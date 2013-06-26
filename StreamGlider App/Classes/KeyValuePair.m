//
//  KeyValuePair.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 04/08/2010.
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

#import "KeyValuePair.h"


@implementation KeyValuePair

@synthesize key, value;

- (id)initWithKey:(NSString*)newKey value:(NSString*)newValue {
	if (self = [super init]) {
		self.key = newKey;
		self.value = newValue;
	}
	return self;			
}

- (NSString*)description {
	NSString *ret = [NSString stringWithFormat:@"%@=%@", key, value];
	return ret;
}

- (void)dealloc {
	self.key = nil;
	self.value = nil;
	[super dealloc];
}

@end
