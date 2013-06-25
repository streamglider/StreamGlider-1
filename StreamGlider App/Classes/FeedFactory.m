//
//  FeedFactory.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 18/08/2011.
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

#import "FeedFactory.h"
#import "RSSFeed.h"
#import "YTFeed.h"
#import "FBFeed.h"
#import "TwitterFeed.h"
#import "FlickrFeed.h"
#import "Feed.h"
#import "FeedSource.h"

@implementation FeedFactory

+ (Feed*)createFeedForSource:(FeedSource*)src {
	Feed *f;
	switch (src.type) {
		case FeedSourceTypeRSS:
			f = [[RSSFeed alloc] init];					
			break;
		case FeedSourceTypeFacebook:
			f = [[FBFeed alloc] init];					
			break;
		case FeedSourceTypeFlickr:
			f = [[FlickrFeed alloc] init];					
			break;
		case FeedSourceTypeTwitter:
			f = [[TwitterFeed alloc] init];					
			break;
		case FeedSourceTypeYouTube:
			f = [[YTFeed alloc] init];					
			break;
	}
	return [f autorelease];
}

+ (NSString*)stringNameForType:(FeedSourceType)type {
	NSString *ret;
	switch (type) {
		case FeedSourceTypeRSS:
			ret = @"RSS";					
			break;
		case FeedSourceTypeFacebook:
			ret = @"Facebook";					
			break;
		case FeedSourceTypeFlickr:
			ret = @"Flickr";					
			break;
		case FeedSourceTypeTwitter:
			ret = @"Twitter";					
			break;
		case FeedSourceTypeYouTube:
			ret = @"YouTube";					
			break;
	}
	return ret;
}


+ (FeedSourceType)typeForStringName:(NSString*)name {
	if ([name isEqualToString:@"Twitter"]) {
		return FeedSourceTypeTwitter;
	} else if ([name isEqualToString:@"YouTube"]) {
		return FeedSourceTypeYouTube;
	} else if ([name isEqualToString:@"Flickr"]) { 
		return FeedSourceTypeFlickr;
	} else if ([name isEqualToString:@"Facebook"]) {
		return FeedSourceTypeFacebook;
	} else { 
		return FeedSourceTypeRSS;
	}	
	return -1;
}


@end
