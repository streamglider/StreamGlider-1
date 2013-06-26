//
//  Frame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/15/10.
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

#import "Frame.h"
#import "CacheController.h"
#import "Feed.h"
#import "Core.h"


@implementation Frame

@synthesize feed, URLString, imageURL, thumbURL, frameIsReady, frameWasShown;

#pragma mark Image Paths

- (NSArray*)getImagePaths {
	return [NSArray arrayWithObjects:imageURL, thumbURL, nil];
}

- (NSArray*)getResourcePaths {
	return [NSArray array];
}

#pragma mark Date Formatting

+ (NSString*)formatDate:(NSDate*)date {
	
#define MINUTE 60
#define HOUR 3600
#define DAY 86400
	
	NSTimeInterval interval = abs([date timeIntervalSinceNow]);
	
	if (interval < 2 * MINUTE) {
		// about one minute ago
		return @"1 minute ago";
	} else if (interval < HOUR) {
		// number of minutes ago
		int minutes = interval / MINUTE;
		return [NSString stringWithFormat:@"%d minutes ago", minutes];
	} else if (interval < DAY) {
		// about <number of hours> ago
		int hours = interval / HOUR;
		int rem = ((long)interval) % HOUR;
		if (rem > (HOUR / 2)) {
			hours++;
		}
		if (hours == 1)
			return @"about 1 hour ago";
		else 
			return [NSString stringWithFormat:@"about %d hours ago", hours];
	} else {
		// exact date
		NSDate *now = [NSDate date];
		
		// create Gregorian calendar
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		
		NSDateComponents *nowComps = [gregorian components:(NSYearCalendarUnit | NSDayCalendarUnit) fromDate:now];
		NSDateComponents *dateComps = [gregorian components:(NSYearCalendarUnit | NSDayCalendarUnit) fromDate:date];
		
		[gregorian release];
		
		// add year data only if year is different from current
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"h:mm a MMM d"];						
		
		NSMutableString *ret = [NSMutableString stringWithString:[formatter stringFromDate:date]];
		[formatter release];
		
		// add suffix to day component
		int day = [dateComps day];
		int ending = day % 10;
		NSString *suffix = @"th";
		switch (ending) {
			case 1:
				if (day != 11)
					suffix = @"st";
				break;
			case 2:
				if (day != 12)
					suffix = @"nd";
				break;
			case 3:
				if (day != 13)
					suffix = @"rd";
				break;
		}
		
		[ret appendString:suffix];
		
		if ([nowComps year] != [dateComps year]) {
			// add year component
			[ret appendFormat:@", %d", [dateComps year]];
		} 
		
		return [NSString stringWithString:ret];
	}	
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	self.URLString = [aDecoder decodeObjectForKey:@"URLString"];
	
	// find feed using object ID
	NSString *feedID = [aDecoder decodeObjectForKey:@"feedID"];
	
	self.feed = [[CacheController sharedInstance] findFeed:feedID];
	
	self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
	self.thumbURL = [aDecoder decodeObjectForKey:@"thumbURL"];
	self.frameIsReady = [aDecoder decodeBoolForKey:@"frameIsReady"];
	
	// mark all deserialized frames as read
	[[Core sharedInstance] isFrameNew:URLString];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:URLString forKey:@"URLString"];
	[aCoder encodeObject:feed.objectID forKey:@"feedID"];
	[aCoder encodeObject:imageURL forKey:@"imageURL"];
	[aCoder encodeObject:thumbURL forKey:@"thumbURL"];
	[aCoder encodeBool:frameIsReady forKey:@"frameIsReady"];
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		self.frameIsReady = NO;
	}
	
	return self;
}

- (void)dealloc {	
	[[CacheController sharedInstance] releaseImage:self.imageURL];
	[[CacheController sharedInstance] releaseImage:self.thumbURL];
		
	self.imageURL = nil;
	self.thumbURL = nil;
	DebugLog(@"dealloc for frame: %@", [self class]);
	
	[super dealloc];
}

@end
