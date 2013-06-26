//
//  Stream.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/15/10.
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
#import "StreamDelegate.h"
#import "ObjectWithID.h"

@class Frame;
@class Feed;

@interface Stream : ObjectWithID 

@property (nonatomic, copy, setter=setTitle:) NSString *title;
@property (nonatomic, retain) NSMutableArray *feeds;
@property (nonatomic, retain) NSMutableArray *frames;

@property (nonatomic) BOOL isPaused;
@property (assign) BOOL skipNextFrameAddition;

@property (assign) BOOL initializing;

@property (nonatomic, copy) NSString *remoteID;

- (BOOL)addFeed:(Feed*)feed; 
- (void)removeFeed:(Feed*)feed;
- (void)moveFeed:(Feed*)feed fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)insertFeed:(Feed*)feed atIndex:(NSInteger)atIndex;

- (void)addStreamDelegate:(id<StreamDelegate>)delegate;
- (void)removeStreamDelegate:(id<StreamDelegate>)delegate;

- (void)loadNewFrames;
- (void)addNextFrame;
- (void)removeFrame:(Frame*)frame;

- (NSArray*)getImagePaths;
- (NSArray*)getResourcePaths;

- (void)fireFeedWasChanged:(Feed*)feed;

@end
