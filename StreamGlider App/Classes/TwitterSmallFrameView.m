//
//  TwitterSmallFrameView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 24/02/2011.
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

#import "TwitterSmallFrameView.h"
#import "TwitterSmallFrameViewController.h"
#import "HighlightedTextView.h"
#import "DogEarView.h"

#define TEXT_VIEW_WIDTH 200
#define TEXT_VIEW_HEIGHT 95
#define MARGIN 10
#define GAP 10

#define USER_NAME_FONT_SIZE 14
#define TEXT_VIEW_FONT_SIZE 15

@implementation TwitterSmallFrameView {
    int currentScale;
}

@synthesize viewController;

#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float h = self.frame.size.height;
	float w = self.frame.size.width;
	float k = w / FRAME_WIDTH;
		
	TwitterSmallFrameViewController *vc = viewController;
	
	int newScale = ceil(k);
	newScale = MIN(3, newScale);
	
	if (newScale != currentScale) {
		currentScale = newScale;
		NSString *imgName = @"";
		switch (currentScale) {
			case 1:
				imgName = @"TWEET_CARD_BG_X1.png";
				break;
			case 2:
				imgName = @"TWEET_CARD_BG_X2.png";				
				break;
			case 3:
				imgName = @"TWEET_CARD_BG_X3.png";				
				break;	
		}
		vc.backImage.image = [UIImage imageNamed:imgName];
	}
	
	vc.textView.frame = CGRectMake(MARGIN * k, MARGIN * k, TEXT_VIEW_WIDTH * k, TEXT_VIEW_HEIGHT * k);
	
	CGRect rect = vc.profileImage.frame;
	rect.origin.x = MARGIN * k;
	rect.origin.y = h - rect.size.height - MARGIN * k;
	
	vc.profileImage.frame = rect;
	
	float lw = 	w - rect.origin.x - rect.size.width - 2 * k * GAP - vc.dogEarView.frame.size.width;
	vc.userNameLabel.frame = CGRectMake(rect.origin.x + rect.size.width + k * GAP, 
										rect.origin.y, 
										lw, 
										rect.size.height);
	
	vc.textView.fontSize = k * TEXT_VIEW_FONT_SIZE;
	vc.userNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:k * USER_NAME_FONT_SIZE];
}

#pragma mark Lifecycle

- (void)dealloc {
    [super dealloc];
}


@end
