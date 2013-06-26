//
//  SlideShowView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 07/04/2011.
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
