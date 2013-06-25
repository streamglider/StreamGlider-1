//
//  FeedSourceCategory.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 28/02/2011.
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

#import "FeedSourceCategory.h"
#import "FeedSource.h"

@implementation FeedSourceCategory

@synthesize children, parentCategory, title, imageURL;

#pragma mark Children

- (void)addChild:(NSObject*)child {	
	[children addObject:child];
}

- (void)removeChild:(NSObject*)child {
	[children removeObject:child];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super init];
	self.title = [aDecoder decodeObjectForKey:@"title"];
	self.children = [aDecoder decodeObjectForKey:@"children"];
	
	// set parent category to self for all children
	for (NSObject *child in children) {
		if ([child isMemberOfClass:[FeedSourceCategory class]]) {
			((FeedSourceCategory*)child).parentCategory = self;
		} else {
			((FeedSource*)child).category = self;
		}
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:children forKey:@"children"];
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		children = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	self.children = nil;
	self.parentCategory = nil;
	self.title = nil;
    self.imageURL = nil;
	
	[super dealloc];
}

@end
