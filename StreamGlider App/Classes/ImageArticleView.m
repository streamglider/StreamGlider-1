//
//  ImageArticleView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 16/11/2011.
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

#import "ImageArticleView.h"
#import "ImageArticleViewController.h"

@implementation ImageArticleView

@synthesize viewController;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = viewController.titleLabel.frame;
    CGSize sz = [viewController.titleLabel sizeThatFits:r.size];
    r.size.height = sz.height;
    
    viewController.titleLabel.frame = r;
    
    CGFloat ah = self.frame.size.height - r.size.height - 15;
    CGFloat yPos = r.origin.y + r.size.height;
    
    r = viewController.imageView.frame;
    r.origin.y = yPos;
    r.size.height = ah;
    
    viewController.imageView.frame = r;
    viewController.ytOverlayView.frame = r;
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
