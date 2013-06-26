//
//  IncomingStreamsController.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 08/02/2012.
//  Copyright (c) 2012 StreamGlider, Inc. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "APIDelegate.h"

@class ButtonWithBadge;

@interface IncomingStreamsController : NSObject <APIDelegate>

@property (nonatomic, retain) NSMutableArray *addedStreams;

+ (IncomingStreamsController*)sharedInstance;

- (void)markAllViewed;
- (void)addBadgeButton:(ButtonWithBadge*)bb;
- (void)removeBadgeButton:(ButtonWithBadge*)bb;

- (void)pauseUpdating;
- (void)resumeUpdating;

@end
