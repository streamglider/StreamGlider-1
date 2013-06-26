//
//  FBFeed.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/09/2010.
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

#import "FBFeed.h"
#import "FeedSource.h"
#import "OAuth2.h"
#import "OAuthCore.h"
#import "NSString+OAuth.h"
#import "JSON.h"
#import "FBFrame.h"
#import "FlickrFrame.h"
#import "CacheController.h"
#import "Core.h"
#import "SettingsController.h"

@interface FBFeed () 

@property (nonatomic, retain) NSMutableString *receivedData;

@end

@implementation FBFeed {
	int page;	
	BOOL photosFeed;    
}

@synthesize receivedData, photosFeed;

- (void)setSource:(FeedSource*)newSource {
	// check if this feed loads photos
	photosFeed = newSource != nil && [newSource.URLString rangeOfString:@"fields=photos"].location != NSNotFound;

	[super setSource:newSource];
}

#pragma mark Loading

- (void)makeFrameReady:(Frame*)frameToBeComplimented {	
	if (photosFeed) {
		FlickrFrame *f = (FlickrFrame*)frameToBeComplimented;
		f.imageURL = [[CacheController sharedInstance] storeImageData:f.imageURL withThumb:YES];
		if (f.imageURL != nil) {
			f.thumbURL = [f.imageURL stringByAppendingString:@"thumb"];
		} 
	} else {
		FBFrame *f = (FBFrame*)frameToBeComplimented;
		
		if (f.userPictureURL != nil) {
			f.userPictureURL = [[CacheController sharedInstance] storeImageData:f.userPictureURL withThumb:NO];
		}
		
		if (f.imageURL != nil) {
			f.imageURL = [[CacheController sharedInstance] storeImageData:f.imageURL withThumb:YES];
			f.thumbURL = [f.imageURL stringByAppendingString:@"thumb"];
		}			
	}
}

- (void)performLoadInBackground {
	[super performLoadInBackground];	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (self.source == nil) {
		[self loadWasFinished];
		return;
	}
	
    if (![SettingsController sharedInstance].paginateFeeds)
        page = 0;
    
	int offset = page * FEEDS_PER_PAGE;
    
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@limit=%d&offset=%d&", 
								  self.source.URLString, FEEDS_PER_PAGE, offset];
	
	page++;
	
	OAuth2 *oauth = (OAuth2*)[[OAuthCore sharedInstance] getOAuthForRealm:FACEBOOK_REALM];
	
	NSString *normalizedAccessToken = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, 
																						  (CFStringRef)oauth.accessToken, 
																						  NULL, 
																						  (CFStringRef)@"￼|", 
																						  kCFStringEncodingUTF8);	
	
	if (normalizedAccessToken != nil) {
		[urlString appendFormat:@"access_token=%@", normalizedAccessToken];
        CFRelease(normalizedAccessToken);
    }
	
	DebugLog(@"loading FB, full url: %@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];	
	
	NSMutableString *rd = [[NSMutableString alloc] init];
	self.receivedData = rd;
	[rd release];
	
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[con release];
	
	while (self.loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];
}

- (void)sortQueue {
	if ([self.tempQueue count] != 0) {
		
		NSString *key = photosFeed ? @"dateUpload" : @"createdTime";
		
		NSSortDescriptor *sorterKey = [[NSSortDescriptor alloc] initWithKey:key ascending: NO];
		NSArray *sorters = [NSArray arrayWithObjects:sorterKey, nil];
		[self.tempQueue sortUsingDescriptors:sorters];
		[sorterKey release];
		
		self.queue = [NSArray arrayWithArray:self.tempQueue];
		self.currentFrameIndex = 0;
	}	
}

#pragma mark OAuthDelegate

- (void)exchangeWasFinished:(id<OAuthProtocol>)oauth {
	if ([oauth authenticated]) {
		[self loadNewFrames];
	} 
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if (str != nil)
		[self.receivedData appendString:str];
	
	[str release];	
}

static NSString *dateFormatString = @"yyyy-MM-dd'T'HH:mm:ssZZZ";

- (NSString*)dateFormat {
	return dateFormatString;
}

- (void)doRequestAuth {
    NSString *reason = [NSString stringWithFormat:@"Feed \"%@\" requires Facebook authentication.", self.source.title];
    [[OAuthCore sharedInstance] requestAuthForRealm:FACEBOOK_REALM withDelegate:self viewController:nil askUser:YES reason:reason];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	
	// read JSON data		
	NSDictionary *dic = [receivedData JSONValue];
	NSArray *data = nil;
	
	if (photosFeed) {
		NSDictionary *photos = [dic objectForKey:@"photos"];
		if (photos != nil)
			data = [photos objectForKey:@"data"];
	} else {
		data = [dic objectForKey:@"data"];
	}

	
	if (data == nil) {
		// check if we need to request authentication
		NSDictionary *error = [dic objectForKey:@"error"];
		NSString *type = [error objectForKey:@"type"];
		if ([type isEqualToString:@"OAuthException"]) {
            page = 0;
            [self performSelectorOnMainThread:@selector(doRequestAuth) withObject:nil waitUntilDone:NO];
		}
	} else {
		for (NSDictionary *item in data) {
			if (photosFeed) {
				FlickrFrame *frame = [[FlickrFrame alloc] init];
				frame.title = [item objectForKey:@"name"];
				frame.imageURL = [item objectForKey:@"source"];
				frame.URLString = [item objectForKey:@"link"];
				
				frame.feed = self;
				
				if (![SettingsController sharedInstance].removeViewedFrames || 
					![[Core sharedInstance] isFrameDeleted:frame.URLString]) {
					[self.tempQueue addObject:frame];
				}
				[frame release];
			} else {
				FBFrame *frame = [[FBFrame alloc] init];
				frame.message = [item objectForKey:@"message"];
				
				frame.createdTime = [self parseDate:[item objectForKey:@"created_time"]];
				
				NSDictionary *user = [item objectForKey:@"from"];
				frame.userName = [user objectForKey:@"name"];
				
				frame.userPictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [user objectForKey:@"id"]];		
				frame.imageURL = [item objectForKey:@"picture"];		
				frame.feed = self;
				
				frame.URLString = [item objectForKey:@"link"];
				if (frame.URLString == nil) {
					frame.URLString = [NSString stringWithFormat:@"http://www.facebook.com/profile.php?id=%@&dummy=%@", 
									   [user objectForKey:@"id"],
									   [item objectForKey:@"id"]];
				}
				
				if (![SettingsController sharedInstance].removeViewedFrames || 
					![[Core sharedInstance] isFrameDeleted:frame.URLString]) {
					[self.tempQueue addObject:frame];	
				}
				
				[frame release];
			}
		}
		
		NSDictionary *paging = [dic objectForKey:@"paging"];
		if (paging == nil || [paging objectForKey:@"next"] == nil) {
			page = 0;
		}			
	}
	
	self.receivedData = nil;	
	[self sortQueue];
	[self loadWasFinished];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"failed, error: %@", error);	
	page = 0;
	[self loadWasFinished];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {	
	FBFeed *copy = [[FBFeed alloc] init];
	
	copy.title = self.title;
	copy.source = self.source;
	
	return copy;	
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		page = 0;
		photosFeed = NO;
	}
	return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"Facebook Feed, URL: %@", self.source.URLString];
}

- (void)dealloc {	
	[super dealloc];
}

@end
