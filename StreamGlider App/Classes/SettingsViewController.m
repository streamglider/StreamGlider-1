//
//  SettingsViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 05/05/2011.
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

#import "SettingsViewController.h"
#import "SettingsTableViewController.h"


@implementation SettingsViewController

@synthesize rootViewController, navController;

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	navController.navigationBar.frame = CGRectMake(0, 0, 0, 44);
	[navController.navigationBar sizeToFit];
	navController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	navController.view.frame = self.view.frame;
	
	[self.view addSubview:rootViewController.navigationController.view];	
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
    [self setRootViewController:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [rootViewController viewWillDisappear:animated];
}

#pragma mark Lifecycle

- (void)dealloc {
	self.rootViewController = nil;
	self.navController = nil;
    [super dealloc];
}


@end
