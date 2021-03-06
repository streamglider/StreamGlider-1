//
//  SettingsController.h
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

#import <Foundation/Foundation.h>
#import "SettingsDelegate.h"

#define NEW_INDICATOR_IMAGES @"settings_new_yellow.png", @"settings_new_blue.png", @"settings_new_green.png", @"settings_new_pink.png", @"settings_new_red.png", @"settings_new_white.png", nil

@interface SettingsController : NSObject 

@property (nonatomic, assign, setter = setRemoveViewedFrames:) BOOL removeViewedFrames;

@property (nonatomic, retain) NSArray *niColors;
@property (nonatomic, retain) NSArray *niColorNames;
@property (nonatomic, retain) NSArray *niColorImages;
@property (nonatomic, assign, setter = setNiCurrentColor:) int niCurrentColor;

@property (nonatomic, assign, setter = setCardsInterval:) int cardsInterval;

@property (nonatomic, assign, setter = setGrayOutViewedFrames:) BOOL grayOutViewedFrames;

@property (nonatomic, assign, setter = setPlusMode:) BOOL plusMode;

@property (nonatomic, assign, setter = setPaginateFeeds:) BOOL paginateFeeds;


+ (SettingsController*)sharedInstance;

- (void)addDelegate:(id<SettingsDelegate>)delegate forProperty:(SettingsPropertyType)property;
- (void)removeDelegate:(id<SettingsDelegate>)delegate property:(SettingsPropertyType)property;

- (void)storeDefaults;

@end
