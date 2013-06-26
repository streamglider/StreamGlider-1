//
//  StreamCastStateController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 17/12/2010.
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

typedef enum {
	StreamLayoutTable,
	StreamLayoutSlideshow,
	StreamLayoutCombined,
	StreamLayoutPreview,
	StreamLayoutBrowser,
	StreamLayoutEditing
} MainScreenLayoutType;

@class StreamCastViewController;
@class SmallFrameViewController;

@interface StreamCastStateController : NSObject 

@property (nonatomic, assign) StreamCastViewController *streamCastViewController;
@property (nonatomic, assign, setter=setIsPlaying:) BOOL isPlaying;
@property (nonatomic, assign) MainScreenLayoutType currentState;
@property (assign) BOOL animationInProgress;
@property (nonatomic, assign) UIView *animateView;
@property (nonatomic, assign) CGRect animateRect;

+ (StreamCastStateController*)sharedInstance;

- (void)switchToState:(MainScreenLayoutType)state;
- (void)exitBrowser;
- (void)exitPreview;
- (void)exitEditing;

@end
