//
//  DogEarView.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 29/12/2010.
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
#import "SettingsDelegate.h"

@class SmallFrameViewController;

@interface DogEarView : UIView <SettingsDelegate> 

@property (nonatomic, assign, setter = setViewed:) BOOL viewed;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, assign) SmallFrameViewController *viewController;

- (void)attachSettingsDelegate;
- (void)detachSettingsDelegate;

@end
