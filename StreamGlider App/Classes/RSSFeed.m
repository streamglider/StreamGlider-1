//
//  RSSFeed.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 12/08/2010.
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

#import "RSSFeed.h"
#import "RSSFrame.h"
#import "Stream.h"
#import "FeedSource.h"
#import "CacheController.h"
#import "SettingsController.h"
#import "Core.h"
#import "NSString+OAuth.h"

@interface RSSFeed () 

@property (nonatomic, retain) NSMutableString *receivedData;

@property (nonatomic, retain) NSSet *tagNames;
@property (nonatomic, copy) NSString *currentElementName;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) NSMutableArray *elementPath;

@property (nonatomic, retain) RSSFrame *frame;
@property (nonatomic, copy) NSDate *oldLastBuildDate;
@property (nonatomic, retain) NSDictionary *attributes;

@property (nonatomic, copy) NSString *contentEncoded;

@end

@implementation RSSFeed {	
	int page;        
}

@synthesize link, feedDescription, lastBuildDate, receivedData, feedTitle,
	tagNames, currentElementName, currentText, elementPath, frame, oldLastBuildDate,
	imageURL, imageData, attributes, contentEncoded;

#pragma mark Utility Methods

- (NSString *)flattenHTML:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while (![theScanner isAtEnd]) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL]; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@>", text]
											   withString:@""];
		
    } // while //
	
    return html;
}

- (NSString*)sanitizeString:(NSString*)str {
	NSMutableCharacterSet *set = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
	[set formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
	NSArray* components = [str componentsSeparatedByCharactersInSet:set];
    return [components componentsJoinedByString:@""];
}


- (NSString*)parseAuthorName:(NSString*)s {
    // author name should be in ()
    int start = [s rangeOfString:@"("].location;
    if (start != NSNotFound) {
        int end = [s rangeOfString:@")"].location;
        NSRange rng = NSMakeRange(start + 1, end - start - 1);
        return [s substringWithRange:rng];
    } else
        return s;
}

#pragma mark Properties

- (void)setSource:(FeedSource*)newSource {
	[super setSource:newSource];
	// clear oldLastBuildDate
	self.oldLastBuildDate = nil;
}

#pragma mark Loading

- (NSString*)extractImageFromDescription:(NSString*)s {
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:s];
	
	// find start of tag
	[theScanner scanUpToString:@"<img" intoString:NULL];
	
	while (![theScanner isAtEnd]) {
		// find end of tag
		[theScanner scanUpToString:@">" intoString:&text];
	
		// extract img source
		int index = [text rangeOfString:@"src"].location;
		if (index != NSNotFound) {
			text = [text substringFromIndex:index + 3];
			index = [text rangeOfString:@"="].location;
			
			if (index == NSNotFound)
				return nil;
			
			text = [text substringFromIndex:index + 1];
			index = [text rangeOfString:@"\""].location;
			
			if (index == NSNotFound)
				return nil;
			
			text = [text substringFromIndex:index + 1];			
			index = [text rangeOfString:@"\""].location;
			
			if (index == NSNotFound)
				return nil;		
			
			text = [text substringToIndex:index];
			
			text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			if ([text hasSuffix:@".png"] || [text hasSuffix:@".jpg"] || [text hasSuffix:@"jpeg"]) {
				text = [text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
				DebugLog(@"approved: %@", text);
				return text;
			}
		}
		[theScanner scanUpToString:@"<img" intoString:NULL];		
	}
		
    return nil;	
}

- (void)makeFrameReady:(Frame*)frameToBeComplimented {
	RSSFrame *f = (RSSFrame*)frameToBeComplimented;
		
	// sanitize title (remove all HTML tags)
	f.title = [self flattenHTML:f.title]; 

    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:f.URLString]];
    
    if (data != nil) {
        f.articleBodyURL = [[CacheController sharedInstance] storeResourceData:data];
    }
	
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
		
	DebugLog(@"loading rss feed: %@", self.source.URLString);
	
	NSURL *url = [NSURL URLWithString:self.source.URLString];
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
		NSSortDescriptor *sorterKey = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending: NO];
		NSArray *sorters = [NSArray arrayWithObjects:sorterKey, nil];
		[self.tempQueue sortUsingDescriptors:sorters];
		[sorterKey release];
		
		NSRange rng = NSMakeRange(page * FEEDS_PER_PAGE, FEEDS_PER_PAGE);
		
		if (rng.location >= [self.tempQueue count]) {
			page = 0;
			rng.location = 0;
		} 
		
		if ((rng.location + rng.length) > [self.tempQueue count]) {
			rng.length = [self.tempQueue count] - rng.location;
		}
		
		DebugLog(@"feed: %@", feedTitle);
		DebugLog(@"queue size: %d", [self.tempQueue count]);
		DebugLog(@"page: %d, rng: %d/%d", page, rng.location, rng.length);
		
		self.currentFrameIndex = 0;
		self.queue = [self.tempQueue subarrayWithRange:rng];
		
		[self.tempQueue removeAllObjects];
		
		page++;
	}
}

#pragma mark NSXMLParserDelegate

