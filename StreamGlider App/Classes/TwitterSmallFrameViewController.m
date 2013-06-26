//
//  TwitterSmallFrameViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/22/10.
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

#import "TwitterSmallFrameViewController.h"
#import "TwitterFrame.h"
#import "Feed.h"
#import "StreamCastViewController.h"
#import "CacheController.h"
#import "HighlightedTextView.h"

@implementation TwitterSmallFrameViewController

@synthesize userNameLabel, imageView, profileImage, textView, backImage;

#pragma mark Displaying Data

- (void)displayFrameData {
	[super displayFrameData];
	
	TwitterFrame *tf = (TwitterFrame*)frame;
	if (tf != nil) {				
		textView.text = tf.text;
		userNameLabel.text = tf.userName;
		
		// display profile image
		profileImage.image = [[CacheController sharedInstance] getImage:tf.imageURL];
	} 
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	textView.fontName = @"HelveticaNeue-Bold";
	textView.color = [UIColor colorWithRed:0.69 green:0.753 blue:0.82 alpha:1];
	textView.fontSize = 15;
	textView.insets = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Overriden to allow any orientation.
//    return YES;
//}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setUserNameLabel:nil];
    [self setImageView:nil];
    [self setProfileImage:nil];
    [self setTextView:nil];
    [self setBackImage:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.userNameLabel = nil;
	self.imageView = nil;
	self.profileImage = nil;
	self.textView = nil;
	self.backImage = nil;
    [super dealloc];
}

@end
