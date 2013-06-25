//
//  BrowseTableViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 01/03/2011.
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
#import "GoogleReaderLoginDelegate.h"

@class EditWindowViewController;
@class FeedSourceCategory;
@class FeedSource;

@interface BrowseTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, GoogleReaderLoginDelegate> 

@property (nonatomic, assign, setter=setEditViewController:) EditWindowViewController *editViewController;
@property (nonatomic, assign, setter=setLeafPage:) BOOL leafPage;
@property (nonatomic, assign, setter=setCategory:) FeedSourceCategory *category;

@property (nonatomic, retain) FeedSourceCategory *filteredCategory;
 
- (void)openCategory:(FeedSourceCategory*)cat;
- (void)scrollTableToSource:(FeedSource*)src;

@end
