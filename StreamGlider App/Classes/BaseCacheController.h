//
//  BaseCacheController.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 13/10/2010.
//  Refactoring by Gavin McKenzie on 11-07-12.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
