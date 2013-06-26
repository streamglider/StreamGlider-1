//
//  SettingsController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 05/05/2011.
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

#import "SettingsController.h"

@interface SettingsController () 

@property (nonatomic, retain) NSDictionary *delegates;

@end

@implementation SettingsController

// ni prefix means "new indicator"
@synthesize removeViewedFrames, niColors, niCurrentColor, 
	niColorNames, niColorImages, delegates, cardsInterval, grayOutViewedFrames, plusMode,
    paginateFeeds;

#define REMOVE_VIEWED_FRAMES @"remove_viewed_frames_pref"
#define PAGINATE_FEEDS @"paginate_feeds_pref"
#define NEW_INDICATOR_COLOR @"new_indicator_color_pref"
#define CARDS_INTERVAL @"cards_interval_pref"
#define GRAY_OUT_VIEWED_FRAMES @"gray_out_viewed_frames_pref"
#define PLUS_MODE @"plus_mode_pref"


#pragma mark Delegates

- (void)addDelegate:(id<SettingsDelegate>)delegate forProperty:(SettingsPropertyType)property {
	NSMutableArray *arr = [delegates objectForKey:[NSNumber numberWithInt:property]];
	[arr addObject:delegate];
}

- (void)removeDelegate:(id<SettingsDelegate>)delegate property:(SettingsPropertyType)property {
	NSMutableArray *arr = [delegates objectForKey:[NSNumber numberWithInt:property]];
	[arr removeObject:delegate];
}

- (void)firePropertyChanged:(SettingsPropertyType)property oldValue:(NSObject*)oldValue newValue:(NSObject*)newValue {
	NSMutableArray *arr = [delegates objectForKey:[NSNumber numberWithInt:property]];
	for (id<SettingsDelegate> delegate in arr) {
		[delegate propertyChanged:property 
						 oldValue:oldValue 
						 newValue:newValue];
	}
}

#pragma mark Properties

- (void)setPlusMode:(BOOL)val {
	if (plusMode != val) {
		plusMode = val;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		[defaults setBool:plusMode forKey:PLUS_MODE];
		[defaults synchronize];		
		
		[self firePropertyChanged:SettingsPropertyTypePlusMode 
						 oldValue:[NSNumber numberWithBool:!plusMode] 
						 newValue:[NSNumber numberWithBool:plusMode]];
	}
}

- (void)setGrayOutViewedFrames:(BOOL)val {
	if (grayOutViewedFrames != val) {
		grayOutViewedFrames = val;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		[defaults setBool:grayOutViewedFrames forKey:GRAY_OUT_VIEWED_FRAMES];
		[defaults synchronize];		
		
		[self firePropertyChanged:SettingsPropertyTypeGrayOutViewedFrames 
						 oldValue:[NSNumber numberWithBool:!grayOutViewedFrames] 
						 newValue:[NSNumber numberWithBool:grayOutViewedFrames]];
	}
}

- (void)setRemoveViewedFrames:(BOOL)val {
	if (removeViewedFrames != val) {
		removeViewedFrames = val;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		[defaults setBool:removeViewedFrames forKey:REMOVE_VIEWED_FRAMES];
		[defaults synchronize];
	}
}

- (void)setPaginateFeeds:(BOOL)val {
	if (paginateFeeds != val) {
		paginateFeeds = val;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:paginateFeeds forKey:PAGINATE_FEEDS];
		[defaults synchronize];
	}
}


- (void)setNiCurrentColor:(int)val {
	if (niCurrentColor != val) {
		int oldVal = niCurrentColor;
		niCurrentColor = val;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		[defaults setInteger:niCurrentColor forKey:NEW_INDICATOR_COLOR];
		[defaults synchronize];
		
		[self firePropertyChanged:SettingsPropertyTypeNewIndicatorColor 
						 oldValue:[NSNumber numberWithInt:oldVal] 
						 newValue:[NSNumber numberWithInt:niCurrentColor]];
	}
}

