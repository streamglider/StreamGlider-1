//
//  ObjectWithID.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 13/10/2010.
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

#import "ObjectWithID.h"


@implementation ObjectWithID

@synthesize objectID;

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [self init];	
	self.objectID = [aDecoder decodeObjectForKey:@"objectID"];	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[aCoder encodeObject:objectID forKey:@"objectID"];
}

#pragma mark ID

- (void)generateID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	//get the string representation of the UUID
	objectID = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		// generate random ID
		[self generateID];		
	}
	return self;
}

- (void)dealloc {
	[objectID release];
	[super dealloc];
}

@end
