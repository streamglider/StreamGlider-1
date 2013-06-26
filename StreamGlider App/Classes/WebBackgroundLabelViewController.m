//
//  WebBackgroundLabelViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 24/11/2011.
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

#import "WebBackgroundLabelViewController.h"

@implementation WebBackgroundLabelViewController

@synthesize titleLabel;
@synthesize leftImage;
@synthesize middleImage;
@synthesize rightImage;
@synthesize isActive;

#pragma mark Utility Methods

- (UIImageView*)createImageViewFor:(NSString*)imageName {
    UIImageView *iv = [[UIImageView alloc] init];
    iv.image = [UIImage imageNamed:imageName];
    return [iv autorelease];
}

#pragma mark Properties

- (void)setActive:(BOOL)val {
    if (isActive == val)
        return;
    
    isActive = val;
    
    if (val) {
        leftImage.image = [UIImage imageNamed:@"title_bg_selected_left.png"];
        middleImage.image = [UIImage imageNamed:@"title_bg_selected_middle.png"];
        rightImage.image = [UIImage imageNamed:@"title_bg_selected_right.png"];
    } else {
        leftImage.image = [UIImage imageNamed:@"title_bg_left.png"];
        middleImage.image = [UIImage imageNamed:@"title_bg_middle.png"];
        rightImage.image = [UIImage imageNamed:@"title_bg_right.png"];        
    }    
}
    

#pragma mark UIViewController

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
    self.isActive = NO;
    
    // Do any additional setup after loading the view from its nib.    
    self.leftImage = [self createImageViewFor:@"title_bg_left.png"];
    leftImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    leftImage.frame = CGRectMake(0, 0, 15, 29);
    
    [self.view addSubview:leftImage];
    
    self.middleImage = [self createImageViewFor:@"title_bg_middle.png"];
    middleImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    middleImage.frame = CGRectMake(15, 0, self.view.frame.size.width - 30, 29);
    
    [self.view addSubview:middleImage];
    
    self.rightImage = [self createImageViewFor:@"title_bg_right.png"];
    rightImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    rightImage.frame = CGRectMake(self.view.frame.size.width - 15, 0, 15, 29);
    
    [self.view addSubview:rightImage];    
    
    self.titleLabel = [[[UILabel alloc] init] autorelease];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    titleLabel.textColor = [UIColor colorWithRed:0.643 green:0.706 blue:0.776 alpha:1];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.frame = CGRectMake(5, 0, self.view.frame.size.width - 10, 29);
    
    [self.view addSubview:titleLabel];    
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setLeftImage:nil];
    [self setMiddleImage:nil];
    [self setRightImage:nil];
    
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
    [leftImage release];
    [middleImage release];
    [rightImage release];
        
    [super dealloc];
}

@end
