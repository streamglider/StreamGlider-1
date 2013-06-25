//
//  RSSArticleViewController.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 03/11/2011.
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

#import "FrameViewController.h"
#import "DTAttributedTextView.h"
#import "DTLazyImageView.h"

@class MagModeViewController;

@interface RSSArticleViewController : FrameViewController <DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate> 

@property (nonatomic, assign) MagModeViewController *magModeVC;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) DTAttributedTextView *textArea;

@end
