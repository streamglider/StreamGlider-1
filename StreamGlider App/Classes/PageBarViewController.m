//
//  PageBarViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 26/10/2011.
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

#import "PageBarViewController.h"
#import "Core.h"
#import "PageOfStreams.h"
#import "PageLabelViewController.h"
#import "UIColor+SG.h"

#define PAGE_LABEL_GAP 5

@interface PageBarViewController ()

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *pages;

@end

@implementation PageBarViewController

@synthesize scrollView, pages, editMode;

#pragma mark Utility Methods

- (void)createPageLabelVC:(PageOfStreams*)page addingPage:(BOOL)addingPage {
    PageLabelViewController *l = [[PageLabelViewController alloc] initWithNibName:@"PageLabelViewController" bundle:nil];
    
    if (page == nil)
        l.newPageButton = YES;
    else
        l.page = page;
    
    l.editMode = editMode;
    l.barVC = self;
    
    [scrollView addSubview:l.view]; 
    
    if (addingPage) 
        [pages insertObject:l atIndex:[pages count] - 1];
    else    
        [pages addObject:l];
    
    [l release];    
}

- (void)layoutPageLabels {
    CGFloat xOffset = PAGE_LABEL_GAP;
    
    for (PageLabelViewController *l in pages) {
        CGRect r = l.view.frame;
        r.origin = CGPointMake(xOffset, 0);
        r.size = [l.view sizeThatFits:CGSizeZero];
        
        l.view.frame = r;
        
        xOffset += r.size.width + PAGE_LABEL_GAP;        
    }
    
    scrollView.contentSize = CGSizeMake(xOffset, scrollView.contentSize.height);    
}

#pragma mark CoreDelegate

- (void)pageWasAdded:(PageOfStreams*)page {        
    if (editMode) {
        [self createPageLabelVC:page addingPage:YES];        
    } else {
        [self createPageLabelVC:page addingPage:NO];
    }    
    
    [self layoutPageLabels];
}

- (void)pageWasRemoved:(PageOfStreams*)page {
    for (PageLabelViewController *l in pages) {
        if (l.page == page) {
            [pages removeObject:l];
            [l.view removeFromSuperview];
            break;
        }        
    }    
    [self layoutPageLabels];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[Core sharedInstance] addCoreDelegate:self];
    
    self.view.backgroundColor = [UIColor gridCellBackgroundColor];
    
    self.pages = [[[NSMutableArray alloc] init] autorelease];
    
    // create labels for pages
    for (PageOfStreams *p in [Core sharedInstance].pages) {
        [self createPageLabelVC:p addingPage:NO];        
    }
    
    if (editMode) {
        // create "new page" pseudo page label
        [self createPageLabelVC:nil addingPage:NO];        
    }    
    
    [self layoutPageLabels];
}

- (void)viewDidUnload
{
    self.scrollView = nil;
    [self setPages:nil];
    
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

#pragma mark Lifecycle

- (void)dealloc {
    [[Core sharedInstance] removeCoreDelegate:self];

    self.scrollView = nil;
    self.pages = nil;
    
    [super dealloc];
}

@end
