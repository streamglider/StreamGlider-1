//
//  FrameView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 07/04/2011.
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

#import "FrameView.h"
#import "SmallFrameFactory.h"
#import "SmallFrameViewController.h"
#import "DogEarView.h"
#import "Core.h"
#import "Frame.h"



@implementation FrameView

@synthesize theFrame, frameController, streamCastViewController;

#pragma mark Properties

- (void)setTheFrame:(Frame*)f {
	[theFrame release];
	theFrame = [f retain];
	
	if (f == nil)
		return;
	
	// create small frame view controller
	self.frameController = [SmallFrameFactory createSmallFrameViewFor:theFrame];
	
	frameController.showThumbnail = NO;

	frameController.doubleTapAction = @selector(displayBrowserForFrame:);
	frameController.doubleTapTarget = streamCastViewController;
	
	frameController.tapAction = @selector(displaySourceBarHandler:);
	frameController.target = frameController;
	
	[self addSubview:frameController.view];					
	frameController.dogEarView.isNew = [[Core sharedInstance] isFrameNew:f.URLString];
	
	[frameController hideSourceBarWithAnimation:NO];
}

#pragma mark UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float h = self.frame.size.height;
	float w = self.frame.size.width;
	float k = MIN(h / (float)FRAME_HEIGHT, w / (float)FRAME_WIDTH);
	
	int frameH = FRAME_HEIGHT * k;
	int frameW = FRAME_WIDTH * k;
	
	int yPos = (h - frameH) / 2;
	int xPos = (w - frameW) / 2;
	
	CGRect rect = CGRectMake(xPos, yPos, frameW, frameH);	
	
	frameController.view.frame = rect;
}

- (id)initWithFrame:(CGRect)f {
    self = [super initWithFrame:f];
    if (self) {
        // Initialization code.
    }
    return self;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.theFrame = nil;
	self.frameController = nil;
    [super dealloc];
}


@end
