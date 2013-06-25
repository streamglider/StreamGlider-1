//
//  YTFrame.m
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

#import "YTFrame.h"

@implementation YTFrame

@synthesize authorName, published, durationString, title;

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	self.authorName = [aDecoder decodeObjectForKey:@"authorName"];
	self.published = [aDecoder decodeObjectForKey:@"published"];
	self.durationString = [aDecoder decodeObjectForKey:@"durationString"];
	self.title = [aDecoder decodeObjectForKey:@"title"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:authorName forKey:@"authorName"];
	[aCoder encodeObject:published forKey:@"published"];
	[aCoder encodeObject:durationString forKey:@"durationString"];	
	[aCoder encodeObject:title forKey:@"title"];
}

#pragma mark Lifecycle

- (NSString*)description {
	return [NSString stringWithString:title];
}

- (void)dealloc {
	self.authorName = nil;
	self.published = nil;
	self.durationString = nil;
	self.title = nil;
	
	[super dealloc];
}

@end
