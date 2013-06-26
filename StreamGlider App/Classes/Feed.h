//
//  Feed.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/16/10.
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

#import <Foundation/Foundation.h>
#import "FeedDelegate.h"
#import "ObjectWithID.h"


@class Stream;
@class FeedSource;

@interface Feed : ObjectWithID <NSCopying> 
 
@property (nonatomic, copy, setter=setTitle:) NSString *title;
@property (nonatomic, assign) Stream* stream;

@property (nonatomic, retain) NSMutableArray *tempQueue;

@property (retain) NSArray *queue;

@property (nonatomic, retain, setter = setSource:) FeedSource *source;

@property BOOL loading;

@property (nonatomic, setter = setEditing:) BOOL editing; 

@property (nonatomic) int currentFrameIndex;

@property (assign) BOOL stopComplimenting;

- (void)loadNewFrames; 

- (void)performLoadInBackground;

- (void)loadWasFinished;

- (void)addFeedDelegate:(id<FeedDelegate>)delegate;
- (void)removeFeedDelegate:(id<FeedDelegate>)delegate;

- (void)moveToNextFrame;

- (void)makeFrameReady:(Frame*)frame;
- (BOOL)hasReadyFrames;
- (BOOL)allFramesWereShown;

- (NSDate*)parseDate:(NSString*)date;
- (NSString*)dateFormat;

@end
