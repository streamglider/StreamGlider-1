//
//  RSSSmallFrameView.m
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

#import "RSSSmallFrameView.h"
#import "RSSSmallFrameViewController.h"
#import "DogEarView.h"
#import "HighlightedTextView.h"

#define TITLE_VIEW_WIDTH 210
#define TITLE_VIEW_HEIGHT 110
#define GAP 10

#define FEED_TITLE_FONT_SIZE 14
#define FEED_TITLE_VIEW_HEIGHT 30
#define TITLE_VIEW_FONT_SIZE 20

#define IMAGE_PANEL_HEIGHT 59

#define IMAGE_TITLE_VIEW_HEIGHT 40
#define IMAGE_TITLE_VIEW_WIDTH 220
#define IMAGE_FEED_TITLE_VIEW_HEIGHT 25

#define IMAGE_FEED_TITLE_FONT_SIZE 11
#define IMAGE_TITLE_VIEW_FONT_SIZE 13

@implementation RSSSmallFrameView {
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
	
	RSSSmallFrameViewController *vc = viewController;
	int newScale = ceil(k);
	newScale = MIN(3, newScale);
	
	if (newScale != currentScale) {
		currentScale = newScale;
		NSString *imgName = @"";
		switch (currentScale) {
			case 1:
				imgName = @"NEWS_CARD_BG_X1_220x155.png";
				break;
			case 2:
				imgName = @"NEWS_CARD_BG_X2_440x310.png";				
				break;
			case 3:
				imgName = @"NEWS_CARD_BG_X3_660x465.png";				
				break;	
		}
		vc.backImage.image = [UIImage imageNamed:imgName];
	}	
	
	if (!vc.hasImage) {	
		vc.titleView.frame = CGRectMake(0, 0, TITLE_VIEW_WIDTH * k, TITLE_VIEW_HEIGHT * k);
		
		CGRect rect = vc.feedTitleView.frame;
			
		float lw = 	w - k * GAP - vc.dogEarView.frame.size.width;
		rect.size.width = lw;
		rect.size.height = FEED_TITLE_VIEW_HEIGHT * k;
		rect.origin.x = 0;
		rect.origin.y = h - k * GAP - rect.size.height;
		
		vc.feedTitleView.frame = rect;
				
		vc.titleView.fontSize = k * TITLE_VIEW_FONT_SIZE;
		vc.feedTitleView.fontSize = k * FEED_TITLE_FONT_SIZE;		
		
		vc.titleView.insets = UIEdgeInsetsMake(5 * k, 10 * k, 5 * k, 5 * k);
		vc.feedTitleView.insets = UIEdgeInsetsMake(5 * k, 10 * k, 5 * k, 5 * k);
	} else {
		CGRect rect = vc.imagePanel.frame;
		rect.size.height = IMAGE_PANEL_HEIGHT * k;
		rect.origin.y = h - rect.size.height;
		
		vc.imagePanel.frame = rect;
		
		// configure title view
		rect = vc.imageTitleView.frame;
		rect.size.width = IMAGE_TITLE_VIEW_WIDTH * k;
		rect.size.height = IMAGE_TITLE_VIEW_HEIGHT *k;
		vc.imageTitleView.frame = rect;
		vc.imageTitleView.fontSize = IMAGE_TITLE_VIEW_FONT_SIZE * k;
		vc.imageTitleView.insets = UIEdgeInsetsMake(k * 3, k * 10, k * 3, k * 3);
		
		// configure feed title view
		rect.origin.y = rect.size.height;
		rect.size.height = IMAGE_FEED_TITLE_VIEW_HEIGHT * k;
		vc.imageFeedTitleView.frame = rect;
		vc.imageFeedTitleView.fontSize = IMAGE_FEED_TITLE_FONT_SIZE * k;
		vc.imageFeedTitleView.insets = vc.imageTitleView.insets;		
	}
}

@end
