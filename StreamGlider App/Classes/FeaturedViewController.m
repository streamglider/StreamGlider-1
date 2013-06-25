//
//  FeaturedViewController.m
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

#import "FeaturedViewController.h"
#import "EditWindowViewController.h"
#import "FeedSource.h"
#import "Feed.h"
#import "FeedFactory.h"
#import "Stream.h"
#import "RSSFrame.h"
#import "StreamCastStateController.h"
#import "StreamCastViewController.h"
#import "NSString+OAuth.h"
#import "FeaturedFeedSource.h"
#import "Core.h"
#import "BrowseTableViewController.h"

@interface FeaturedViewController () 

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)handleButtonTapped:(id)sender;

@end

@implementation FeaturedViewController

@synthesize editViewController, scrollView;

#pragma mark Utility Methods

- (void)createButtons {
	editViewController.waitView.hidden = YES;
	[editViewController.activityView stopAnimating];
	
    editViewController.browseViewController.category = [Core sharedInstance].rootCategory;
    
	// create buttons
	int i = 0;
	int shift = 25;
	for (FeaturedFeedSource *feed in [Core sharedInstance].featuredFeeds) {
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *img = [UIImage imageWithContentsOfFile:feed.imageURL];
		[b setImage:img forState:UIControlStateNormal];
		b.frame = CGRectMake(25, shift, 490, 168);
		
		shift += 10 + 168;
		b.tag = i;
		i++;
		
		[b addTarget:self action:@selector(handleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		[scrollView addSubview:b];
	}
	
	scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, 
										168 * [[Core sharedInstance].featuredFeeds count] + 
										([[Core sharedInstance].featuredFeeds count] - 1) * 10 + 2 * 25);
}

- (void)waitForFeaturedFeeds {
	while (YES) {
        if ([[Core sharedInstance].featuredFeeds count] != 0 && [Core sharedInstance].rootCategory != nil) {
			[self performSelectorOnMainThread:@selector(createButtons) 
								   withObject:nil waitUntilDone:NO];
			break;
		} else {
			[NSThread sleepForTimeInterval:2.0];
		}
	}
}

#pragma mark Handlers

- (int)findSourceInArrayOfFeeds:(FeedSource*)src feeds:(NSArray*)feeds {
	int index = 0;
	for (Feed *feed in feeds) {
		if ([feed.source isEqual:src]) 
			return index;
		index++;
	}
	return NSNotFound;
}

- (IBAction)handleButtonTapped:(id)sender {
	UIButton *but = (UIButton*)sender;
	
	NSArray *ffArray = [Core sharedInstance].featuredFeeds;
	
	FeaturedFeedSource *ffs = [ffArray objectAtIndex:but.tag];
	
	FeedSource *feedSource = [ffs.feedSource copy];
	
	EditWindowViewController *e = editViewController;
	if (e.feed == nil) {
		// check if this source is already in the stream
		
		int index = [self findSourceInArrayOfFeeds:feedSource 
											 feeds:editViewController.stream.feeds];
		if (index == NSNotFound) {		
			Feed *f = [FeedFactory createFeedForSource:feedSource];
			f.source = feedSource;
			f.stream = e.stream;
			[e.stream addFeed:f];
			[editViewController.addedFeeds addObject:f];
		}
	} else {		
		// change feed source or create a new feed
		if (e.feed.source.type == feedSource.type) {
			e.feed.source = feedSource;
		} else {
			// remove old feed, create a new one
			Feed *f = [FeedFactory createFeedForSource:feedSource];
			f.source = feedSource;
			f.stream = e.stream;
			
			int index = [e.stream.feeds indexOfObject:e.feed];
			[e.stream removeFeed:e.feed];
			[e.stream insertFeed:f atIndex:index];
			e.feed = f;
		}		
	}	
    
    [feedSource release];
}

- (void)handleCloseTapped {
	[editViewController closeCallback];
	[editViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	
	self.title = @"Featured";
	    
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																	 target:self 
																	 action:@selector(handleCloseTapped)];
	self.navigationItem.leftBarButtonItem = closeButton;
	[closeButton release];
	
	if ([[Core sharedInstance].featuredFeeds count] != 0 && [Core sharedInstance].rootCategory != nil) {
		[self createButtons];
	} else {
		// show wait window and wait in background until featured feads being downloaded
		editViewController.waitView.hidden = NO;
		[editViewController.activityView startAnimating];
		[self performSelectorInBackground:@selector(waitForFeaturedFeeds) withObject:nil];
	}
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
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.scrollView = nil;
    [super dealloc];
}

@end
