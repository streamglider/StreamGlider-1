//
//  ButtonWithBadge.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 08/02/2012.
//  Copyright (c) 2012 StreamGlider, Inc. All rights reserved.
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

#import "ButtonWithBadge.h"
#import "CustomBadge.h"

@interface ButtonWithBadge ()

@property (nonatomic, retain) CustomBadge *badge;

@end

@implementation ButtonWithBadge

@synthesize badgeNumber;
@synthesize badge;

- (void)setBadgeNumber:(int)bn {
    badgeNumber = bn;
    [badge setBadgeText:[NSString stringWithFormat:@"%d", badgeNumber]];
    if (badgeNumber == 0) {
        badge.hidden = YES;
    } else {
        badge.hidden = NO;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    badge.frame = CGRectMake(self.frame.size.width - (badge.frame.size.width / 1.6), 
                             -badge.frame.size.height / 2.4, 
                             badge.frame.size.width, badge.frame.size.height);        
}

- (id)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    
    badgeNumber = 0;
    
    // create custom badge
    self.badge = [CustomBadge customBadgeWithString:@"0" 
                                    withStringColor:[UIColor whiteColor] 
                                     withInsetColor:[UIColor redColor] 
                                     withBadgeFrame:YES 
                                withBadgeFrameColor:[UIColor whiteColor] 
                                          withScale:0.8 
                                        withShining:YES];
    badge.hidden = YES;
    
    [self addSubview:badge];
    
    return self;
}

- (void)dealloc {
    self.badge = nil;
    [super dealloc];
}


@end
