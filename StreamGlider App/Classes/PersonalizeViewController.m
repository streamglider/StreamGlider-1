//
//  PersonalizeViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 02/03/2011.
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

#import "PersonalizeViewController.h"
#import "NewFBSourceTableViewController.h"
#import "NewTwitterSourceTableViewController.h"
#import "NewFlickrSourceTableViewController.h"
#import "NewYTSourceTableViewController.h"
#import "NewRSSSourceTableViewController.h"
#import "SourceTableViewController.h"
#import "EditWindowViewController.h"
#import "FeedSource.h"
#import "Feed.h"


@interface PersonalizeViewController ()

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)handleButtonTapped:(id)sender;

@end

@implementation PersonalizeViewController

@synthesize editViewController, scrollView;

#pragma mark Opening

- (void)openEditorForSource:(FeedSource*)src {
	SourceTableViewController *c;
	switch (src.type) {
		case FeedSourceTypeRSS:
			c = [[NewRSSSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			break;
		case FeedSourceTypeTwitter:
			c = [[NewTwitterSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];						
			break;
		case FeedSourceTypeFacebook:
			c = [[NewFBSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			((NewFBSourceTableViewController*)c).editViewController = editViewController;
			break;
		case FeedSourceTypeFlickr:
			c = [[NewFlickrSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			((NewFlickrSourceTableViewController*)c).editViewController = editViewController;
			break;
		case FeedSourceTypeYouTube:
			c = [[NewYTSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			break;
	}
	c.stream = editViewController.stream;
	c.feed = editViewController.feed;
	[self.navigationController pushViewController:c animated:NO];
	[c release];	
}

#pragma mark Handlers

- (IBAction)handleButtonTapped:(id)sender {
	UIButton *button = (UIButton*)sender;
	SourceTableViewController *c = nil;
	switch (button.tag) {
		case 0: //facebook
			c = [[NewFBSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			((NewFBSourceTableViewController*)c).editViewController = editViewController;
			break;
		case 1: //twitter
			c = [[NewTwitterSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];						
			break;
		case 2: //flickr
			c = [[NewFlickrSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			((NewFlickrSourceTableViewController*)c).editViewController = editViewController;
			break;
		case 3: //YT
			c = [[NewYTSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			break;
		case 4: //RSS
			c = [[NewRSSSourceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];			
			break;
	}
	c.feed = editViewController.feed;
	c.stream = editViewController.stream;
	
	[self.navigationController pushViewController:c animated:YES];
	
	[c release];
}

- (void)handleCloseTapped {
	[editViewController dismissModalViewControllerAnimated:YES];
	[editViewController closeCallback];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Personalize";
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																	 target:self 
																	 action:@selector(handleCloseTapped)];
	self.navigationItem.leftBarButtonItem = closeButton;
	[closeButton release];
	
	scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, 168 * 3 + 2 * 10 +2 * 25);
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
