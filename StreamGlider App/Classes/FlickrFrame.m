//
//  FlickrFrame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 04/10/2010.
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

#import "FlickrFrame.h"
#import "CacheController.h"


@implementation FlickrFrame

@synthesize title, userName, dateUpload, secondaryImageURL;

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
			
	self.title = [aDecoder decodeObjectForKey:@"title"];
	self.userName = [aDecoder decodeObjectForKey:@"userName"];
	self.dateUpload = [aDecoder decodeObjectForKey:@"dateUpload"];	
	self.secondaryImageURL = [aDecoder decodeObjectForKey:@"secondaryImageURL"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];		
	[aCoder encodeObject:title forKey:@"title"];	
	[aCoder encodeObject:userName forKey:@"userName"];
	[aCoder encodeObject:dateUpload forKey:@"dateUpload"];	
	[aCoder encodeObject:secondaryImageURL forKey:@"secondaryImageURL"];
}

#pragma mark Lifecycle

- (NSString*)description {
	return title;
}

- (void)dealloc {	
	self.title = nil;
	self.userName = nil;
	self.dateUpload = nil;
	self.secondaryImageURL = nil;
		
	[super dealloc];
}

@end
