//
//  FlickrFeed.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 04/10/2010.
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

#import "FlickrFeed.h"
#import <CoreLocation/CoreLocation.h>
#import "FlickrFrame.h"
#import "OAuthProtocol.h"
#import "OAuthCore.h"
#import "FeedSource.h"
#import "CacheController.h"
#import "Stream.h"
#import "AuthFlickr.h"
#import "Core.h"
#import "SettingsController.h"
#import "LocationController.h"

@interface FlickrFeed () 

@property (nonatomic, retain) NSMutableString *receivedData;
@property (nonatomic, copy) NSString *currentElementName;
@property (nonatomic, retain) NSMutableArray *elementPath;
@property (nonatomic, retain) FlickrFrame *frame;
@property (nonatomic, retain) NSDictionary *attributes;

@end

@implementation FlickrFeed {
	int page;
	int pagesCount;    
}

@synthesize receivedData, currentElementName, elementPath, frame, attributes;

#pragma mark Properties

- (void)makeFrameReady:(Frame*)frameToBeComplimented {	
	if (frameToBeComplimented == nil)
		return;

	FlickrFrame *f = (FlickrFrame*)frameToBeComplimented;
	f.imageURL = [[CacheController sharedInstance] storeImageData:f.imageURL withThumb:YES];
	if (f.imageURL != nil) {
		f.thumbURL = [f.imageURL stringByAppendingString:@"thumb"];
	} else {
		f.imageURL = [[CacheController sharedInstance] storeImageData:f.secondaryImageURL withThumb:YES];
		f.thumbURL = [f.imageURL stringByAppendingString:@"thumb"];			
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
    int index = [self.source.URLString rangeOfString:@"lat="].location;
    if (index != NSNotFound) {
        NSString *s = [self.source.URLString substringToIndex:index];
        CLLocation *loc = [LocationController sharedInstance].location;
        if (loc != nil) {
            self.source.URLString = [NSString stringWithFormat:@"%@lat=%+.6f&lon=%+.6f&radius=10", s, loc.coordinate.latitude, loc.coordinate.longitude];                
        }             
    }
    
    if (![SettingsController sharedInstance].paginateFeeds)
        page = 1;
    
	NSString *urlString = [NSString stringWithFormat:@"%@&page=%d&per_page=%d", self.source.URLString, page, FEEDS_PER_PAGE];
	DebugLog(@"loading flickr feed: %@, page: %d", urlString, page);

	page++;
	if (pagesCount != 0 && page == pagesCount) {
		page = 1;
	}
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:url];
	
	// prepare data field for recieved data
	NSMutableString *rd = [[NSMutableString alloc] init];
	self.receivedData = rd;
	[rd release];
	
	// sign request with OAuth signature
	id<OAuthProtocol> oauth = [[OAuthCore sharedInstance] getOAuthForRealm:FLICKR_REALM];
	[oauth signRequest:r];	
	
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:r delegate:self];
	[con release];
	
	while (self.loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}	
	
	[pool drain];
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
    NSString *reason = [NSString stringWithFormat:@"Feed \"%@\" requires Flickr authentication.", self.source.title];
    [[OAuthCore sharedInstance] requestAuthForRealm:FLICKR_REALM withDelegate:self viewController:nil askUser:YES reason:reason];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([receivedData rangeOfString:@"<rsp stat=\"fail\">"].location != NSNotFound && 
		[receivedData rangeOfString:@"99"].location != NSNotFound) { 
        
        [self performSelectorOnMainThread:@selector(doRequestAuth) withObject:nil waitUntilDone:NO];
        page = 0;
		[self loadWasFinished];
        
	} else if ([receivedData rangeOfString:@"<rsp stat=\"fail\">"].location != NSNotFound && 
			   [receivedData rangeOfString:@"98"].location != NSNotFound) {        
        
		AuthFlickr *af = (AuthFlickr*)[[OAuthCore sharedInstance] getOAuthForRealm:FLICKR_REALM];
		af.authToken = nil;
        
		[OAuthCore deleteKeychainValueForKey:@"flickr-auth-token"]; 
        
        [self performSelectorOnMainThread:@selector(doRequestAuth) withObject:nil waitUntilDone:NO];        
        
		[self loadWasFinished];
	} else {
		// parse XML response
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[receivedData dataUsingEncoding:NSUTF8StringEncoding]];
		parser.delegate = self;
		[parser parse];
		[parser release];				
	}
	
	self.receivedData = nil;
} 

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	page = 1;
	pagesCount = 0;
	[self loadWasFinished];
}

#pragma mark NSXMLParserDelegate

- (void)sortQueue {
	if ([self.tempQueue count] != 0) {
		NSSortDescriptor *sorterKey = [[NSSortDescriptor alloc] initWithKey:@"dateUpload" ascending: NO];
		NSArray *sorters = [NSArray arrayWithObjects:sorterKey, nil];
		[self.tempQueue sortUsingDescriptors:sorters];
		[sorterKey release];
		
		self.queue = [NSArray arrayWithArray:self.tempQueue];
		self.currentFrameIndex = 0;
		
		[self.tempQueue removeAllObjects];
	}	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	self.elementPath = nil;		
	[self sortQueue];	
	[self loadWasFinished];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSMutableArray *ep = [[NSMutableArray alloc] init];
	self.elementPath = ep;
	[ep release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	self.currentElementName = elementName;
	[elementPath addObject:currentElementName]; 
	
	if ([elementName isEqualToString:@"photo"]) {
		FlickrFrame *ff = [[FlickrFrame alloc] init];
		self.frame = ff;
		[ff release];
	} else if ([elementName isEqualToString:@"photos"]) {
		pagesCount = [[attributeDict objectForKey:@"pages"] intValue];
	}
		
	self.attributes = attributeDict;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString:@"photo"]) {
		frame.feed = self;
		
		frame.userName = [attributes objectForKey:@"ownername"];

		frame.title = [attributes objectForKey:@"title"];	
		
		// construct image URLs
		NSString *farm = [attributes objectForKey:@"farm"];
		NSString *server = [attributes objectForKey:@"server"];
		NSString *imageID = [attributes objectForKey:@"id"];
		NSString *secret = [attributes objectForKey:@"secret"];
		
		NSString *imgUrl = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_z.jpg",
							   farm, server, imageID, secret];
		frame.imageURL = imgUrl;
		imgUrl = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@.jpg",
									farm, server, imageID, secret];
		frame.secondaryImageURL = imgUrl;

		frame.URLString = [NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@", 
						   [attributes objectForKey:@"owner"], 
						   imageID];
		
		NSString *seconds = [attributes objectForKey:@"dateupload"];
		frame.dateUpload = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
		
		if (![SettingsController sharedInstance].removeViewedFrames || 
			![[Core sharedInstance] isFrameDeleted:frame.URLString]) {
			[self.tempQueue addObject:frame];
		}
		self.frame = nil;
	} 
	
	[elementPath removeLastObject];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {	
	FlickrFeed *copy = [[FlickrFeed alloc] init];
	
	copy.title = self.title;
	copy.source = self.source;
	
	return copy;	
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		page = 1;
		pagesCount = 0;
	}
	return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"Flickr Feed, URL: %@", self.source.URLString];
}

- (void)dealloc {
	self.currentElementName = nil;
	self.elementPath = nil;
	self.attributes = nil;
	
	[super dealloc];
}

@end
