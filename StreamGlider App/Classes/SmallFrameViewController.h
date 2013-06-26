//
//  SmallFrameController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 30/07/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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

#import <UIKit/UIKit.h>
#import "FrameViewController.h"

@class DogEarView;

@interface SmallFrameViewController : FrameViewController 

@property (nonatomic, retain) IBOutlet DogEarView *dogEarView;
@property (nonatomic, retain) UIImageView *contentImage;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL tapAction;

@property (nonatomic, assign) id doubleTapTarget;
@property (nonatomic, assign) SEL doubleTapAction;

@property (nonatomic, setter=setZooming:) BOOL zooming;

@property (nonatomic, retain) IBOutlet UIView *grayView;

@property (assign) BOOL sourceBarIsHidden;

- (void)grayOut;
- (void)cancelGrayOut;

- (void)hideSourceBarWithAnimation:(BOOL)animated;
- (void)displaySourceBarHandler:(Frame*)f;

@end
