//
//  TwitterFrame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/21/10.
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

#import "TwitterFrame.h"

@implementation TwitterFrame

@synthesize text, createdAt, userName, statusId;

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	self.text = [aDecoder decodeObjectForKey:@"text"];
	self.createdAt = [aDecoder decodeObjectForKey:@"createdAt"];
	self.userName = [aDecoder decodeObjectForKey:@"userName"];
	self.statusId = [aDecoder decodeObjectForKey:@"statusId"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:text forKey:@"text"];
	[aCoder encodeObject:createdAt forKey:@"createdAt"];
	[aCoder encodeObject:userName forKey:@"userName"];
	[aCoder encodeObject:statusId forKey:@"statusId"];
}

#pragma mark Lifecycle

- (NSString*)description {
	return [NSString stringWithFormat:@"%@: %@", userName, text];
}

- (void)dealloc {	
	self.text = nil;
	self.createdAt = nil;
	self.userName = nil;
	self.statusId = nil;
	
	[super dealloc];	
}

@end
