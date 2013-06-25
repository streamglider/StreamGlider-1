//
//  GReaderLoader.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 03/05/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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

#import "GReaderLoader.h"
#import "FeedSource.h"
#import "FeedSourceCategory.h"

@interface GReaderLoader ()

@property (nonatomic, copy) NSString *auth;
@property (nonatomic, retain) NSMutableDictionary *sources;
@property (nonatomic, retain) FeedSourceCategory *category;

@end

@implementation GReaderLoader

@synthesize auth, delegate, sources, category;

#pragma mark Singleton

static GReaderLoader* instance = nil;

+ (GReaderLoader*)sharedInstance {
	if (instance == nil) {
		instance = [[GReaderLoader alloc] init];
	}
	return instance;
}


#pragma mark Google Reader

- (BOOL)loginWithUser:(NSString*)user password:(NSString*)password {
	// get auth
	NSString *urlString = [NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin?service=reader&Email=%@&Passwd=%@", 
						   user, password];
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSString *ret = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	
	NSArray *arr = [ret componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	for (NSString *str in arr) {
		NSArray *params = [str componentsSeparatedByString:@"="];
		if ([[params objectAtIndex:0] isEqualToString:@"Auth"]) {
			self.auth = [params objectAtIndex:1];
		} 
	}
		
	[ret release];
	
	return auth != nil;
}

- (void)addSourcesToCategory:(FeedSourceCategory*)parent {
	NSMutableArray *sortedCats = [[NSMutableArray alloc] initWithCapacity:[[sources allKeys] count]];
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
	NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
	for (NSString *key in [sources allKeys]) {
		FeedSourceCategory *cat = [sources objectForKey:key];
		[sortedCats addObject:cat];
		[cat.children sortUsingDescriptors:descriptors];
	}
	
	[sortedCats sortUsingDescriptors:descriptors];
	
	for (FeedSourceCategory *cat in sortedCats) {
		[parent addChild:cat];
		cat.parentCategory = parent;
	}
	
	[sortedCats release];
}


- (void)getGoogleReaderSourcesForUser:(NSString*)user password:(NSString*)password {
	if ([self loginWithUser:user password:password]) {        
		NSURL *url = [NSURL URLWithString:@"http://www.google.com/reader/public/subscriptions/user/-/"];
		
		NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
		
		NSString *authString = [NSString stringWithFormat:@"GoogleLogin auth=%@", auth];
		[req setValue:authString forHTTPHeaderField:@"Authorization"];
		
		NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:NULL error:NULL];
		NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				
		[req release];
				
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[ret dataUsingEncoding:NSUTF8StringEncoding]];
		
		[ret release];
		
		parser.delegate = self;
		
		[parser parse];
		[parser release];					
	} else {
		[delegate loadFailed];
	}
	
}

#pragma mark NSXMLParserDelegate

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	[delegate loadFinished];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[delegate loadFailed];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {		
    self.category = nil;
    self.sources = nil;
	sources = [[NSMutableDictionary alloc] init];
}

- (void)setCategoryWithName:(NSString*)name {
	for (NSString *key in [sources allKeys]) {
		if ([key isEqualToString:name]) {
			self.category = [sources objectForKey:key];
			return;
		}
	}
	
	// create source category
    self.category = nil;
	category = [[FeedSourceCategory alloc] init];
	category.title = name;
	[sources setObject:category forKey:name];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"outline"]) {
		NSString *xmlUrl = [attributeDict objectForKey:@"xmlUrl"];
		if (xmlUrl != nil) {
			// feed source
			FeedSource *fs = [[FeedSource alloc] init];
			fs.type = FeedSourceTypeRSS;
			fs.URLString = xmlUrl;
			fs.title = [attributeDict objectForKey:@"title"];
			            
			if (category == nil) {
				[self setCategoryWithName:@"GR Feeds"];
			}
            
			if (fs.title != nil && ![fs.title isEqualToString:@"(title unknown)"]) {
				[category addChild:fs];
				fs.category = category;
			}
			[fs release];			
		} else {
			// category
			[self setCategoryWithName:[attributeDict objectForKey:@"title"]];
		}				
	} 	
}

#pragma mark Lifecycle

- (void)dealloc {
	self.auth = nil;
	self.sources = nil;
	self.category = nil;
	
	[super dealloc];
}

@end
