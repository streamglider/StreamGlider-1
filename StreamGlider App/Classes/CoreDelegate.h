//
//  CoreDelegate.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/19/10.
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
@class FeedSource;
@class PageOfStreams;

@protocol CoreDelegate

@optional
// streams
- (void)streamWasAdded:(Stream*)stream;
- (void)streamWasRemoved:(Stream*)stream index:(NSInteger)index;
- (void)streamWasMoved:(Stream*)stream fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

// feed sources
- (void)sourceWasAdded:(FeedSource*)source;
- (void)sourceWasRemoved:(FeedSource*)source;

// pages
- (void)pageWasAdded:(PageOfStreams*)page;
- (void)pageWasRemoved:(PageOfStreams*)page;
- (void)activePageWasChangedToPage:(PageOfStreams*)page;

@end
