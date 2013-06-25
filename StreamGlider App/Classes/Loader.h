//
//  Loader.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/16/10.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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
#import "LoaderDelegate.h"
#import "FeedSourceType.h"
#import "APIDelegate.h"
#import "StreamsLoaderDelegate.h"

@class Core;
@class FeaturedFeedsLoader;

@interface Loader : NSObject <APIDelegate, StreamsLoaderDelegate> 

@property (nonatomic, assign) id<LoaderDelegate> delegate;
@property (nonatomic, retain) FeaturedFeedsLoader *ffLoader;

+ (Loader*)sharedInstance;

- (void)loadWithCore:(Core*)core;
- (void)storeSources;
- (void)storeStreams;

@end
