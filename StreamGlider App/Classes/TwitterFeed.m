//
//  TwitterFeed.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 25/08/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
//
//  This program is free software if used non-commercially: you can redistribute it and/or modify
//  it under the terms of the BSD 4 Clause License as published by
//  the Free Software Foundation.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  BSD 4 Clause License for more details.
//
//  You should have received a copy of the BSD 4 Clause License
//  along with this program.  If not, see the README.md file with this program.

#import "TwitterFeed.h"
#import "TwitterFrame.h"
#import "OAuthProtocol.h"
#import "OAuthCore.h"
#import "FeedSource.h"
#import "CacheController.h"
#import "Core.h"
#import "SettingsController.h"
#import "LocationController.h"
#import "JSON.h"

@interface TwitterFeed ()

@property (nonatomic, retain) NSMutableString *receivedData;
@property (nonatomic, copy) NSString *minId;

@end

@implementation TwitterFeed {
   	BOOL isSearch;
}

@synthesize receivedData, minId;

#pragma mark Properties

- (void)setSource:(FeedSource*)newSource {
	[super setSource:newSource];
    self.minId = nil;
	int index = [newSource.URLString rangeOfString:@"search/tweets"].location;
	isSearch = index != NSNotFound;
}

#pragma mark Loading

- (void)makeFrameReady:(Frame*)f {
	// load images
	if (f.imageURL != nil) {
		f.imageURL = [[CacheController sharedInstance] storeImageData:f.imageURL 
																withThumb:NO];			
	}	
}

- (void)performLoadInBackground {
	[super performLoadInBackground];	
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (self.source == nil) {
		[self loadWasFinished];
		return;
	}
	
    // rewrite URL string with fresh coordinates, if it's location enabled
    int index = [self.source.URLString rangeOfString:@"geocode="].location;
    if (index != NSNotFound) {
        NSString *s = [self.source.URLString substringToIndex:index + @"geocode=".length];
        CLLocation *loc = [LocationController sharedInstance].location;
        if (loc != nil) {
            self.source.URLString = [NSString stringWithFormat:@"%@%+.6f,%+.6f,10km", s, loc.coordinate.latitude, loc.coordinate.longitude];                
        }             
    }
    
	NSURL *url = [NSURL URLWithString:self.source.URLString];
	
	NSMutableString *query = [NSMutableString stringWithString:@""];
	if ([url query] != nil) {
		[query appendFormat:@"%@&", [url query]];
	}
	
    // if max_id is null, don't add it to the query
	[query appendFormat:@"count=%d", FEEDS_PER_PAGE];
    
    if ([SettingsController sharedInstance].paginateFeeds) {
        if (minId)
            [query appendFormat:@"&max_id=%@", minId];
    }
	
	NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", [url host], [url path], query];
	
	url = [NSURL URLWithString:urlString];
    
	DebugLog(@"loading twitter feed: %@", urlString);
	
	NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:url];
    
    [r setHTTPShouldHandleCookies:NO];
	
	// prepare data field for recieved data
	NSMutableString *rd = [[NSMutableString alloc] init];
	self.receivedData = rd;
	[rd release];
	
	// sign request with OAuth signature
	id<OAuthProtocol> oauth = [[OAuthCore sharedInstance] getOAuthForRealm:TWITTER_REALM];
	[oauth signRequest:r];	
		
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:r delegate:self];
	[con release];
	
	while (self.loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}	
	
	[pool drain];
}

- (void)sortQueue {
	if ([self.tempQueue count] != 0) {
		NSSortDescriptor *sorterKey = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending: NO];
		NSArray *sorters = [NSArray arrayWithObjects:sorterKey, nil];
		[self.tempQueue sortUsingDescriptors:sorters];
		[sorterKey release];
		
		self.queue = [NSArray arrayWithArray:self.tempQueue];
		self.currentFrameIndex = 0;
		
		[self.tempQueue removeAllObjects];
	}	
}

#pragma mark OAuthDelegate

- (void)exchangeWasFinished:(id<OAuthProtocol>)oauth {
	if ([oauth authenticated]) {
		[self loadNewFrames];
	} 
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if (str != nil)
		[self.receivedData appendString:str];
	
	[str release];
}

- (void)doRequestAuth {
    NSString *reason = [NSString stringWithFormat:@"Feed \"%@\" requires Twitter authentication.", self.source.title];
    [[OAuthCore sharedInstance] requestAuthForRealm:TWITTER_REALM withDelegate:self viewController:nil askUser:YES reason:reason];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	// check if it's an error response
	if ([receivedData rangeOfString:@"Bad Authentication data"].location != NSNotFound) {
        [self performSelectorOnMainThread:@selector(doRequestAuth) withObject:nil waitUntilDone:NO];
        self.minId = nil;
		[self loadWasFinished];
	} else {
        NSObject *jsData = [receivedData JSONValue];
        NSArray *statuses = nil;
        if ([jsData isKindOfClass:[NSArray class]]) {
            statuses = (NSArray*)jsData;
        } else {
            NSDictionary *dic = (NSDictionary*)jsData;
            statuses = [dic objectForKey:@"statuses"];
        }
                     
        for (NSDictionary *status in statuses) {
            TwitterFrame *tf = [[TwitterFrame alloc] init];
            
            tf.feed = self;
            
            tf.text = [status objectForKey:@"text"];
            tf.userName = [[status objectForKey:@"user"] objectForKey:@"screen_name"];
            tf.createdAt = [self parseDate:[status objectForKey:@"created_at"]];
            tf.imageURL = [[status objectForKey:@"user"] objectForKey:@"profile_image_url"];
            
            tf.statusId = [status objectForKey:@"id_str"];
            
            self.minId = tf.statusId;
            
            NSString *urlString = [self extractURLFrom:tf.text];
            
            if (urlString != nil)
                tf.URLString = urlString;
            else
                tf.URLString = [NSString stringWithFormat:@"https://twitter.com/user/status/%@", tf.statusId];
            
            if (![SettingsController sharedInstance].removeViewedFrames ||
                ![[Core sharedInstance] isFrameDeleted:tf.URLString]) {
                [self.tempQueue addObject:tf];
            }
            
            [tf release];            
        }
        
        if ([self.tempQueue count] == 0)
            self.minId = nil;
        
        [self sortQueue];
        [self loadWasFinished];        
	}
	
	self.receivedData = nil;	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.minId = nil;
	[self loadWasFinished];
}


- (NSString*)extractURLFrom:(NSString*)text {
	int index = [text rangeOfString:@"http://"].location;
	
	if (index != NSNotFound) {
		NSRange rng;
		rng.location = index;
		rng.length = [text length] - rng.location;
		int end = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] 
							  options:NSCaseInsensitiveSearch range:rng].location;
		if (end == NSNotFound)
			end = [text length];
		
		rng.length = end - rng.location;
		
		NSString *ret = [text substringWithRange:rng];		
		return ret;
	}	
	return nil;
}

static NSString *dateFormatString = @"EEE MMM d HH:mm:ss ZZZ yyyy";

- (NSString*)dateFormat {
	return dateFormatString;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {	
	TwitterFeed *copy = [[TwitterFeed alloc] init];
	
	copy.title = self.title;
	copy.source = self.source;
		
	return copy;	
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
        self.minId = nil;
	}
	
	return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"Twitter Feed, URL: %@", self.source.URLString];
}

- (void)dealloc {
    self.receivedData = nil;
    self.minId = nil;
	
	[super dealloc];
}

@end
