//
//  ScrollPagingClipView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 25/10/2010.
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
