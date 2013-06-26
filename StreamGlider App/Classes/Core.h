//
//  Core.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/16/10.
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

#import <Foundation/Foundation.h>
#import "CoreDelegate.h"
#import "StreamDelegate.h"
#import "SettingsDelegate.h"

@class Stream;
@class FeedSource;
@class BrowserViewController;
@class SmallFrameViewController;
@class FeedSourceCategory;
@class PageOfStreams;

@interface Core : NSObject <StreamDelegate, SettingsDelegate> 

@property (nonatomic, assign) NSMutableArray *streams;
@property (nonatomic, retain) NSMutableArray *pages;

@property (nonatomic, assign) BOOL isPaused;

@property (nonatomic, retain) BrowserViewController *browserViewController;

@property (nonatomic, retain) FeedSourceCategory *rootCategory;

@property (nonatomic, retain) UIImage *cardImage;

@property (nonatomic, retain) NSArray *featuredFeeds;

// user api token and email with the SG system
@property (nonatomic, copy, setter = setApiToken:, getter = getApiToken) NSString *apiToken;
@property (nonatomic, copy, setter = setUserEmail:, getter = getUserEmail) NSString *userEmail;

+ (Core*)sharedInstance;

// streams
- (void)addStream:(Stream*)stream skipStoring:(BOOL)skipStoring;
- (void)removeStream:(Stream*)stream;
- (void)moveStream:(Stream*)stream fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

// pages
- (void)addPage:(PageOfStreams*)page makeActive:(BOOL)makeActive;
- (void)removePage:(PageOfStreams*)page;
- (void)setActivePage:(PageOfStreams*)page;
- (PageOfStreams*)getActivePage;

// feed sources
- (void)addSource:(FeedSource*)source;
- (void)removeSource:(FeedSource*)source;

// delegates
- (void)addCoreDelegate:(id<CoreDelegate>)delegate;
- (void)removeCoreDelegate:(id<CoreDelegate>)delegate;

// pause / resume
- (void)togglePause;
- (void)pauseAllStreamsExcept:(Stream*)stream;
- (void)resumeAllStreams;
- (void)pauseAllStreams;

// image paths
- (NSArray*)getImagePaths;
- (NSArray*)getResourcePaths;

// viewed frames
- (BOOL)frameWasViewed:(SmallFrameViewController*)viewController;
- (void)viewFrame:(NSString*)frameURL;
- (void)releaseFrameFromViewed:(SmallFrameViewController*)viewController;
- (void)removeAllFramesWithURL:(NSString*)frameURL;

// new frames
- (BOOL)isFrameNew:(NSString*)frameURL;
- (BOOL)isFrameDeleted:(NSString*)frameURL;

// timers
- (void)installTimers;
- (void)killTimers;

// cookies
+ (void)clearCookies:(NSURL*)url;

@end
