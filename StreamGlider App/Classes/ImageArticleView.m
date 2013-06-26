//
//  ImageArticleView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 16/11/2011.
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

#import "ImageArticleView.h"
#import "ImageArticleViewController.h"

@implementation ImageArticleView

@synthesize viewController;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = viewController.titleLabel.frame;
    CGSize sz = [viewController.titleLabel sizeThatFits:r.size];
    r.size.height = sz.height;
    
    viewController.titleLabel.frame = r;
    
    CGFloat ah = self.frame.size.height - r.size.height - 15;
    CGFloat yPos = r.origin.y + r.size.height;
    
    r = viewController.imageView.frame;
    r.origin.y = yPos;
    r.size.height = ah;
    
    viewController.imageView.frame = r;
    viewController.ytOverlayView.frame = r;
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
