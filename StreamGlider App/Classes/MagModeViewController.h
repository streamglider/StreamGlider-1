//
//  MagModeViewController.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 31/10/2011.
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

#import <UIKit/UIKit.h>
#import "CoreDelegate.h"

@class Stream;
@class PreviewViewController;
@class Frame;

@interface MagModeViewController : UIViewController <CoreDelegate, UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, retain) PreviewViewController *previewVC;
@property (nonatomic, assign) Stream *stream;
@property (nonatomic, assign) BOOL openStreamsPanel;

- (void)activeStreamWasChanged;
- (void)displayPreviewForFrame:(Frame*)frame;

@end
