//
//  StreamCastStateController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 17/12/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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
