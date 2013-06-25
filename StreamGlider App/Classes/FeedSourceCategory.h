//
//  FeedSourceCategory.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 28/02/2011.
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


@interface FeedSourceCategory : NSObject 

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) FeedSourceCategory *parentCategory;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, copy) NSString *imageURL;

- (void)addChild:(NSObject*)child;
- (void)removeChild:(NSObject*)child;

@end
