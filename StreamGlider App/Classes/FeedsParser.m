//
//  FeedsParser.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 17/08/2011.
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

#import "FeedsParser.h"
#import "FeedSource.h"
#import "FeedSourceCategory.h"
#import "FeedFactory.h"
#import "CacheController.h"


@implementation FeedsParser

- (FeedSource*)parseFeed:(NSDictionary*)f {
	FeedSource *feed = [[FeedSource alloc] init];
	feed.title = [f objectForKey:@"title"];
	feed.URLString = [f objectForKey:@"url"];
	NSString *t = [f objectForKey:@"feed_type"];
	feed.type = [FeedFactory typeForStringName:t];
	
	return [feed autorelease];
}

- (FeedSourceCategory*)parseCategory:(NSDictionary*)cat {
	FeedSourceCategory *fsc = [[FeedSourceCategory alloc] init];
	fsc.title = [cat objectForKey:@"title"];
    
	fsc.imageURL = [cat objectForKey:@"image_url"];
    if ([fsc.imageURL rangeOfString:@"missing.png"].location == NSNotFound) {
		fsc.imageURL = [NSString stringWithFormat:@"%@%@", API_V2_URL, fsc.imageURL];
		fsc.imageURL = [[CacheController sharedInstance] storeImageData:fsc.imageURL withThumb:NO];        
    } else {
        fsc.imageURL = nil;
    }
    
	for (NSDictionary *obj in [cat objectForKey:@"children"]) {
		NSObject *url = [obj objectForKey:@"url"];	
		if (url != nil) {
			FeedSource *fs = [self parseFeed:obj];
			[fsc addChild:fs];
			fs.category = fsc;
		} else {
			FeedSourceCategory *cc = [self parseCategory:obj];
			[fsc addChild:cc];
			cc.parentCategory = fsc;
		}
	}
	
	return [fsc autorelease];
}

- (FeedSourceCategory*)parseFeeds:(NSArray*)data {
	FeedSourceCategory *root = [[FeedSourceCategory alloc] init];
	root.title = @"Categories";
	
	for (NSDictionary* src in data) {
		FeedSourceCategory *cat = [self parseCategory:src];
		[root addChild:cat];
		cat.parentCategory = root;
	}
	
	return [root autorelease];
}

@end
