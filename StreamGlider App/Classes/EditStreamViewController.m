//
//  EditStreamViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/07/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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

#import "EditStreamViewController.h"
#import "Stream.h"
#import "Core.h"
#import "EditFrameViewController.h"
#import "Feed.h"
#import "TwitterFeed.h"
#import "RSSFeed.h"
#import "OtherStreamsTableViewController.h"
#import "YTFeed.h"
#import "FBFeed.h"
#import "FlickrFeed.h"
#import "StreamCastStateController.h"
#import "EditWindowViewController.h"
#import "PageBarViewController.h"

@interface EditStreamViewController ()

@property (nonatomic, retain) IBOutlet EditWindowViewController *editWindowViewController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIButton *editButton;
@property (nonatomic, retain) IBOutlet UIView *toolbarView;
@property (nonatomic, retain) IBOutlet PageBarViewController *pageBarVC;

- (IBAction)handleAddTapped;
- (IBAction)handleBackTapped;
- (IBAction)handleEditTapped;

@end

@implementation EditStreamViewController {
    CGPoint oldScrollPosition;
}

@synthesize pageBarVC;

@synthesize popoverController, editButton,
	otherStreamsTableViewController, editWindowViewController, toolbarView;

#pragma mark Displaying Feeds

- (void)displayEditWindowForFeed:(EditFrameViewController*)feed {
	editWindowViewController.stream = feed.stream;
	[self presentModalViewController:editWindowViewController animated:YES];
	[editWindowViewController editFeed:feed.feed];
}

- (void)scrollStreamToTheTop:(Stream*)stream {
	oldScrollPosition = otherStreamsTableViewController.tableView.contentOffset;
	int index = [[Core sharedInstance].streams indexOfObject:stream];
	NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
	UITableViewCell *cell = [otherStreamsTableViewController.tableView cellForRowAtIndexPath:path];
	CGPoint pt = CGPointMake(0, cell.frame.origin.y);
	[otherStreamsTableViewController.tableView setContentOffset:pt animated:YES];
}

- (void)revertScrollToTheTop {
	[otherStreamsTableViewController.tableView setContentOffset:oldScrollPosition animated:YES];
}

#pragma mark Handlers

- (IBAction)handleEditTapped {
	if (otherStreamsTableViewController.editing) {
		[otherStreamsTableViewController setEditing:NO animated:YES];
		editButton.transform = CGAffineTransformIdentity;		
	} else {
		[otherStreamsTableViewController setEditing:YES animated:YES];		
		editButton.transform = CGAffineTransformMakeRotation(-(M_PI / 2));		
	}
}

- (IBAction)handleAddTapped {
	Stream *s = [[Stream alloc] init];
	s.title = @"New Stream";
	[[Core sharedInstance] addStream:s skipStoring:NO];	
	[s release];	
}

- (IBAction)handleBackTapped {
	[otherStreamsTableViewController dropEditing];	
	[[StreamCastStateController sharedInstance] exitEditing];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageBarVC.editMode = YES;
    [self.view addSubview:pageBarVC.view];
    pageBarVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageBarVC.view.frame = CGRectMake(0, 60, self.view.frame.size.width, 39);
    
	self.title = @"Edit Streams";
		
	editWindowViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	editWindowViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	editWindowViewController.editStreamViewController = self;
	
	UIImage *backgroundImage = [UIImage imageNamed:@"Background_Pattern_100x100.png"];
	otherStreamsTableViewController.tableView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
	
	toolbarView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
				
	otherStreamsTableViewController.editStreamViewController = self;		
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
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [self setPageBarVC:nil];
    [self setEditWindowViewController:nil];
    [self setEditButton:nil];
    [self setOtherStreamsTableViewController:nil];
    [self setToolbarView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.editWindowViewController = nil;
	self.editButton = nil;
	self.popoverController = nil;
	self.otherStreamsTableViewController = nil;
	self.toolbarView = nil;
	
    [pageBarVC release];
    [super dealloc];
}


@end
