//
//  BrowseTableViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 01/03/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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
