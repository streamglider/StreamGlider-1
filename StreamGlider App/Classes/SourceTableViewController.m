//
//  SourceTableViewController.m
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

#import "SourceTableViewController.h"
#import "FeedSource.h"
#import "Feed.h"
#import "FeedFactory.h"
#import "Stream.h"
#import "NamedFieldTableViewCell.h"


@implementation SourceTableViewController

@synthesize feedSource, doneButton, feed, stream;

#pragma mark Utility Methods

- (void)resignEditing {
	NSIndexPath *p = [NSIndexPath indexPathForRow:0 inSection:2];
	NamedFieldTableViewCell *cell = (NamedFieldTableViewCell*)[self.tableView cellForRowAtIndexPath:p];
	[cell.titleValueTextField resignFirstResponder];
	
	p = [NSIndexPath indexPathForRow:1 inSection:2];
	cell = (NamedFieldTableViewCell*)[self.tableView cellForRowAtIndexPath:p];
	[cell.titleValueTextField resignFirstResponder];
}

#pragma mark Properties

- (void)setFeed:(Feed*)f {
	feed = f;
	[self prepopulateFields];
}

#pragma mark Prepopulating

- (void)prepopulateFields {
}

#pragma mark Creating Feeds

- (void)createOrEditFeed {
	if (feed == nil) {
		Feed *f = [FeedFactory createFeedForSource:feedSource];
		f.source = feedSource;
		f.stream = stream;
		[stream addFeed:f];
	} else {		
		// change feed source or create a new feed
		if (feed.source.type == feedSource.type) {
			feed.source = feedSource;
		} else {
			// remove old feed, create a new one
			Feed *f = [FeedFactory createFeedForSource:feedSource];			
			f.source = feedSource;
			f.stream = stream;
			
			int index = [stream.feeds indexOfObject:feed];
			[stream removeFeed:feed];
			[stream insertFeed:f atIndex:index];
		}
	}
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *buttonTitle;
	if (feed != nil)
		buttonTitle = @"Save";
	else 
		buttonTitle = @"Create";
	
	self.doneButton = [[[UIBarButtonItem alloc] 
					   initWithTitle:buttonTitle 
					   style:UIBarButtonItemStyleBordered
					   target:self 
					   action:@selector(handleDoneButtonTapped)] autorelease];
	doneButton.enabled = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.navigationItem.rightBarButtonItem = doneButton;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.feedSource = nil;
	self.doneButton = nil;
    [super dealloc];
}


@end

