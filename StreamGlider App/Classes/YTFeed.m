//
//  YTFeed.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 21/09/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <CoreLocation/CoreLocation.h>
#import "YTFeed.h"
#import "YTFrame.h"
#import "FeedSource.h"
#import "CacheController.h"
#import "Core.h"
#import "SettingsController.h"
#import "OAuth2.h"
#import "OAuthCore.h"
#import "LocationController.h"

@interface YTFeed () 

@property (nonatomic, retain) NSMutableString *receivedData;

@property (nonatomic, retain) NSSet *tagNames;
@property (nonatomic, copy) NSString *currentElementName;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) NSMutableArray *elementPath;
@property (nonatomic, retain) YTFrame *frame;
@property (nonatomic, retain) NSDictionary *attributes;

@end

@implementation YTFeed {
	int pagesCount;
	int page;    
}

@synthesize receivedData, tagNames, currentElementName, currentText, elementPath, frame, 
	authorName, attributes;

#pragma mark Loading

- (void)makeFrameReady:(Frame*)f {	
	if (f.imageURL != nil) {
		f.imageURL = [[CacheController sharedInstance] storeImageData:f.imageURL 
																withThumb:YES];
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
    
	int startIndex = 1;
    if ([SettingsController sharedInstance].paginateFeeds)
        startIndex += (FEEDS_PER_PAGE * page);
    
    // rewrite URL string with fresh coordinates, if it's location enabled
    int index = [self.source.URLString rangeOfString:@"location="].location;
    if (index != NSNotFound) {
        NSString *s = [self.source.URLString substringToIndex:index];
        CLLocation *loc = [LocationController sharedInstance].location;
        if (loc != nil) {
            self.source.URLString = [NSString stringWithFormat:@"%@location=%.5f,%.5f&location-radius=10km", s, loc.coordinate.latitude, loc.coordinate.longitude];                
        }             
    }

    
	NSURL *url = [NSURL URLWithString:self.source.URLString];
	
    if ([SettingsController sharedInstance].paginateFeeds) {
        page++;
        if (pagesCount != 0 && page > pagesCount) {
            page = 0;
        }
    }
	
	NSMutableString *query = [NSMutableString stringWithString:@""];
	if ([url query] != nil) {
		[query appendFormat:@"%@&", [url query]];
	}
	
	[query appendFormat:@"start-index=%d&max-results=%d", startIndex, FEEDS_PER_PAGE];
	
	OAuth2 *oauth = (OAuth2*)[[OAuthCore sharedInstance] getOAuthForRealm:YOUTUBE_REALM];
		
	if (oauth.accessToken != nil)
		[query appendFormat:@"&access_token=%@", oauth.accessToken];
	
	NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", [url host], [url path], query];
	
	url = [NSURL URLWithString:urlString];
	
	DebugLog(@"loading YouTube feed: %@", urlString);
	
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
		NSSortDescriptor *sorterKey = [[NSSortDescriptor alloc] initWithKey:@"published" ascending: NO];
		NSArray *sorters = [NSArray arrayWithObjects:sorterKey, nil];
		[self.tempQueue sortUsingDescriptors:sorters];
		[sorterKey release];
		
		self.queue = [NSArray arrayWithArray:self.tempQueue];
		self.currentFrameIndex = 0;
		
		[self.tempQueue removeAllObjects];
	}	
}

#pragma mark NSXMLParserDelegate

#define TAG_NAMES @"title", @"name", @"published", @"link", @"item", @"media:thumbnail", @"yt:duration", @"openSearch:totalResults", nil

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	self.elementPath = nil;	
	
	[self sortQueue];
	[self loadWasFinished];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.elementPath = nil;	
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
	if ([elementName isEqualToString:@"entry"]) {
		YTFrame *f = [[YTFrame alloc] init];
		self.frame = f;
		[f release];		
	} else if ([tagNames containsObject:elementName]) {
		NSMutableString *ct = [[NSMutableString alloc] init];
		self.currentText = ct;
		[ct release];
	}
	
	self.attributes = attributeDict;
}

#define SECONDS_PER_HOUR 3600
#define SECONDS_PER_MINUTE 60

