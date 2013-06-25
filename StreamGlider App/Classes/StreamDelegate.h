//
//  StreamDelegate.h
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
