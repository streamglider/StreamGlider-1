//
//  FixedMagPageLayout1.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 04/11/2011.
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

#import "FixedMagPageLayout1.h"

@implementation FixedMagPageLayout1

- (CGRect)positionForArticle:(int)articleNumber orientation:(UIInterfaceOrientation)orientation withBanner:(BOOL)withBanner {
    if (withBanner) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frames[] = {CGRectMake(0, 0, 359, 556), CGRectMake(360, 0, 408, 277), 
                CGRectMake(360, 278, 408, 278), 
                CGRectMake(0, 557, 768, 282)};
            return frames[articleNumber];
        } else {
            CGRect frames[] = {CGRectMake(0, 0, 339, 583), CGRectMake(340, 0, 339, 367), CGRectMake(680, 0, 344, 367), 
                CGRectMake(340, 368, 684, 215)};
            return frames[articleNumber];        
        }        
    } else {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frames[] = {CGRectMake(0, 0, 359, 600), CGRectMake(360, 0, 408, 299), 
                CGRectMake(360, 300, 408, 300), 
                CGRectMake(0, 601, 768, 304)};
            return frames[articleNumber];
        } else {
            CGRect frames[] = {CGRectMake(0, 0, 339, 649), CGRectMake(340, 0, 339, 400), CGRectMake(680, 0, 344, 400), 
                CGRectMake(340, 401, 684, 248)};
            return frames[articleNumber];        
        }                
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.spacesCount = 4;
    }
    
    return self;
}

@end
