//
//  WebBackgroundLabelView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 24/11/2011.
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

#import "WebBackgroundLabelView.h"
#import "WebBackgroundLabelViewController.h"

@implementation WebBackgroundLabelView

- (CGSize)sizeThatFits:(CGSize)size {
    WebBackgroundLabelViewController *viewController = (WebBackgroundLabelViewController*)[self nextResponder];
    
    CGFloat w = [viewController.titleLabel sizeThatFits:CGSizeZero].width;
        
    w = MAX(131, w);
    w = MIN(w, 300);
    return CGSizeMake(w + 10, 29);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
