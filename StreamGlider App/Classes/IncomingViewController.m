//
//  IncomingViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 31/08/2011.
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

#import "IncomingViewController.h"
#import "IncomingTableViewController.h"
#import "APIReader.h"
#import "Core.h"
#import "IncomingStreamsController.h"

@interface IncomingViewController ()

@property (nonatomic, retain) IBOutlet UIView *waitView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) IBOutlet IncomingTableViewController *tableVC;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) APIReader *reader;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

- (IBAction)handleCloseTapped;

@end

@implementation IncomingViewController
@synthesize titleLabel;

@synthesize waitView, activityView, tableVC, toolbar, reader;

#pragma mark Handlers

- (IBAction)handleCloseTapped {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
	tableVC.data = (NSArray*)data;
	[tableVC.tableView reloadData];
	waitView.hidden = YES;
	[activityView stopAnimating];
}

- (void)apiLoadFailed:(APIReader*)reader {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shared Stream Load" 
													message:@"There was an error while loading the streams shared with you." 
												   delegate:nil 
										  cancelButtonTitle:@"Close" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	waitView.hidden = YES;
	[activityView stopAnimating];
}


#pragma mark UIViewController

- (void)loadData {
	[reader loadAPIDataFor:@"share_tos.json" withMethod:@"GET" addAuthToken:YES handleAuthError:YES];    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [[IncomingStreamsController sharedInstance] pauseUpdating];
    
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" 
																	style:UIBarButtonItemStyleDone 
																   target:self 
																   action:@selector(handleCloseTapped)];
	
	self.navigationItem.leftBarButtonItem = closeButton;
	
	[closeButton release];
		
	[activityView startAnimating];	
	
	CGRect rect = self.view.frame;
	rect.origin.y = toolbar.frame.size.height;
	rect.size.height -= rect.origin.y;
	
    tableVC.viewController = self;
	tableVC.tableView.frame = rect;
	
	[self.view insertSubview:tableVC.tableView atIndex:1];
	
	NSMutableArray *arr = [toolbar.items mutableCopy];
	[arr addObject:[tableVC editButtonItem]];
	toolbar.items = [arr autorelease];
	
    titleLabel.text = [NSString stringWithFormat:@"Streams shared with: %@", [Core sharedInstance].userEmail];
    
	self.reader = [[[APIReader alloc] init] autorelease];
	reader.delegate = self;
    reader.viewController = self;
    
    [self performSelectorInBackground:@selector(loadData) withObject:nil];
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

- (void)viewWillDisappear:(BOOL)animated {
    [[IncomingStreamsController sharedInstance] markAllViewed];
    [[IncomingStreamsController sharedInstance] resumeUpdating];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
    [self setTableVC:nil];
    [self setToolbar:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.waitView = nil;
	self.activityView = nil;
	self.tableVC = nil;
	self.toolbar = nil;
	self.reader = nil;
	
    [titleLabel release];
    [super dealloc];
}


@end
