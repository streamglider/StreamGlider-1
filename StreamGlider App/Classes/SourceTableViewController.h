//
//  SourceTableViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 25/09/2010.
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

@class FeedSource;
@class Feed;
@class Stream;

@interface SourceTableViewController : UITableViewController {
	FeedSource *feedSource;
	UIBarButtonItem *doneButton;
	Feed *feed;
	Stream *stream;
}

@property (nonatomic, retain) FeedSource *feedSource;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, assign, setter = setFeed:) Feed *feed;
@property (nonatomic, assign) Stream *stream;

- (void)createOrEditFeed;
- (void)prepopulateFields;

- (void)resignEditing;

@end
