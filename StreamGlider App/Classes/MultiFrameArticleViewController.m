//
//  TwitterArticleViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 11/11/2011.
//  Copyright (c) 2011 StreamGlider, Inc. All rights reserved.
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

#import "MultiFrameArticleViewController.h"
#import "Frame.h"
#import "Feed.h"
#import "FeedSource.h"
#import "TwitterLEViewController.h"
#import "FBLEViewController.h"
#import "UIColor+SG.h"
#import "MagModeViewController.h"

@interface MultiFrameArticleViewController () 

@property (nonatomic, retain) NSArray *controllers;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *feedTitleLabel;

@end

@implementation MultiFrameArticleViewController

@synthesize scrollView;
@synthesize feedTitleLabel;
@synthesize magModeVC;
@synthesize framesList;
@synthesize controllers;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    Feed *feed = ((Frame*)[framesList lastObject]).feed;
    
    feedTitleLabel.text = feed.source.title;
    
    scrollView.backgroundColor = [UIColor gridCellBackgroundColor];
    self.view.backgroundColor = [UIColor gridCellBackgroundColor];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[framesList count]];
    CGFloat shift = 0;
    
    for (Frame *f in framesList) {
        UIViewController *vc;
        if (f.feed.source.type == FeedSourceTypeTwitter) {
            vc = [[TwitterLEViewController alloc] initWithNibName:@"TwitterLEViewController" bundle:nil];
            ((TwitterLEViewController*)vc).frame = f;
            ((TwitterLEViewController*)vc).magModeVC = magModeVC;
        } else {
            vc = [[FBLEViewController alloc] initWithNibName:@"FBLEViewController" bundle:nil];
            ((FBLEViewController*)vc).frame = f;            
            ((FBLEViewController*)vc).magModeVC = magModeVC;            
        }
            
        [scrollView addSubview:vc.view];
        
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        CGRect r = vc.view.frame;
        CGSize sz = [vc.view sizeThatFits:r.size];
        
        r.size = sz;
        
        r.origin.y = shift;
        r.size.width = scrollView.frame.size.width;
        
        vc.view.frame = r;
        
        [arr addObject:vc];
        [vc release];
        
        shift += r.size.height;
    }
    
    self.controllers = [arr autorelease];
    
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, shift);    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setControllers:nil];
    
    [self setFeedTitleLabel:nil];
    [self setMagModeVC:nil];
    
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
    [scrollView release];
    [controllers release];
    
    self.framesList = nil;
    
    [feedTitleLabel release];
    [super dealloc];
}
@end
