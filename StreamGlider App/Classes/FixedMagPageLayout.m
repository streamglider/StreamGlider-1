//
//  FixedMagPageLayout.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 31/10/2011.
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

#import "FixedMagPageLayout.h"

@implementation FixedMagPageLayout

- (CGRect)positionForArticle:(int)articleNumber orientation:(UIInterfaceOrientation)orientation withBanner:(BOOL)withBanner {
    
    if (withBanner) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frames[] = {CGRectMake(0, 0, 360, 278), CGRectMake(361, 0, 407, 318), 
                CGRectMake(0, 279, 360, 316), CGRectMake(361, 319, 407, 276), 
                CGRectMake(0, 596, 310, 242), CGRectMake(311, 596, 458, 242)};
            return frames[articleNumber];
        } else {
            CGRect frames[] = {CGRectMake(0, 0, 350, 317), CGRectMake(351, 0, 298, 347), CGRectMake(650, 0, 374, 317), 
                CGRectMake(0, 318, 350, 265), CGRectMake(351, 348, 298, 235), CGRectMake(650, 318, 374, 265)};
            return frames[articleNumber];        
        }        
    } else {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frames[] = {CGRectMake(0, 0, 360, 300), CGRectMake(361, 0, 407, 340), 
                CGRectMake(0, 301, 360, 338), CGRectMake(361, 341, 407, 298), 
                CGRectMake(0, 640, 310, 264), CGRectMake(311, 640, 458, 264)};
            return frames[articleNumber];
        } else {
            CGRect frames[] = {CGRectMake(0, 0, 350, 340), CGRectMake(351, 0, 298, 380), CGRectMake(650, 0, 374, 340), 
                CGRectMake(0, 341, 350, 308), CGRectMake(351, 381, 298, 268), CGRectMake(650, 341, 374, 308)};
            return frames[articleNumber];        
        }                
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.spacesCount = 6;
    }
    
    return self;
}

@end
