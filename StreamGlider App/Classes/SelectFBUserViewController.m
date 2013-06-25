//
//  SelectFBUserViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 27/12/2010.
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

#import "SelectFBUserViewController.h"
#import "SelectFBUserTableViewController.h"
#import "NewFBSourceTableViewController.h"
#import "CacheController.h"

@interface SelectFBUserViewController ()

@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) IBOutlet SelectFBUserTableViewController *tableViewController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *selectButton;

- (IBAction)handleCloseTapped;
- (IBAction)handleSelectTapped;

@end

@implementation SelectFBUserViewController {
    NSDictionary *user;
}

@synthesize users, tableViewController, fbTableViewController, selectButton, images;

#pragma mark Callbacks

- (void)userWasSelected:(NSDictionary*)u {
	user = u;
	selectButton.enabled = YES;
}

#pragma mark Handlers

- (void)releaseImages {
	for (NSString *path in images) {
		[[CacheController sharedInstance] releaseImage:path];
	}
}

- (IBAction)handleCloseTapped {
	[self releaseImages];
	[self dismissModalViewControllerAnimated:YES];
	[fbTableViewController selectCancelled];
}

- (IBAction)handleSelectTapped {
	[self releaseImages];
	[self dismissModalViewControllerAnimated:YES];
	[fbTableViewController selectionWasMade:user];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// preload images for FB users
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	for (NSDictionary *u in users) {
		NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", 
							   [u objectForKey:@"id"]];
		NSString *imgPath = [[CacheController sharedInstance] storeImageData:urlString 
																   withThumb:NO];
		[arr addObject:imgPath];
	}
	
	self.images = arr;
	[arr release];
	
	tableViewController.users = users;
	tableViewController.images = images;
	tableViewController.selectViewController = self;
	selectButton.enabled = NO;
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
    [self setTableViewController:nil];
    [self setSelectButton:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.users = nil;	
	self.tableViewController = nil;
	self.selectButton = nil;
	self.images = nil;
    [super dealloc];
}


@end
