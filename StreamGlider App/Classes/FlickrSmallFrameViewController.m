//
//  FlickrSmallFrameViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 05/10/2010.
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

#import "FlickrSmallFrameViewController.h"
#import "FlickrFrame.h"
#import "CacheController.h"
#import "Feed.h"
#import "Stream.h"
#import "HighlightedTextView.h"
#import "FlickrSmallFrameView.h"


@implementation FlickrSmallFrameViewController

@synthesize imageView, titleLabel, logoImage, sourceBarView;

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
	
	FlickrFrame *ff = (FlickrFrame*)frame;
	if (ff != nil) {		
		titleLabel.text = ff.title;
		
		UIImage *img;
		if (showThumbnail) {
			img = [[CacheController sharedInstance] getImage:ff.thumbURL];
			imageView.contentMode = UIViewContentModeScaleAspectFill;
		} else {
			img = [[CacheController sharedInstance] getImage:ff.imageURL];
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
	
	((FlickrSmallFrameView*)self.view).titleLabelInsets = titleLabel.insets;
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
	self.imageView = nil;
	self.titleLabel = nil;
	self.logoImage = nil;
	self.sourceBarView = nil;
	
    [super dealloc];
}


@end
