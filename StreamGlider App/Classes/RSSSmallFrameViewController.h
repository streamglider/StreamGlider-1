//
//  RssSmallFrameViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 16/08/2010.
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

#import <UIKit/UIKit.h>
#import "SmallFrameViewController.h"

@class RSSFrame;
@class HighlightedTextView;

@interface RSSSmallFrameViewController : SmallFrameViewController 

@property (nonatomic, retain) IBOutlet HighlightedTextView *titleView;
@property (nonatomic, retain) IBOutlet HighlightedTextView *feedTitleView;

@property (nonatomic, retain) IBOutlet HighlightedTextView *imageTitleView;
@property (nonatomic, retain) IBOutlet HighlightedTextView *imageFeedTitleView;

@property (nonatomic, retain) IBOutlet UIView *textPanel;
@property (nonatomic, retain) IBOutlet UIView *imagePanel;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@property (nonatomic, assign, readonly) int fontSize;

@property (nonatomic, retain) IBOutlet UIImageView *backImage;

@property (nonatomic, assign) BOOL hasImage;

@end
