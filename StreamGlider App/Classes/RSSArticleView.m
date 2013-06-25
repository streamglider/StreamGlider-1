//
//  RSSArticleView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 18/11/2011.
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

#import "RSSArticleView.h"
#import "RSSArticleViewController.h"

@implementation RSSArticleView

@synthesize viewController;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = viewController.titleLabel.frame;
    
    CGSize sz = [viewController.titleLabel sizeThatFits:r.size];
    r.size = sz;
    
    viewController.titleLabel.frame = r;
    
    CGFloat yPos = r.origin.y + sz.height + 5;
    CGFloat ah = self.frame.size.height - yPos - 10;
    
    r = viewController.textArea.frame;
    r.origin.y = yPos;
    r.size.height = ah;
    
    viewController.textArea.frame = r;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

@end
