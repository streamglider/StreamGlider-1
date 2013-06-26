//
//  FeaturedFeedsLoader.m
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

#import "FeaturedFeedsLoader.h"
#import "APIReader.h"
#import "Core.h"
#import "CacheController.h"
#import "FeaturedFeedSource.h"
#import "FeedSource.h"
#import "FeedFactory.h"

@implementation FeaturedFeedsLoader

#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
    
#ifdef DEBUG_MODE    
	NSDate *start = [NSDate date];
#endif    
	
	// parse response
	NSMutableArray *ffeeds = [[NSMutableArray alloc] init];
	for (NSDictionary *entry in ((NSArray*)data)) {
		NSDictionary *ff = [entry objectForKey:@"featured_feed"];
		FeaturedFeedSource *ffs = [[FeaturedFeedSource alloc] init];
		
		ffs.feedSource = [[[FeedSource alloc] init] autorelease]; 
		
		ffs.imageURL = [NSString stringWithFormat:@"%@%@", API_V2_URL, [ff objectForKey:@"logo_url"]];
		ffs.imageURL = [[CacheController sharedInstance] storeImageData:ffs.imageURL withThumb:NO];
		ffs.shouldReleaseImage = YES;
		
		NSDictionary *feed = [ff objectForKey:@"feed"];
		ffs.feedSource.title = [feed objectForKey:@"title"];
		ffs.feedSource.URLString = [feed objectForKey:@"url"];
		NSString *t = [ff objectForKey:@"feed_type"];
		ffs.feedSource.type = [FeedFactory typeForStringName:t];
		
		[ffeeds addObject:ffs];
		[ffs release];
	}
		
	[Core sharedInstance].featuredFeeds = [ffeeds autorelease];
	
	[reader release];
	
#ifdef DEBUG_MODE    
	NSDate *finish = [NSDate date];
	NSTimeInterval elapsed = [finish timeIntervalSinceDate:start];
	DebugLog(@"elapsed time: %f", elapsed);
#endif
    
}

- (void)apiLoadFailed:(APIReader*)reader {	
    //TODO: populate featured feeds statically
	[reader release];
}

#pragma mark Loading

- (void)loadFeaturedFeeds {
	APIReader *reader = [[APIReader alloc] init];
	reader.delegate = self;
	
	[reader performSelectorInBackground:@selector(loadAPIDataFor:) withObject:@"featured_feeds.json"];	
}

@end
