//
//  FBFrame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/09/2010.
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

#import "FBFrame.h"
#import "CacheController.h"


@implementation FBFrame

@synthesize userName, createdTime, userPictureURL, message;

#pragma mark Image Paths

- (NSArray*)getImagePaths {
	return [NSArray arrayWithObjects:self.imageURL, self.thumbURL, userPictureURL, nil];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	self.userName = [aDecoder decodeObjectForKey:@"userName"];
	self.createdTime = [aDecoder decodeObjectForKey:@"createdTime"];
		
	self.userPictureURL = [aDecoder decodeObjectForKey:@"userPictureURL"];
	self.message = [aDecoder decodeObjectForKey:@"message"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:userName forKey:@"userName"];
	[aCoder encodeObject:createdTime forKey:@"createdTime"];
	[aCoder encodeObject:userPictureURL forKey:@"userPictureURL"];
	[aCoder encodeObject:message forKey:@"message"];
}

#pragma mark Lifecycle

- (NSString*)description {
	if (message != nil)
		return message;
	else 
		return @"Facebook Frame";	
}

- (void)dealloc {
	self.userName = nil;
	self.createdTime = nil;
	
	[[CacheController sharedInstance] releaseImage:userPictureURL];
	
	self.userPictureURL = nil;
	self.message = nil;
	
	[super dealloc];
}

@end
