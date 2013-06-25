//
//  SettingsDelegate.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 06/05/2011.
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

#import <UIKit/UIKit.h>

typedef enum {
	SettingsPropertyTypeNewIndicatorColor,
	SettingsPropertyTypeCardsInterval, 
	SettingsPropertyTypeGrayOutViewedFrames,
	SettingsPropertyTypePlusMode,
    SettingsPropertyTypePaginateFeeds
} SettingsPropertyType; 

@protocol SettingsDelegate

- (void)propertyChanged:(SettingsPropertyType)propertyName oldValue:(NSObject*)oldValue newValue:(NSObject*)newValue;

@end
