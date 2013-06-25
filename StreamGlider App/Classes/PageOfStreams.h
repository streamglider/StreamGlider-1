//
//  PageOfStreams.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 25/10/2011.
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
#import "ObjectWithID.h"
#import "PageOfStreamsDelegate.h"

@interface PageOfStreams : ObjectWithID 
    
@property (nonatomic, retain) NSMutableArray *streams;
@property (nonatomic, copy, setter = setTitle:) NSString *title;
@property (nonatomic, assign) BOOL activePage;

@property (nonatomic, retain) NSMutableSet *delegates;

@property (nonatomic, assign) int magModeIndex;

- (void)addDelegate:(id<PageOfStreamsDelegate>)delegate;
- (void)removeDelegate:(id<PageOfStreamsDelegate>)delegate;

@end
