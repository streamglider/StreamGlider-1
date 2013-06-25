//
//  FixedMagPageLayout2.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 05/12/2011.
//  Copyright (c) 2011 StreamGlider, Inc. All rights reserved.
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

#import "FixedMagPageLayout2.h"

@implementation FixedMagPageLayout2

- (CGRect)positionForArticle:(int)articleNumber orientation:(UIInterfaceOrientation)orientation withBanner:(BOOL)withBanner {
    if (withBanner) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frames[] = {CGRectMake(0, 0, 376, 417), CGRectMake(377, 0, 391, 278), CGRectMake(377, 279, 391, 278), CGRectMake(0, 418, 376, 420), CGRectMake(377, 558, 391, 280)};
            return frames[articleNumber];
        } else {
            CGRect frames[] = {CGRectMake(0, 0, 670, 289), CGRectMake(671, 0, 353, 289), 
                CGRectMake(0, 290, 336, 293), CGRectMake(337, 290, 333, 293), CGRectMake(671, 290, 353, 293)};
            return frames[articleNumber];        
        }        
    } else {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frames[] = {CGRectMake(0, 0, 376, 450), CGRectMake(377, 0, 391, 300), CGRectMake(377, 301, 391, 300), CGRectMake(0, 451, 376, 453), CGRectMake(377, 602, 391, 302)};
            return frames[articleNumber];
        } else {
            CGRect frames[] = {CGRectMake(0, 0, 670, 322), CGRectMake(671, 0, 353, 322), 
                CGRectMake(0, 323, 336, 326), CGRectMake(337, 323, 333, 326), CGRectMake(671, 323, 353, 326)};
            return frames[articleNumber];        
        }                
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.spacesCount = 5;
    }
    
    return self;
}

@end
