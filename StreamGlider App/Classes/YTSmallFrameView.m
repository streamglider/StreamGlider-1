//
//  YTSmallFrameView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 24/02/2011.
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

#import "YTSmallFrameView.h"
#import "YTSmallFrameViewController.h"
#import "HighlightedTextView.h"
#import "DogEarView.h"

#define GAP 10
#define TITLE_LABEL_FONT_SIZE 13
#define LOGO_IMAGE_WIDTH 35

@implementation YTSmallFrameView {
    int currentScale;
}

@synthesize viewController, titleLabelInsets;

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
	
	float w = self.frame.size.width;
	float k = w / FRAME_WIDTH;

	int newScale = ceil(k);
	newScale = MIN(3, newScale);
	
	if (newScale != currentScale) {
		currentScale = newScale;
		NSString *imgName;
		switch (currentScale) {
			case 1:
				imgName = @"MINI_VIDEO_ICON_40X30.png";
				break;
			case 2:
				imgName = @"MINI_VIDEO_ICON_80X60.png";				
				break;
			default:
				imgName = @"MINI_VIDEO_ICON_120X90.png";				
				break;	
		}
		viewController.logoImage.image = [UIImage imageNamed:imgName];
	}
	
	YTSmallFrameViewController *vc = viewController;
    
	vc.titleLabel.insets = UIEdgeInsetsMake(titleLabelInsets.top * k, 
											titleLabelInsets.left * k, 
											titleLabelInsets.bottom * k, 
											titleLabelInsets.right * k);
	
	vc.titleLabel.fontSize = k * TITLE_LABEL_FONT_SIZE;
}

#pragma mark Lifecycle

- (void)dealloc {
    [super dealloc];
}


@end
