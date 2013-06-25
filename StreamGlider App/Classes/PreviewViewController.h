//
//  PreviewViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/10/2010.
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FrameViewController.h"

@class StreamCastViewController;
@class MagModeViewController;

@interface PreviewViewController : FrameViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> 

@property (nonatomic, assign) StreamCastViewController *streamCastViewController;
@property (nonatomic, assign) BOOL magMode;
@property (nonatomic, assign) int selectedFrameIndex;
@property (nonatomic, assign) CGRect firstFrameRect;
@property (nonatomic, retain) IBOutlet UIView *panelView;
@property (nonatomic, assign) MagModeViewController *magModeVC;

- (void)play;
- (void)closePreview;

@end
