//
//  EditFrameViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 01/09/2010.
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

#import "EditFrameViewController.h"
#import "Feed.h"
#import "Stream.h"
#import "EditStreamViewController.h"
#import "FrameDNDButton.h"
#import "RSSFeed.h"
#import "TwitterFeed.h"
#import "YTFeed.h"
#import "FBFeed.h"
#import "FlickrFeed.h"
#import "FeedSource.h"
#import "OtherStreamsTableViewController.h"

@interface EditFrameViewController ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UILabel *feedTypeLabel;
@property (nonatomic, retain) IBOutlet UIView *dummyView;
@property (nonatomic, retain) IBOutlet UILabel *dummyLabel;
@property (nonatomic, retain) IBOutlet FrameDNDButton *moveButton;

- (IBAction)handleDeleteTapped;

@end

@implementation EditFrameViewController

@synthesize titleLabel, feed, editStreamViewController, 
	deleteButton, moveButton, feedTypeLabel, dummyView, dummyLabel, stream;

#pragma mark Handlers

- (IBAction)handleDeleteTapped {
	[feed.stream removeFeed:feed];
}

#pragma mark Displaying Data

- (void)displayFeedData {
	if (feed != nil) {
		[dummyView removeFromSuperview];
		
		if (feed.source != nil)
			titleLabel.text = feed.source.title;
		else 
			titleLabel.text = @"New Feed";
		
		if ([feed isMemberOfClass:[RSSFeed class]]) {
			feedTypeLabel.text = @"RSS Feed"; //Banana
//			feedTypeLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.4 alpha:1];
		} else if ([feed isMemberOfClass:[TwitterFeed class]]) {
			feedTypeLabel.text = @"Twitter Feed";	//Ice		
//			feedTypeLabel.backgroundColor = [UIColor colorWithRed:0.4 green:1 blue:1 alpha:1];
		} else if ([feed isMemberOfClass:[YTFeed class]]){
			feedTypeLabel.text = @"YouTube Feed";	//Sea Foam					
//			feedTypeLabel.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0.502 alpha:1];
		} else if ([feed isMemberOfClass:[FBFeed class]]){
			feedTypeLabel.text = @"Facebook Feed"; //Orchid						
//			feedTypeLabel.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:1 alpha:1];	
//			feedTypeLabel.textColor = [UIColor whiteColor];
		} else {
			feedTypeLabel.text = @"Flickr Feed"; //Orchid						
		}				
	} else {
		dummyLabel.text = [NSString stringWithFormat:@"Tap to Add Feeds to %@", stream.title];
		[stream addStreamDelegate:self];
	}
}

#pragma mark StreamDelegate

- (void)titleWasChanged:(Stream *)s {
	dummyLabel.text = [NSString stringWithFormat:@"Tap to Add Feeds to %@", stream.title];	
}

#pragma mark FeedDelegate

- (void)feedTitleWasChanged:(NSString*)newTitle {
	titleLabel.text = newTitle;
}

- (void)sourceWasChanged:(FeedSource*)newSource {
	[self displayFeedData];
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {	
	UITouch *t = [touches anyObject];
	if (t.tapCount == 1 || t.tapCount == 2) {
		// present change feed popover
		[editStreamViewController displayEditWindowForFeed:self];
		// scroll table to the row
		[editStreamViewController scrollStreamToTheTop:stream];
	}	
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (feed != nil)	
		[feed addFeedDelegate:self];
	
	moveButton.tableView = editStreamViewController.otherStreamsTableViewController.tableView;
	
	[self displayFeedData];	
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
}


- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setDeleteButton:nil];
    [self setMoveButton:nil];
    [self setFeedTypeLabel:nil];
    [self setDummyView:nil];
    [self setDummyLabel:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)moveDNDButton {
	moveButton.center = CGPointMake(0, -moveButton.frame.size.height);	
	[editStreamViewController.view addSubview:moveButton];	
	
	// create a new button in place of moved
	self.moveButton = [[[FrameDNDButton alloc] initWithFrame:CGRectMake(190, 125, 30, 30)] autorelease];
	
	[moveButton setImage:[UIImage imageNamed:@"DND_CARD_ICON.png"] forState:UIControlStateNormal];
	moveButton.frameViewController = self;
	moveButton.tableView = editStreamViewController.otherStreamsTableViewController.tableView;
	[self.view addSubview:moveButton];
}

- (void)dealloc {
	if (feed != nil)
		[feed removeFeedDelegate:self];	
	
	self.feed = nil;
	self.titleLabel = nil;
	self.deleteButton = nil;
	self.moveButton = nil;
	self.feedTypeLabel = nil;
	self.dummyView = nil;
	self.dummyLabel = nil;
	
    [super dealloc];
}


@end
