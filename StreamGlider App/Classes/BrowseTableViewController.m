//
//  BrowseTableViewController.m
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

#import "BrowseTableViewController.h"
#import "FeedSourceCategory.h"
#import "FeedSource.h"
#import "EditWindowViewController.h"
#import "Feed.h"
#import "FeedFactory.h"
#import "Stream.h"
#import "Core.h"
#import "GoogleReaderLoginViewController.h"

#define CELL_IMAGES @"CAT_MYFEEDS.png", @"CAT_GOOGLEREADER.png", @"CAT_FACEBOOK.png", @"CAT_FLICKR.png", @"CAT_TWITTER.png", @"CAT_YOUTUBE.png", @"CAT_NEWS.png", @"CAT_SPORTS.png", @"CAT_BIZ&FINANCE.png", @"CAT_DINING.png", @"CAT_TECHNOLOGY.png", @"CAT_CULTURE.png", @"CAT_HEALTH.png", @"CAT_TRAVEL.png", NULL

@implementation BrowseTableViewController {
	FeedSource *selectedSource;
	NSArray *cellImages;	    
}

@synthesize leafPage, editViewController, category, filteredCategory;

#pragma mark Properties

- (void)setCategory:(FeedSourceCategory*)cat {
	if (cat != category) {
		category = cat;
		self.title = category.title;
		if ([cat.title isEqualToString:@"My Feeds"]) {
			// display edit button
			self.navigationItem.rightBarButtonItem = self.editButtonItem;		
		} 
        [self.tableView reloadData];
	}
}

- (void)setEditViewController:(EditWindowViewController*)ewvc {
	editViewController = ewvc;
	if (editViewController.feed != nil)
		selectedSource = editViewController.feed.source;
}

- (void)setLeafPage:(BOOL)lp {
	leafPage = lp;
	if (!leafPage) {
		UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																					 target:self 
																					 action:@selector(handleCloseTapped)];
		self.navigationItem.leftBarButtonItem = closeButton;
		[closeButton release];
		
		cellImages = [NSArray arrayWithObjects:CELL_IMAGES];
		[cellImages retain];
	}
}

#pragma mark Opening Category

- (void)openCategory:(FeedSourceCategory*)cat {
	// create path
	BrowseTableViewController *btc = [[BrowseTableViewController alloc] initWithNibName:@"BrowseTableViewController" 
																				 bundle:nil];
	
	btc.editViewController = editViewController;
	btc.category = cat;
	btc.leafPage = YES; 
	
	[self.navigationController pushViewController:btc animated:NO];

	if (editViewController.feed != nil) {
		[btc performSelector:@selector(scrollTableToSource:) withObject:editViewController.feed.source 
				  afterDelay:0.1];
	}
	
	[btc release];
}

- (void)scrollTableToSource:(FeedSource*)src {
	// find section and row
	int section = 0;
	int row = 0;
	BOOL srcFound = NO;
	for (FeedSourceCategory *cat in category.children) {
		row = 0;
		for (FeedSource *s in cat.children) {	
			if ([s isEqual:src]) {
				srcFound = YES;
				break;
			}
			row++;
		}
		if (srcFound)
			break;
		
		section++;
	}
		
	if (srcFound) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle 
									  animated:NO];
	}
}

#pragma mark GoogleReaderLoginDelegate

- (void)loginSuccessful {
	BrowseTableViewController *btc = [[BrowseTableViewController alloc] initWithNibName:@"BrowseTableViewController" 
																				 bundle:nil];				
	btc.editViewController = editViewController;
    
    for (FeedSourceCategory *fsc in category.children) {
        if ([fsc.title isEqualToString:@"My Feeds"]) {
            for (FeedSourceCategory *fsc1 in fsc.children) { 
                if ([fsc1.title isEqualToString:@"Google Reader"]) {
                    btc.category = fsc1; 
                    btc.leafPage = YES; 
                    
                    [self.navigationController pushViewController:btc animated:YES];
                    break;
                }
            }
            break;
        }        
    }
    
    [btc release];			
}

