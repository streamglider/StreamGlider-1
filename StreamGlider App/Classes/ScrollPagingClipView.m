//
//  ScrollPagingClipView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 25/10/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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

#import "ScrollPagingClipView.h"


@implementation ScrollPagingClipView

@synthesize scrollView, additionalView;

#pragma mark UIView

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {		
	if (additionalView != nil) {
		CGPoint pt = [additionalView convertPoint:point fromView:self];
		UIView *v = [additionalView hitTest:pt withEvent:event];
		if (v != nil)
			return v;
	}
	
	for (UIView *child in scrollView.subviews) {
		CGPoint pt = [child convertPoint:point fromView:self];
		UIView *v = [child hitTest:pt withEvent:event];
		if (v != nil)
			return v;
	}
	
    if ([self pointInside:point withEvent:event])
        return scrollView;   
		 
    return nil;		
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;

}

@end
