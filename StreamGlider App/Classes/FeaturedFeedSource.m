//
//  FeaturedFeedSource.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 18/08/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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

#import "FeaturedFeedSource.h"
#import "CacheController.h" 


@implementation FeaturedFeedSource

@synthesize imageURL, shouldReleaseImage, feedSource;

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		self.shouldReleaseImage = NO;
	}
	
	return self;
}

- (void)dealloc {
	self.imageURL = nil;
	self.feedSource = nil;
	
	if (shouldReleaseImage)
		[[CacheController sharedInstance] releaseImage:imageURL];
	
	[super dealloc];
}

@end
