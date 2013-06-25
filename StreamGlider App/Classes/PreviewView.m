//
//  PreviewView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 03/12/2010.
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

#import "PreviewView.h"
#import "PreviewViewController.h"
#import "SettingsController.h"


@implementation PreviewView

@synthesize viewController;

#pragma mark UIView

- (void)layoutSubviews {	
	[super layoutSubviews];

	CGRect rect = viewController.panelView.frame;

    if (viewController.magMode) {
        rect.size = CGSizeMake(668, 620);
        viewController.panelView.frame = rect;
        viewController.panelView.center = self.center;        
    } else {    
        rect.origin = viewController.firstFrameRect.origin;
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            rect.origin.x += FRAME_WIDTH + FRAMES_GAP; 
        } else {
            rect.origin.y += CELL_HEIGHT;
        }
        CGFloat panelWidth = self.frame.size.width - rect.origin.x;        
        CGFloat panelHeight = self.frame.size.height - rect.origin.y;        
        rect.size = CGSizeMake(panelWidth, panelHeight);
        
        viewController.panelView.frame = rect;
    }
}

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
