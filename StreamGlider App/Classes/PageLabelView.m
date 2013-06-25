//
//  PageLabelView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 28/10/2011.
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

#import "PageLabelView.h"
#import "PageLabelViewController.h"

@implementation PageLabelView

- (CGSize)sizeThatFits:(CGSize)size {
    PageLabelViewController *viewController = (PageLabelViewController*)[self nextResponder];
    CGFloat w = [viewController.titleLabel sizeThatFits:CGSizeZero].width;
    
    if (viewController.editMode) {
        w += viewController.deleteButton.frame.size.width + 5;
    } 
        
    w = MAX(131, w);
    w = MIN(w, 300);
    return CGSizeMake(w + 10, 29);
}
 
- (void)layoutSubviews {
    [super layoutSubviews];
    
    PageLabelViewController *viewController = (PageLabelViewController*)[self nextResponder];
    if (viewController.editMode) {
        CGFloat lW = self.frame.size.width - viewController.deleteButton.frame.size.width - 15;
        
        CGRect r = viewController.titleLabel.frame;
        r.size.width = lW;
        viewController.titleLabel.frame = r;
        
        r = viewController.editField.frame;
        r.size.width = lW;
        viewController.editField.frame = r;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
