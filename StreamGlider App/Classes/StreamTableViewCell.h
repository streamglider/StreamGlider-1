//
//  StreamTableViewCell.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/21/10.
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

#import <UIKit/UIKit.h>
#import "StreamDelegate.h"

@class Stream;
@class StreamCastViewController;

@interface StreamTableViewCell : UITableViewCell <StreamDelegate, UIScrollViewDelegate>
	
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign, setter=setStream:) Stream *stream;
@property (nonatomic, retain) UIPopoverController *sharePopover;
@property (nonatomic, retain) NSMutableArray *frameControllers;
@property (nonatomic, assign) StreamCastViewController *streamCastViewController;
@property (nonatomic, assign) int zoomingFrameIndex;
@property (nonatomic, assign) int zoomingFrameOffset;
@property (nonatomic) BOOL animate;

- (void)releaseFrames;

- (int)frameIndexForPoint:(CGPoint)pt;

@end
