//
//  SocialNetworksViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 01/04/2011.
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

#import "SocialNetworksViewController.h"
#import "Core.h"
#import "StreamCastViewController.h"
#import "NSString+OAuth.h"
#import "NSData+Base64.h"
#import "SettingsTableViewController.h"
#import "UIColor+SG.h"

@interface SocialNetworksViewController ()

@property (nonatomic, retain) SettingsTableViewController *tableViewController;

- (IBAction)handleDoneTapped;

@end

@implementation SocialNetworksViewController

@synthesize tableViewController;

#pragma mark Handlers

- (IBAction)handleDoneTapped {
    [[Core sharedInstance] installTimers];    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	tableViewController = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController" 
																			 bundle:nil];
	tableViewController.viewController = self;
	tableViewController.emailPanel = YES;
	
	[self.view insertSubview:tableViewController.view atIndex:1];
    
	tableViewController.view.frame = CGRectMake(0, 130, self.view.frame.size.width, 
                                                self.view.frame.size.height - 130);	
    
    self.view.backgroundColor = [UIColor socialNetworksBackgroundColor];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [tableViewController viewWillDisappear:animated];
}

#pragma mark Lifecycle

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
	
	self.tableViewController = nil;
    
    [super dealloc];
}


@end
