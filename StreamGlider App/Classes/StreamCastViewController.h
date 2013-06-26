//
//  StreamCastViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/15/10.
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
#import "LoaderDelegate.h"
#import "PageBarViewController.h"

@class Stream;
@class StreamsTableViewController;
@class EditStreamViewController;
@class Frame;
@class SlideShowViewController;
@class PreviewViewController;
@class StartupAnimationViewController;

@interface StreamCastViewController : UIViewController <LoaderDelegate>
	
@property (nonatomic, retain) IBOutlet StreamsTableViewController *tableViewController;
@property (nonatomic, retain) IBOutlet EditStreamViewController *editViewController;

@property (nonatomic, retain) IBOutlet SlideShowViewController *slideShowViewController;
@property (nonatomic, retain, setter=setPreviewViewController:) IBOutlet PreviewViewController *previewViewController;

@property (nonatomic, retain) IBOutlet UIView *tableView;
@property (nonatomic, retain) IBOutlet UIView *tableViewContainer;

@property (assign) BOOL displayingPreview;

- (void)displayViewForFrame:(Frame*)frame;
- (void)playPreviewAnimation;
- (void)displayBrowserForFrame:(Frame*)frame;
- (void)displayBrowserForRequest:(NSURLRequest*)req;

- (IBAction)handleSharedStreamsTapped;
- (IBAction)handleEditTapped;

- (void)updateButtons;

- (void)pause;
- (void)resume;

@end
