//
//  YTSmallFrameViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 21/09/2010.
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

#import "YTSmallFrameViewController.h"
#import "YTFrame.h"
#import "CacheController.h"
#import "Stream.h"
#import "Feed.h"
#import "HighlightedTextView.h"
#import "YTSmallFrameView.h"
#import "DogEarView.h"


@implementation YTSmallFrameViewController

@synthesize titleLabel, imageView, logoImage, sourceBarView;

#pragma mark Source Bar Hiding

- (BOOL)supportsSourceBarHiding {
	return YES;
}

- (UIView*)getSourceBarView {
	return sourceBarView;
}

#pragma mark Displaying Data

- (void)displayFrameData {
	[super displayFrameData];
	
	YTFrame *yf = (YTFrame*)frame;
	if (yf != nil) {
		
		titleLabel.text = yf.title;
		
		// display thumbnail
		UIImage *img;
		
		if (showThumbnail) {
			img = [[CacheController sharedInstance] getImage:yf.thumbURL];
			imageView.contentMode = UIViewContentModeScaleAspectFill;
		} else { 
			img = [[CacheController sharedInstance] getImage:yf.imageURL];
			imageView.contentMode = UIViewContentModeScaleAspectFit;
		}
		
		imageView.image = img;		
	} 
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	titleLabel.fontName = @"HelveticaNeue-Bold";
	titleLabel.color = [UIColor colorWithRed:0.69 green:0.753 blue:0.82 alpha:1];
	titleLabel.fontSize = 13;
	titleLabel.backgroundColor = [UIColor colorWithRed:0.067 green:0.098 blue:0.141 alpha:1]; 
//	titleLabel.highlightColor = [UIColor colorWithRed:0.067 green:0.098 blue:0.141 alpha:1];
	titleLabel.insets = UIEdgeInsetsMake(5, 10, 5, 5);
	titleLabel.oneLiner = NO;
	
	sourceBarView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:CAPTION_BAR_OPACITY];
	
	titleLabel.backgroundColor = [UIColor clearColor];
	logoImage.backgroundColor = [UIColor clearColor];
		
	((YTSmallFrameView*)self.view).titleLabelInsets = titleLabel.insets;
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
    [self setTitleLabel:nil];
    [self setImageView:nil];
    [self setLogoImage:nil];
    [self setSourceBarView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.titleLabel = nil;
	self.imageView = nil;
	imageView.image = nil;
	self.logoImage = nil;
	self.sourceBarView = nil;
	
    [super dealloc];
}


@end