#pragma mark Handlers

- (void)handleCloseTapped {
	[editViewController dismissModalViewControllerAnimated:YES];
	[editViewController closeCallback];
}

#pragma mark UITableViewDataSource

- (Feed*)createFeedForSource:(FeedSource*)src {
	// create a new feed using selected feed source
	Feed *f = [FeedFactory createFeedForSource:selectedSource];	
	f.source = src;
	f.stream = editViewController.stream;
	return f;
}

- (int)findSourceInArrayOfFeeds:(FeedSource*)src feeds:(NSArray*)feeds {
	int index = 0;
	for (Feed *feed in feeds) {
		if ([feed.source isEqual:src]) { 
			return index;
		}
		index++;
	}
	return NSNotFound;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (leafPage) {
		if (tableView == self.tableView)
			return [category.children count];
		else 
			return [filteredCategory.children count];
	} else {
        return [category.children count];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (leafPage) {
		FeedSourceCategory *cat;
		if (tableView == self.tableView)
			cat = [category.children objectAtIndex:section];
		else 
			cat = [filteredCategory.children objectAtIndex:section];
		
		return [cat.children count];
	} else {
        return [((FeedSourceCategory*)[category.children objectAtIndex:section]).children count];                     
	}
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (leafPage) {
		FeedSourceCategory *cat;
		if (tableView == self.tableView)
			cat = [category.children objectAtIndex:section];
		else 
			cat = [filteredCategory.children objectAtIndex:section];
		
		return cat.title;
	} else {
        FeedSourceCategory *cat = (FeedSourceCategory*)[category.children objectAtIndex:section];
        if ([cat.title isEqualToString:@"My Feeds"])
            return nil;
        else
            return cat.title;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CategoryCellIdentifier = @"CategoryCell";
    static NSString *SourceCellIdentifier = @"SourceCell";

	NSObject *obj;
    NSString *cellId;
	
	if (leafPage) {
		FeedSourceCategory *cat;
		if (tableView == self.tableView)
			cat = [category.children objectAtIndex:indexPath.section];
		else 
			cat = [filteredCategory.children objectAtIndex:indexPath.section];
		
		obj = [cat.children objectAtIndex:indexPath.row];
		cellId = SourceCellIdentifier;
	} else {
        FeedSourceCategory *cat = [category.children objectAtIndex:indexPath.section];
        obj = [cat.children objectAtIndex:indexPath.row];
		cellId = CategoryCellIdentifier;
	}

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	if (leafPage) {
		cell.textLabel.text = ((FeedSource*)obj).title;
		if (editViewController.feed != nil) {
			if ([selectedSource isEqual:obj]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else { 
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		} else {
			// check if this source is in the added array
			if ([self findSourceInArrayOfFeeds:(FeedSource*)obj feeds:editViewController.addedFeeds] != NSNotFound) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else if ([self findSourceInArrayOfFeeds:(FeedSource*)obj feeds:editViewController.stream.feeds] != NSNotFound) {
				UIImageView *iv = [[UIImageView alloc] init];
				iv.image = [UIImage imageNamed:@"GREYED_TICK.png"];
				iv.frame = CGRectMake(0, 0, 15, 15);
				cell.accessoryView = iv;
				[iv release];
			} else {
				cell.accessoryView = nil;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		
	} else {
		cell.textLabel.text = ((FeedSourceCategory*)obj).title;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        FeedSourceCategory *fsc = (FeedSourceCategory*)obj;
        if (fsc.imageURL != nil)
            cell.imageView.image = [UIImage imageWithContentsOfFile:fsc.imageURL];
        else
            cell.imageView.image = nil;        
	}
    
    // Configure the cell...
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		FeedSourceCategory *cat = [category.children objectAtIndex:indexPath.section];
		FeedSource *fs = [cat.children objectAtIndex:indexPath.row];
		[cat removeChild:fs];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[filteredCategory.children removeAllObjects];
	
	for (FeedSourceCategory *cat in category.children) {
		BOOL catHasChildren = NO;
		FeedSourceCategory *fCat = [[FeedSourceCategory alloc] init];
		fCat.parentCategory = cat.parentCategory;
		fCat.title = cat.title;
		
		for (FeedSource *src in cat.children) {
			if ([src.title rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
				[fCat addChild:src];
				catHasChildren = YES;
			}
		}
		
		if (catHasChildren) {
			[filteredCategory addChild:fCat];
		}
		[fCat release];
	}	
	
	return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[self.tableView reloadData];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!leafPage) {				
		FeedSourceCategory *cat = [category.children objectAtIndex:indexPath.section];
        cat = [cat.children objectAtIndex:indexPath.row];
        
		if ([cat.title isEqualToString:@"Google Reader"]) {
			[cat.children removeAllObjects];
			GoogleReaderLoginViewController *gvc = [[GoogleReaderLoginViewController alloc] 
													initWithNibName:@"GoogleReaderLoginViewController" 
													bundle:nil];
			gvc.delegate = self;
			gvc.modalPresentationStyle = UIModalPresentationFormSheet;
			[editViewController presentModalViewController:gvc animated:YES];
			[gvc release];			
		} else {
			BrowseTableViewController *btc = [[BrowseTableViewController alloc] initWithNibName:@"BrowseTableViewController" 
																						 bundle:nil];				
			btc.editViewController = editViewController;
			btc.category = cat;
			btc.leafPage = YES; 
			
			[self.navigationController pushViewController:btc animated:YES];
			[btc release];			
		}
	} else if (editViewController.feed != nil) {
		FeedSourceCategory *cat;
		if (tableView == self.tableView)
			cat = [category.children objectAtIndex:indexPath.section];		
		else 
			cat = [filteredCategory.children objectAtIndex:indexPath.section];
		
		selectedSource = [cat.children objectAtIndex:indexPath.row];
		
		// change feed source or create a new feed
		if (editViewController.feed.source.type == selectedSource.type) {
			editViewController.feed.source = selectedSource;
		} else {
			// remove old feed, create a new one
			Feed *f = [self createFeedForSource:selectedSource];						
			int index = [editViewController.stream.feeds indexOfObject:editViewController.feed];
			[editViewController.stream removeFeed:editViewController.feed];
			[editViewController.stream insertFeed:f atIndex:index];
			
			editViewController.feed = f;
		}

		[tableView reloadData];
	} else {
		FeedSourceCategory *cat;
		if (tableView == self.tableView)
			cat = [category.children objectAtIndex:indexPath.section];		
		else 
			cat = [filteredCategory.children objectAtIndex:indexPath.section];
		
		selectedSource = [cat.children objectAtIndex:indexPath.row];
		
		int index = [self findSourceInArrayOfFeeds:selectedSource feeds:editViewController.addedFeeds];
		if (index != NSNotFound) {
			// remove this feed from the stream
			[editViewController.addedFeeds removeObjectAtIndex:index];
			index = [self findSourceInArrayOfFeeds:selectedSource feeds:editViewController.stream.feeds];
			[editViewController.stream removeFeed:[editViewController.stream.feeds objectAtIndex:index]];
			[tableView reloadData];
		} else if ([self findSourceInArrayOfFeeds:selectedSource feeds:editViewController.stream.feeds] == NSNotFound) {
			// create a new feed
			Feed *f = [self createFeedForSource:selectedSource];
			f.editing = YES;
			if ([editViewController.stream addFeed:f]) {					
				[editViewController.addedFeeds addObject:f];			
				[tableView reloadData];
			}
		}
	}
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];	
		
	// Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.filteredCategory = nil;
	
	[cellImages release];
	
    [super dealloc];
}


@end

