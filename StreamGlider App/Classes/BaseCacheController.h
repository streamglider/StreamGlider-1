//
//  BaseCacheController.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 13/10/2010.
//  Refactoring by Gavin McKenzie on 11-07-12.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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
#import "CoreDelegate.h"
#import "StreamDelegate.h"

@class Stream;
@class CacheData;

@interface BaseCacheController : NSObject <CoreDelegate, StreamDelegate> 

@property (assign) BOOL syncingImages;

- (Feed*)findFeed:(NSString*)feedID;
- (NSArray*)getFramesForStream:(Stream*)stream;

- (NSData*)loadImageData:(NSString*)url;

- (void)storeCacheData;
- (void)loadCacheData;
- (void)dumpCache;

// images
- (NSString*)storeImageData:(NSString*)imageUrl withThumb:(BOOL)withThumb;
- (UIImage*)getImage:(NSString*)path;
- (void)releaseImage:(NSString*)path;

// resources
- (NSString*)storeResourceData:(NSData*)resData;
- (NSData*)getResourceData:(NSString*)path;
- (void)releaseResourceData:(NSString*)path;

- (void)syncResourcesAndImagesCache;

@end
