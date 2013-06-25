//
//  RssFrame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 12/08/2010.
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

#import "RSSFrame.h"


@implementation RSSFrame

@synthesize title, link, frameDescription, pubDate, authorName, articleBodyURL, articleRetrieved;

- (NSArray*)getResourcePaths {
    if (articleBodyURL != nil)
        return [NSArray arrayWithObject:articleBodyURL];
    else
        return [super getResourcePaths];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	self.title = [aDecoder decodeObjectForKey:@"title"];
	self.link = [aDecoder decodeObjectForKey:@"link"];
	self.frameDescription = [aDecoder decodeObjectForKey:@"frameDescription"];
	self.pubDate = [aDecoder decodeObjectForKey:@"pubDate"];
    
    self.articleBodyURL = [aDecoder decodeObjectForKey:@"articleBodyURL"];
    self.authorName = [aDecoder decodeObjectForKey:@"authorName"];
    
    self.articleRetrieved = [aDecoder decodeBoolForKey:@"articleRetrieved"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:link forKey:@"link"];
	[aCoder encodeObject:frameDescription forKey:@"frameDescription"];
	[aCoder encodeObject:pubDate forKey:@"pubDate"];
    
	[aCoder encodeObject:articleBodyURL forKey:@"articleBodyURL"];
	[aCoder encodeObject:authorName forKey:@"authorName"];
    [aCoder encodeBool:articleRetrieved forKey:@"articleRetrieved"];
}

#pragma mark Lifecycle

- (NSString*)description {
	return [NSString stringWithString:title];
}

- (id)init {
	if (self = [super init]) {
		self.articleRetrieved = NO;
	}
	
	return self;
}

- (void)dealloc {
	self.title = nil;
	self.link = nil;
	self.frameDescription = nil;
	self.pubDate = nil;	
    
    self.authorName = nil;
    self.articleBodyURL = nil;
    
	[super dealloc];
}

@end