- (void)setCardsInterval:(int)val {
	if (cardsInterval != val) {
		int oldVal = cardsInterval;
		cardsInterval = val;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		[defaults setInteger:cardsInterval forKey:CARDS_INTERVAL];
		[defaults synchronize];		
		
		[self firePropertyChanged:SettingsPropertyTypeCardsInterval 
						 oldValue:[NSNumber numberWithInt:oldVal] 
						 newValue:[NSNumber numberWithInt:cardsInterval]];
	}
}

#pragma mark Singleton

static SettingsController* instance = nil;

+ (SettingsController*)sharedInstance {
	if (instance == nil) {
		instance = [[SettingsController alloc] init];
	}
	return instance;
}

#pragma mark Lifecycle

- (void)readDefaults {	
	// read settings from the settings DB
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	removeViewedFrames = [defaults boolForKey:REMOVE_VIEWED_FRAMES];					
	
	niCurrentColor = [defaults integerForKey:NEW_INDICATOR_COLOR];
	
	cardsInterval = [defaults integerForKey:CARDS_INTERVAL];
	if (cardsInterval == 0)
		cardsInterval = 5;
	
	grayOutViewedFrames = [defaults boolForKey:GRAY_OUT_VIEWED_FRAMES];
    paginateFeeds = [defaults boolForKey:PAGINATE_FEEDS];
	plusMode = [defaults boolForKey:PLUS_MODE];
}

- (void)storeDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setBool:NO forKey:REMOVE_VIEWED_FRAMES];
    [defaults setBool:YES forKey:PAGINATE_FEEDS];
	[defaults setBool:YES forKey:GRAY_OUT_VIEWED_FRAMES];
	[defaults setInteger:5 forKey:NEW_INDICATOR_COLOR];
	[defaults setInteger:5 forKey:CARDS_INTERVAL];
	[defaults setBool:YES forKey:PLUS_MODE];
	[defaults synchronize];
	
	[self readDefaults];
}

- (id)init {
	if (self = [super init]) {
		// init delegates dictionary
		NSMutableArray *d = [[NSMutableArray alloc] init];
		NSMutableArray *d1 = [[NSMutableArray alloc] init];
		NSMutableArray *d2 = [[NSMutableArray alloc] init];
		NSMutableArray *d3 = [[NSMutableArray alloc] init];
		
		self.delegates = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:d, d1, d2, d3, nil] 
													 forKeys:[NSArray arrayWithObjects:
															  [NSNumber numberWithInt:SettingsPropertyTypeNewIndicatorColor],
															  [NSNumber numberWithInt:SettingsPropertyTypeCardsInterval],
															  [NSNumber numberWithInt:SettingsPropertyTypeGrayOutViewedFrames],
															  [NSNumber numberWithInt:SettingsPropertyTypePlusMode],
															  nil]];
		[d release];
		[d1 release];
		[d2 release];
		[d3 release];
		
		self.niColors = [NSArray arrayWithObjects:
								   [UIColor yellowColor],
								   [UIColor colorWithRed:0 green:1 blue:1 alpha:1],
								   [UIColor greenColor],
								   [UIColor colorWithRed:1 green:0 blue:1 alpha:1],
								   [UIColor redColor],
								   [UIColor clearColor],
								   nil];
		
		self.niColorNames = [NSArray arrayWithObjects: 
									   @"Yellow", 
									   @"Blue",
									   @"Green",
									   @"Pink",
									   @"Red",
									   @"Don't show the \"New\" indicator",
									   nil];
		
		// new indicator color images
		NSArray *imgNamesArr = [NSArray arrayWithObjects:NEW_INDICATOR_IMAGES];
		NSMutableArray *imgArr = [[NSMutableArray alloc] initWithCapacity:[imgNamesArr count]];
		for (NSString *imgName in imgNamesArr) {
			[imgArr addObject:[UIImage imageNamed:imgName]];
		}
		
		self.niColorImages = [NSArray arrayWithArray:imgArr];
		[imgArr release];
		[self readDefaults];
	}
	return self;
}

- (void)dealloc {
	self.delegates = nil;
	self.niColors = nil;
	self.niColorNames = nil;
	self.niColorImages = nil;
	
	[super dealloc];
}

@end