- (NSString*)formatDuration:(NSString*)seconds {
	int sec = [seconds intValue];
	
	NSString *ret = @"";
	
	int hours = sec / SECONDS_PER_HOUR;
	sec %= SECONDS_PER_HOUR;
	
	int minutes = sec / SECONDS_PER_MINUTE;
	sec %= SECONDS_PER_MINUTE;
	
	if (hours > 0)
		ret = [NSString stringWithFormat:@"%.2d:", hours];
	

	ret = [NSString stringWithFormat:@"%@%.2d:", ret, minutes];
	
	ret = [NSString stringWithFormat:@"%@%.2d", ret, sec];
	
	return ret;
}

static NSString *dateFormatString = @"yyyy-MM-dd'T'HH:mm:ss.SSS";

- (NSString*)dateFormat {
	return dateFormatString;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString: @"entry"]) {
		// add frame to the stream		
		frame.feed = self;		
		if (![SettingsController sharedInstance].removeViewedFrames || 
			![[Core sharedInstance] isFrameDeleted:self.frame.URLString]) {		
			[self.tempQueue addObject:frame];
		}
		
		self.frame = nil;			
	} else if ([currentElementName isEqualToString:elementName]) {
		// save data in the frame object
		if ([elementName isEqualToString:@"title"] && [elementPath count] == 3) {
			frame.title = currentText;
			
		} else if ([elementName isEqualToString:@"link"] && [elementPath count] == 3) {
			NSString *rel = [attributes objectForKey:@"rel"];
			if (rel != nil && [rel isEqualToString:@"alternate"]) {
				frame.URLString = [attributes objectForKey:@"href"];
			}
		} else if ([elementName isEqualToString:@"published"]) {
			frame.published = [self parseDate:currentText];				
		} else if ([elementName isEqualToString:@"name"]) {
			if ([elementPath count] == 3) {
				self.authorName = currentText;
			} else {
				frame.authorName = currentText;
			}	
		} else if ([elementName isEqualToString:@"media:thumbnail"] && frame.thumbURL == nil) {
			frame.imageURL = [attributes objectForKey:@"url"];
		} else if ([elementName isEqualToString:@"yt:duration"]) {
			frame.durationString = [self formatDuration:[attributes objectForKey:@"seconds"]];
		} else if ([elementName isEqualToString:@"openSearch:totalResults"]) {
			int total = [currentText intValue];			
			pagesCount = total / FEEDS_PER_PAGE;			
			if (total % FEEDS_PER_PAGE == 0)
				pagesCount--;
		}
	}
	
	[elementPath removeLastObject];
	self.currentText = nil;		 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.currentText appendString:string];
}

#pragma mark OAuthDelegate

- (void)exchangeWasFinished:(id<OAuthProtocol>)oauth {
	if ([oauth authenticated])
		[self loadNewFrames];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if (str != nil)
		[self.receivedData appendString:str];
	
	[str release];	
}

- (void)doRequestAuth {
    NSString *reason = [NSString stringWithFormat:@"Feed \"%@\" requires YouTube authentication.", self.source.title];
    [[OAuthCore sharedInstance] requestAuthForRealm:YOUTUBE_REALM withDelegate:self viewController:nil askUser:YES reason:reason];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	
	if ([receivedData rangeOfString:@"Token invalid"].location != NSNotFound || 
		[receivedData rangeOfString:@"Error 401"].location != NSNotFound) {
        [self performSelectorOnMainThread:@selector(doRequestAuth) withObject:nil waitUntilDone:NO];
		self.receivedData = nil;
        page = 0;
        [self loadWasFinished];        
		return;
	}
	
	// parse XML response
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[receivedData dataUsingEncoding:NSUTF8StringEncoding]];
	
	self.receivedData = nil;
	
	parser.delegate = self;
	
	[parser parse];
	[parser release];			
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"failed, error: %@", error);	
	page = 0;
	pagesCount = 0;
	[self loadWasFinished];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {	
	YTFeed *copy = [[YTFeed alloc] init];
	
	copy.title = self.title;
	copy.source = self.source;
	
	return copy;	
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		NSSet *tn = [[NSSet alloc] initWithObjects:TAG_NAMES];
		self.tagNames = tn;
		[tn release];
		
		pagesCount = 0;
		page = 0;
	}
	return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"YouTube Feed, URL: %@", self.source.URLString];
}

- (void)dealloc {
	self.tagNames = nil;
	self.currentElementName = nil;
	self.elementPath = nil;
	self.authorName = nil;
	self.attributes = nil;
	
	[super dealloc];
}

@end
