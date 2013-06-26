//
//  TwitterLEView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 15/11/2011.
//  Copyright (c) 2011 StreamGlider, Inc. All rights reserved.
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

#import "TwitterLEView.h"
#import "TwitterLEViewController.h"

@implementation TwitterLEView

@synthesize viewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sSize = [viewController.statusLabel sizeThatFits:viewController.statusLabel.frame.size];
    CGFloat statusHeight = MAX(33, sSize.height);
    size.height = 9 + viewController.userNameLabel.frame.size.height + statusHeight + viewController.dateLabel.frame.size.height;
    
    return size;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect r = viewController.dateLabel.frame;
    
    r.origin.y = viewController.statusLabel.frame.size.height + viewController.statusLabel.frame.origin.y + 3;
    
    viewController.dateLabel.frame = r;
}

- (void)dealloc {
    [super dealloc];
}
@end
