//
//  ImageArticleViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 16/11/2011.
//  Copyright (c) 2011 StreamGlider, Inc. All rights reserved.
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

#import "ImageArticleViewController.h"
#import "FlickrFrame.h"
#import "YTFrame.h"
#import "CacheController.h"
#import "UIColor+SG.h"
#import "MagModeViewController.h"

@implementation ImageArticleViewController
@synthesize titleLabel;
@synthesize imageView;
@synthesize ytOverlayView;
@synthesize magModeVC;

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    if (t.tapCount == 1) {
        [magModeVC displayPreviewForFrame:frame];
    }
}


- (void)displayFrameData {
    if ([frame isMemberOfClass:[FlickrFrame class]]) {
        FlickrFrame *ff = (FlickrFrame*)frame;
        imageView.image = [[CacheController sharedInstance] getImage:ff.imageURL];
        titleLabel.text = ff.title;
    } else {
        ytOverlayView.hidden = NO;
        YTFrame *yf = (YTFrame*)frame;
        imageView.image = [[CacheController sharedInstance] getImage:yf.imageURL];
        titleLabel.text = yf.title;        
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor gridCellBackgroundColor];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setImageView:nil];
    [self setYtOverlayView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc {
    [titleLabel release];
    [imageView release];
    [ytOverlayView release];
    [super dealloc];
}
@end
