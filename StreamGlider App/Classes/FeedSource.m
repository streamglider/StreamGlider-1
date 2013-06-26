//
//  TwitterSource.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 06/09/2010.
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

#import "FeedSource.h"


@implementation FeedSource

@synthesize URLString, title, type, category;

#pragma mark Properties

- (void)setURLString:(NSString *)aURLString {    
    // replace feed:// scheme with http:// scheme
    NSString *s = aURLString;
    if ([s hasPrefix:@"feed://"]) {
        s = [s stringByReplacingOccurrencesOfString:@"feed://" withString:@"http://"];
        DebugLog(@"rss feed feed:// scheme is replaced with http://");
    }
    
    URLString = [s copy];
}

#pragma mark NSCopying


- (id)copyWithZone:(NSZone *)zone {
	FeedSource *another = [[FeedSource alloc] init];
	
	another.URLString = URLString;
	another.type = type;
	another.title = title;
	
	return another;
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object {
	NSObject *another = (NSObject*)object;
	if ([another isMemberOfClass:[FeedSource class]]) {
		FeedSource *anotherFS = (FeedSource*)another;
		if (anotherFS.type == type && 
			[URLString isEqualToString:anotherFS.URLString] && 
			[title isEqualToString:anotherFS.title]) {
			return YES;
		}
	}
	
	return NO;
}

- (NSUInteger)hash {
	return [URLString hash];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super init];
	self.title = [aDecoder decodeObjectForKey:@"title"];
	self.URLString = [aDecoder decodeObjectForKey:@"URLString"];
	self.type = [aDecoder decodeIntForKey:@"type"];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:URLString forKey:@"URLString"];
	[aCoder encodeInt:type forKey:@"type"];
}

#pragma mark Lifecycle

- (void)dealloc {
	self.URLString = nil;
	self.title = nil;	
	[super dealloc];
}

@end
