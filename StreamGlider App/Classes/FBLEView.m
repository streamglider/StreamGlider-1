//
//  FBLEView.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 15/11/2011.
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

#import "FBLEView.h"
#import "FBLEViewController.h"

@implementation FBLEView

@synthesize viewController;

- (CGSize)calcImageSize {
    CGSize imgSize = [viewController.postImage sizeThatFits:CGSizeZero];
    
    CGFloat aw = self.frame.size.width - 15 - viewController.userImage.frame.size.width;
    
    aw = MIN(aw, imgSize.width);
    
    CGFloat ratio = imgSize.width / aw;
    
    CGFloat ah = imgSize.height * ratio;
    
    return CGSizeMake(aw, ah);    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat varH;
    if (viewController.postImage.hidden) {
        CGSize textSize = [viewController.textLabel sizeThatFits:viewController.textLabel.frame.size];
        
        varH = MAX(34, textSize.height);        
    } else {    
        CGSize imgSize = [self calcImageSize];
        
        varH = imgSize.height;        
    }
    
    return CGSizeMake(size.width, viewController.userNameLabel.frame.size.height + varH + 5 + viewController.dateLabel.frame.size.height);    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (viewController.postImage.hidden) {
        CGRect r = viewController.textLabel.frame;
        
        CGSize sz = [viewController.textLabel sizeThatFits:r.size];
        CGFloat h = MAX(34, sz.height);
        
        r.size.height = h;
        
        viewController.textLabel.frame = r;
        
        CGRect dateRect = viewController.dateLabel.frame;
        
        dateRect.origin.y = r.size.height + r.origin.y + 5;
        
        viewController.dateLabel.frame = dateRect;                
    } else {
        CGRect r = viewController.postImage.frame;
        
        r.size = [self calcImageSize];
        
        viewController.postImage.frame = r;
        
        r = viewController.dateLabel.frame;
        
        r.origin.y = viewController.postImage.frame.size.height + viewController.postImage.frame.origin.y;
        
        viewController.dateLabel.frame = r;
    }
}

- (void)dealloc {
    [super dealloc];
}
@end
