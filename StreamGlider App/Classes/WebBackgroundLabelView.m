//
//  WebBackgroundLabelView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 24/11/2011.
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

#import "WebBackgroundLabelView.h"
#import "WebBackgroundLabelViewController.h"

@implementation WebBackgroundLabelView

- (CGSize)sizeThatFits:(CGSize)size {
    WebBackgroundLabelViewController *viewController = (WebBackgroundLabelViewController*)[self nextResponder];
    
    CGFloat w = [viewController.titleLabel sizeThatFits:CGSizeZero].width;
        
    w = MAX(131, w);
    w = MIN(w, 300);
    return CGSizeMake(w + 10, 29);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
