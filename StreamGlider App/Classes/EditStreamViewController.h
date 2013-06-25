//
//  EditStreamViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/07/2010.
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

@class OtherStreamsTableViewController;
@class EditFrameViewController;
@class Stream;

@interface EditStreamViewController : UIViewController <UIPopoverControllerDelegate> 
	
@property (nonatomic, retain) IBOutlet OtherStreamsTableViewController *otherStreamsTableViewController;

- (void)displayEditWindowForFeed:(EditFrameViewController*)feed;
- (void)scrollStreamToTheTop:(Stream*)stream;
- (void)revertScrollToTheTop;

@end
