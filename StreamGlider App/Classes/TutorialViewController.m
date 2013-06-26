    //
//  TutorialViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 21/04/2011.
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

#import "TutorialViewController.h"
#import "TutorialPageViewController.h"
#import "Core.h"

@interface TutorialViewController ()

@property (nonatomic, retain) TutorialPageViewController *page1;
@property (nonatomic, retain) TutorialPageViewController *page2;

@end

@implementation TutorialViewController

@synthesize scrollView, page1, page2;

#pragma mark UIViewController

- (void)layoutPages {
	page1.view.frame = self.view.frame;
	page2.view.frame = CGRectOffset(self.view.frame, self.view.frame.size.width, 0);
	
	scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, 
										self.view.frame.size.height);
	
	[page1 displayImageForOrientation:self.interfaceOrientation];
	[page2 displayImageForOrientation:self.interfaceOrientation];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [[Core sharedInstance] killTimers];    
    
	UIImage *img = [UIImage imageNamed:@"Background_Pattern_100x100.png"];
	self.view.backgroundColor = [UIColor colorWithPatternImage:img];

	
	page1 = [[TutorialPageViewController alloc] 
										 initWithNibName:@"TutorialPageViewController" 
										 bundle:nil];
	
	page1.firstPage = YES;
	page1.viewController = self;
	
	[scrollView addSubview:page1.view];
	
	page2 = [[TutorialPageViewController alloc] 
										 initWithNibName:@"TutorialPageViewController" 
										 bundle:nil];
	
	page2.firstPage = NO;
	page2.viewController = self;
	
	[scrollView addSubview:page2.view];
	
	[self layoutPages];	
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[Core sharedInstance] installTimers];    
}

- (void)viewDidAppear:(BOOL)animated {
	[self layoutPages];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self layoutPages];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPage1:nil];
    [self setPage2:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.scrollView = nil;
	self.page1 = nil;
	self.page2 = nil;
    [super dealloc];
}


@end
