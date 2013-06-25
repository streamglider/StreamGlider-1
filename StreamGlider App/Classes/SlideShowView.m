//
//  SlideShowView.m
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

#import "SlideShowView.h"
#import "SlideShowViewController.h"


@implementation SlideShowView

@synthesize viewController, dontDoLayout;

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
	
	if (!dontDoLayout) {	
		CGSize s = CGSizeMake(self.frame.size.width * 3, viewController.scrollView.frame.size.height);
		viewController.scrollView.contentSize = s;
		
		viewController.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
		
		viewController.currentView.frame = CGRectMake(self.frame.size.width, 0, 
													  self.frame.size.width, 
													  viewController.scrollView.frame.size.height);
		self.dontDoLayout = YES;
	}
}


#pragma mark Lifecycle

- (void)dealloc {
    [super dealloc];
}


@end