#define TAG_NAMES @"title", @"link", @"description", @"pubDate", @"lastBuildDate", @"item", @"url", @"media:thumbnail", @"author", @"content:encoded", nil

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
    
	self.elementPath = nil;	
	self.oldLastBuildDate = self.lastBuildDate;
	
	if (imageURL != nil) {
		// load image data
		self.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
	}
		
	[self sortQueue];
	[self loadWasFinished];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"parse error: %@ with RSS feed: %@", parseError, self.source.URLString);
	self.elementPath = nil;	
	self.oldLastBuildDate = self.lastBuildDate;
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
	if ([elementName isEqualToString:@"item"]) {
		RSSFrame *f = [[RSSFrame alloc] init];
		self.frame = f;
		[f release];		
	} else if ([tagNames containsObject:elementName]) {
		NSMutableString *ct = [[NSMutableString alloc] init];
		self.currentText = ct;
		[ct release];
	}
	
	self.attributes = attributeDict;
}

static NSString *dateFormatString = @"EEE, d MMM yyyy HH:mm:ss zzz";

- (NSString*)dateFormat {
	return dateFormatString;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString: @"item"]) {
		// add frame to the stream		
		self.frame.feed = self;
		self.frame.URLString = self.frame.link;
		self.frame.imageURL = [self extractImageFromDescription:self.frame.frameDescription];
        
        if (!self.frame.imageURL && self.contentEncoded != NULL)
            self.frame.imageURL = [self extractImageFromDescription:self.contentEncoded];
		
		if (![SettingsController sharedInstance].removeViewedFrames || 
			![[Core sharedInstance] isFrameDeleted:self.frame.URLString]) {            
			[self.tempQueue addObject:self.frame];
		}
        
		self.frame = nil;
		self.contentEncoded = nil;
        
	} else if ([currentElementName isEqualToString:elementName]) {
		// save data in the frame object
		if ([elementName isEqualToString:@"title"]) {
			if ([elementPath count] == 3) {
				// channel title
				self.feedTitle = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			} else {
				// item title
				self.frame.title = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			}
			
		} else if ([elementName isEqualToString:@"link"]) {
			if ([elementPath count] == 3) {
				// channel link
				self.link = [self sanitizeString:currentText];
			} else {
				// item link
				self.frame.link = [self sanitizeString:currentText];
			}
		} else if ([elementName isEqualToString:@"description"]) {
			if ([elementPath count] == 3) {
				// channel desc
				self.feedDescription = currentText;
			} else {
				// item desc
				self.frame.frameDescription = currentText;
			}
		} else if ([elementName isEqualToString:@"content:encoded"]) {
            // content:encoded field
            self.contentEncoded = currentText;
		} else if ([elementName isEqualToString:@"pubDate"]) {
			// item pubDate
			self.frame.pubDate = [self parseDate:currentText];							
		} else if ([elementName isEqualToString:@"url"]) {
			if ([elementPath count] == 4)
				self.imageURL = currentText;
			
		} else if ([elementName isEqualToString:@"lastBuildDate"]) {
			@try {
				// channel last build date 
				self.lastBuildDate = [self parseDate:currentText];
				DebugLog(@"last build date: %@ for feed: %@", self.lastBuildDate, self.feedTitle);
				if (self.oldLastBuildDate == nil || 
					self.lastBuildDate != [self.lastBuildDate earlierDate:self.oldLastBuildDate]) {
					//increase page number
					// clear the queue in case we have new data available
					self.currentFrameIndex = 0;
					page = 0;
				}
			} 
			@catch (NSException *e) {
				NSLog(@"last build date parsing error: %@", e);
				// clear the queue in case we have new data available
				self.currentFrameIndex = 0;				
				page = 0;
			}
		} else if ([elementName isEqualToString:@"media:thumbnail"]) {
			frame.imageURL = [attributes objectForKey:@"url"];
		} else if ([elementName isEqualToString:@"author"]) {
            DebugLog(@"author string: %@", currentText);
            frame.authorName = [self parseAuthorName:currentText];
            DebugLog(@"extracted author: %@", frame.authorName);
        }        
	}
	
	[elementPath removeLastObject];
	self.currentText = nil;		 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.currentText appendString:string];
}


#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	    
	if (str != nil)
		[self.receivedData appendString:str];
	
	[str release];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// parse XML response
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[receivedData dataUsingEncoding:NSUTF8StringEncoding]];
	
	self.receivedData = nil;
	
	parser.delegate = self;
	
	[parser parse];
	[parser release];			
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"failed, error: %@", error);	
	[self loadWasFinished];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {	
	RSSFeed *copy = [[RSSFeed alloc] init];
	
	copy.title = self.title;
	copy.source = self.source;
	copy.feedTitle = self.feedTitle;
	
	return copy;	
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];	
	self.feedTitle = [aDecoder decodeObjectForKey:@"feedTitle"];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];	
	[aCoder encodeObject:feedTitle forKey:@"feedTitle"];
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		NSSet *tn = [[NSSet alloc] initWithObjects:TAG_NAMES];
		self.tagNames = tn;
		[tn release];		
		
		page = 0;
	}
	return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"RSS Feed, channel URL: %@, description: %@", self.source.URLString, feedDescription];
}

- (void)dealloc {
	self.link = nil;
	self.feedDescription = nil;
	self.feedTitle = nil;
	self.lastBuildDate = nil;
	self.oldLastBuildDate = nil;
	self.tagNames = nil;
	self.currentElementName = nil;
	self.elementPath = nil;
	self.imageURL = nil;
	self.imageData = nil;
	self.attributes = nil;
	self.currentText = nil;
    self.contentEncoded = nil;
	
	[super dealloc];
}

@end
