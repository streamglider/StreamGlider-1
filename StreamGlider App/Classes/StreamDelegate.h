//
//  StreamDelegate.h
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

#import <UIKit/UIKit.h>

@class Stream;
@class Feed;
@class Frame;

@protocol StreamDelegate

@optional

- (void)titleWasChanged:(Stream*)stream;

- (void)feedWasAdded:(Feed*)feed;
- (void)feedWasRemoved:(Feed*)feed;
- (void)feedWasMoved:(Feed*)feed fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)feedWasInserted:(Feed*)feed atIndex:(NSInteger)atIndex;
- (void)feedWasChanged:(Feed*)feed;

- (void)frameWasAdded:(Frame*)frame;
- (void)frameWasRemoved:(Frame*)frame;

@end
