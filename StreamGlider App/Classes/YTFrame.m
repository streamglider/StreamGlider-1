//
//  YTFrame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 21/09/2010.
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
