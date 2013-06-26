//
//  MagModeViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 31/10/2011.
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

#import "MagModeViewController.h"
#import "UIColor+SG.h"
#import "MagPage.h"
#import "FixedMagPageLayout.h"
#import "FixedMagPageLayout1.h"
#import "FixedMagPageLayout2.h"
#import "MagArticle.h"
#import "RSSArticleViewController.h"
#import "MultiFrameArticleViewController.h"
#import "ImageArticleViewController.h"
#import "Frame.h"
#import "Feed.h"
#import "FeedSource.h"
#import "Core.h"
#import "UIColor+SG.h"
#import "FrameIterator.h"
#import "FBFeed.h"
#import "PageBarViewController.h"
#import "PageOfStreams.h"
#import "PreviewFactory.h"
#import "PreviewViewController.h"
#import "StreamCastStateController.h"
#import "StreamCastViewController.h"
#import "AboutViewController.h"
#import "Stream.h"
#import "SendStreamViewController.h"
#import "ArticleRetriever.h"
#import "StreamsPopoverViewController.h"
#import "StreamsPopoverTableViewController.h"
#import "ButtonWithBadge.h"
#import "IncomingStreamsController.h"

@interface MagModeViewController ()

@property (nonatomic, retain) ArticleRetriever *articleRetriever;

@property (nonatomic, retain) UIPageViewController *pageViewController;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain) NSMutableArray *componentVCs;
@property (nonatomic, retain) NSMutableArray *pages;
@property (nonatomic, retain) NSMutableArray *pageVCs;
@property (nonatomic, retain) FrameIterator *iterator;
@property (retain, nonatomic) IBOutlet PageBarViewController *pageBarVC;
@property (retain, nonatomic) IBOutlet UILabel *streamTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *streamsPopoverButton;
@property (retain, nonatomic) UIPopoverController *sharePopover;
@property (retain, nonatomic) UIPopoverController *streamsPopover;
@property (nonatomic, retain) ButtonWithBadge *sharedStreamsButton;

- (IBAction)handleGridTapped:(id)sender;
- (IBAction)handleSharedStreamsTapped:(id)sender;
- (IBAction)handleEditTapped:(id)sender;
- (IBAction)handleInfoTapped:(id)sender;
- (IBAction)handleStreamsPopoverTapped:(id)sender;

@end

@implementation MagModeViewController {
    int currentPageIndex;    
    int nextLayout;        
    BOOL movingForward;
}

@synthesize stream;
@synthesize pages;
@synthesize pageVCs;
@synthesize iterator;
@synthesize pageBarVC;
@synthesize previewVC;
@synthesize streamTitleLabel;
@synthesize streamsPopoverButton;
@synthesize openStreamsPanel;
@synthesize sharePopover;
@synthesize articleRetriever;
@synthesize streamsPopover;
@synthesize pageViewController;
@synthesize scrollView;
@synthesize componentVCs;
@synthesize sharedStreamsButton;

#pragma mark Utility Methods

- (BOOL)isVersionFive {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0;
}

- (void)updateScrollView {
    CGFloat shift = 0;
    CGRect r = scrollView.frame;
    r.origin = CGPointZero;
    for (UIViewController *c in pageVCs) {
        r.origin = CGPointMake(shift, 0);
        shift += r.size.width;
        c.view.frame = r;
    }
    scrollView.contentSize = CGSizeMake([pageVCs count] * r.size.width, r.size.height);    
    scrollView.contentOffset = CGPointMake(currentPageIndex * r.size.width, 0);    
}

- (void)layoutPageForOrientation:(UIInterfaceOrientation)orientation pageIndex:(int)pageIndex {
    MagPage *page = [pages objectAtIndex:pageIndex];
    UIViewController *pvc = [pageVCs objectAtIndex:pageIndex];
    UIView *pageView = pvc.view;
    
    [page layoutArticlesForOrientation:orientation];
    
    int index = 0;
    for (UIView *child in [pageView subviews]) {
        MagArticle *art = [page.articles objectAtIndex:index];
        index++;
        child.frame = art.frame;
    }    
}

- (void)adjustPageToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {   
    if (![self isVersionFive]) {        
        [self updateScrollView];
    }
    
    for (int i = 0; i < [pageVCs count]; i++) {        
        [self layoutPageForOrientation:toInterfaceOrientation pageIndex:i];
    }    
}


- (BOOL)addPage {
    
    MagPage *mp = [[MagPage alloc] init];
    
    mp.iterator = iterator;
    
    mp.stream = stream;
    
    switch (nextLayout) {
        case 0:
            mp.layout = [[[FixedMagPageLayout alloc] init] autorelease];
            break;
        case 1:
            mp.layout = [[[FixedMagPageLayout1 alloc] init] autorelease];
            break;
        case 2:
            mp.layout = [[[FixedMagPageLayout2 alloc] init] autorelease];
            break;            
    }
    
    nextLayout++;
    if (nextLayout > 2)
        nextLayout = 0;
            
    [mp prepareArticlesForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (mp.emptyPage) {
        [mp release];
        return NO;
    }
    
    [pages addObject:mp];
    [mp release];
    
    UIViewController *pageVC = [[[UIViewController alloc] init] autorelease]; 
    [pageVCs addObject:pageVC];
        
    pageVC.view.frame = pageViewController.view.bounds;    
    pageVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    pageVC.view.backgroundColor = [UIColor colorWithRed:0.455 green:0.502 blue:0.557 alpha:1.0];
            
    for (int i = 0; i < mp.layout.spacesCount; i++) {
        MagArticle * art = nil;
        art = [mp.articles objectAtIndex:i];
        
        UIView *v;
        if (art.contentFrame == nil) {
            v = [[UIView alloc] initWithFrame:art.frame];
            v.backgroundColor = [UIColor gridCellBackgroundColor];            
            [pageVC.view addSubview:[v autorelease]];                
        } else if ((art.contentFrame.feed.source.type == FeedSourceTypeFlickr || art.contentFrame.feed.source.type == FeedSourceTypeYouTube) && art.contentFrame != nil) {
            ImageArticleViewController *vc = [[ImageArticleViewController alloc] initWithNibName:@"ImageArticleViewController" bundle:nil];
            vc.magModeVC = self;
            
            vc.frame = art.contentFrame;
            vc.view.frame = art.frame;            
            v = vc.view;
            
            [componentVCs addObject:[vc autorelease]];            
            [pageVC.view addSubview:v];                

        } else if (art.contentFrame.feed.source.type == FeedSourceTypeRSS && art.contentFrame != nil) {
            RSSArticleViewController *vc = [[RSSArticleViewController alloc] initWithNibName:@"RSSArticleViewController" bundle:nil];
            vc.magModeVC = self;
            
            vc.frame = art.contentFrame;
            vc.view.frame = art.frame;
            
            v = vc.view;       
            
            [componentVCs addObject:[vc autorelease]];  
            
            [pageVC.view addSubview:v];                
        } else if (art.contentFrame.feed.source.type == FeedSourceTypeTwitter && art.contentFrame != nil) {
            MultiFrameArticleViewController *vc = [[MultiFrameArticleViewController alloc] initWithNibName:@"MultiFrameArticleViewController" bundle:nil];
            
            vc.magModeVC = self;
            vc.framesList = art.framesList;
            vc.view.frame = art.frame;
            
            v = vc.view;                                    
            
            [componentVCs addObject:[vc autorelease]];            
            [pageVC.view addSubview:v];                
        } else if (art.contentFrame.feed.source.type == FeedSourceTypeFacebook && art.contentFrame != nil) { 
            FBFeed *fbf = (FBFeed*)art.contentFrame.feed;
            if (fbf.photosFeed) {                
                ImageArticleViewController *vc = [[ImageArticleViewController alloc] initWithNibName:@"ImageArticleViewController" bundle:nil];
                
                vc.magModeVC = self;
                vc.frame = art.contentFrame;
                vc.view.frame = art.frame;            
                v = vc.view;
                [componentVCs addObject:[vc autorelease]];            
                [pageVC.view addSubview:v];                
            } else {
                MultiFrameArticleViewController *vc = [[MultiFrameArticleViewController alloc] initWithNibName:@"MultiFrameArticleViewController" bundle:nil];
                
                vc.magModeVC = self;
                vc.framesList = art.framesList;
                vc.view.frame = art.frame;
                
                v = vc.view;                                    
                [componentVCs addObject:[vc autorelease]];            
                [pageVC.view addSubview:v];                
            }            
        }
    }    
    
    return YES;
}

- (void)frameArticleIsReady:(Frame*)frame {
    for (UIViewController *vc in componentVCs) {
        if ([vc isMemberOfClass:[RSSArticleViewController class]]) {
            RSSArticleViewController *artVC = (RSSArticleViewController*)vc;
            if (artVC.frame == frame) {
                [artVC displayFrameData];
                break;
            }
        }
    }
}

- (void)preparePages {
    
    if (![self isVersionFive] && pageVCs != nil) {
        for (UIViewController *vc in pageVCs) {
            [vc.view removeFromSuperview];
        }
    }
    
    if (articleRetriever) 
        articleRetriever.stopRetrieval = YES;
    
    self.articleRetriever = [[[ArticleRetriever alloc] init] autorelease];
    articleRetriever.target = self;
    articleRetriever.action = @selector(frameArticleIsReady:);
    
    [articleRetriever performSelectorInBackground:@selector(retrieveArticlesForStream:) withObject:stream];
    
    // create iterator
    self.iterator = [[[FrameIterator alloc] init] autorelease];
    iterator.stream = stream;
        
    // create first page
    self.pages = [[[NSMutableArray alloc] init] autorelease];
    
    self.pageVCs = [[[NSMutableArray alloc] init] autorelease];
    
    self.componentVCs = [[[NSMutableArray alloc] init] autorelease];
    
    if (![self addPage]) {
        return;
    }    
    
    [self addPage];
    
    currentPageIndex = 0;
    
    UIViewController *pageVC = [pageVCs objectAtIndex:currentPageIndex];
    
    if ([self isVersionFive]) {    
        [pageViewController setViewControllers:[NSArray arrayWithObject:pageVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else {
        [scrollView addSubview:pageVC.view];
        CGRect r = scrollView.frame;
        r.origin = CGPointZero;
        pageVC.view.frame = r;
        
        if ([pageVCs count] > 1) {
            pageVC = [pageVCs objectAtIndex:1];
            [scrollView addSubview:pageVC.view];            
        }   
        
        [self performSelector:@selector(updateScrollView) withObject:nil afterDelay:0.2];
    }
}

#pragma mark UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (!completed)
        return;
    
    if (movingForward) {
        currentPageIndex++;
        [self addPage];
    } else {
        currentPageIndex--;
    }
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (currentPageIndex == 0)
        return nil;
    
    movingForward = NO;
    return [pageVCs objectAtIndex:currentPageIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (currentPageIndex >= [pageVCs count] - 1) {
        return nil;
    }
    
    movingForward = YES;    
    return [pageVCs objectAtIndex:currentPageIndex + 1];
}

#pragma mark Preview Methods

- (void)displayPreviewForFrame:(Frame*)frame {
	self.previewVC = [PreviewFactory createPreviewFor:frame];	
    previewVC.magMode = YES;    

    [self.view addSubview:previewVC.view];
    
	previewVC.frame = frame;
    previewVC.magModeVC = self;
    previewVC.streamCastViewController = [StreamCastStateController sharedInstance].streamCastViewController;
    
    previewVC.view.frame = self.view.frame;
	
    [previewVC play];
}


#pragma mark CoreDelegate

- (void)activePageWasChangedToPage:(PageOfStreams *)page {
    
    if ([page.streams count] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    // clear previous stream data
        
    self.stream = [page.streams objectAtIndex:page.magModeIndex];
    
    streamTitleLabel.text = stream.title;
    [self preparePages];    
}

- (void)activeStreamWasChanged {
    PageOfStreams *page = [[Core sharedInstance] getActivePage];
    self.stream = [page.streams objectAtIndex:page.magModeIndex];  
    
    streamTitleLabel.text = stream.title;
    
    [self preparePages];    
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        CGPoint pt = [touch locationInView:streamTitleLabel];
        if ([streamTitleLabel pointInside:pt withEvent:event]) {
            SendStreamViewController *sender;
            if (sharePopover == nil) {
                // display share stream popover
                sender = [[[SendStreamViewController alloc] initWithNibName:@"SendStreamViewController" 
                                                                     bundle:nil] autorelease];
                self.sharePopover = [[[UIPopoverController alloc] initWithContentViewController:sender] autorelease];
                sender.popover = sharePopover;
            } else {
                sender = (SendStreamViewController*)sharePopover.contentViewController;
            }
            
            sender.stream = stream;	
            
            [sharePopover presentPopoverFromRect:streamTitleLabel.bounds inView:streamTitleLabel permittedArrowDirections:UIPopoverArrowDirectionUp 
                                        animated:YES];		    
        }
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
    currentPageIndex = scrollView.contentOffset.x / scrollView.frame.size.width; 
    if (currentPageIndex == ([pageVCs count] - 1)) {
        if ([self addPage]) {
            int index = currentPageIndex + 1;
            UIViewController *pageVC = [pageVCs objectAtIndex:index];            
            [scrollView addSubview:pageVC.view];
            [self updateScrollView];
        }        
    }
}

#pragma mark Handlers

- (IBAction)handleGridTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleSharedStreamsTapped:(id)sender {
    [[StreamCastStateController sharedInstance].streamCastViewController handleSharedStreamsTapped];
}

- (IBAction)handleEditTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];    
    [[StreamCastStateController sharedInstance].streamCastViewController handleEditTapped];    
}

- (IBAction)handleInfoTapped:(id)sender {
	AboutViewController *vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" 
																	bundle:nil];
    vc.shouldKillTimers = NO;
    
	vc.modalPresentationStyle = UIModalPresentationFormSheet;
	vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	vc.navController = self.navigationController;
	[self presentModalViewController:vc animated:YES];
	
	[vc release];
}

- (IBAction)handleStreamsPopoverTapped:(id)sender {
    StreamsPopoverViewController *vc;
    if (streamsPopover == nil) {
        // display share stream popover
        vc = [[[StreamsPopoverViewController alloc] initWithNibName:@"StreamsPopoverViewController" 
                                                             bundle:nil] autorelease];
        self.streamsPopover = [[[UIPopoverController alloc] initWithContentViewController:vc] autorelease];
        vc.tableVC.magModeVC = self;
    } else {
        vc = (StreamsPopoverViewController*)streamsPopover.contentViewController;
    }
    
    [vc.tableVC.tableView reloadData];
        
    [streamsPopover presentPopoverFromRect:streamsPopoverButton.bounds inView:streamsPopoverButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];		    
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
        
    nextLayout = 0;
    
    self.sharedStreamsButton = [[[ButtonWithBadge alloc] initWithFrame:CGRectMake(60, 9, 42, 42)] autorelease];
    [sharedStreamsButton setImage:[UIImage imageNamed:@"share_box.png"] forState:UIControlStateNormal];
    [sharedStreamsButton addTarget:self action:@selector(handleSharedStreamsTapped:) forControlEvents:UIControlEventTouchUpInside];    
    [self.view insertSubview:sharedStreamsButton atIndex:4]; 
    
    [[IncomingStreamsController sharedInstance] addBadgeButton:sharedStreamsButton];
    
    // Do any additional setup after loading the view from its nib.        
    self.view.backgroundColor = [UIColor gridCellBackgroundColor];
    
    [self.view addSubview:pageBarVC.view];
    pageBarVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageBarVC.view.frame = CGRectMake(0, 60, self.view.frame.size.width - 52, 39);    
        
    streamTitleLabel.text = stream.title;
    
    UIView *v;
    if ([self isVersionFive]) {
        // create page VC
        // we are using a string instead of UIPageViewControllerOptionSpineLocationKey const
        // in order to be able to run on iOS 4.3
        NSDictionary *opt = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UIPageViewControllerSpineLocationMin] forKey:@"UIPageViewControllerOptionSpineLocationKey"];
        
        self.pageViewController = [[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:opt] autorelease];
        
        pageViewController.dataSource = self;
        pageViewController.delegate = self;
        
        v = pageViewController.view;
        
    } else {
        // create scroll view
        self.scrollView = [[[UIScrollView alloc] init] autorelease];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        v = scrollView;
    }
    
    [self.view addSubview:v];
    
    CGRect rect = self.view.frame;
    rect.origin.y = 99;
    rect.size.height -= rect.origin.y;
    v.frame = rect;
    
    [self preparePages];   
        
    if (openStreamsPanel) {
        [self performSelector:@selector(handleStreamsPopoverTapped:) withObject:nil afterDelay:0.3];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[Core sharedInstance] killTimers];
    [[Core sharedInstance] addCoreDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[Core sharedInstance] installTimers];  
    [[Core sharedInstance] removeCoreDelegate:self];
    articleRetriever.stopRetrieval = YES;
}

- (void)viewDidUnload
{
    [self setPageBarVC:nil];
    [self setStreamTitleLabel:nil];
    [self setSharePopover:nil];
    [self setStreamsPopover:nil];
    [self setPageViewController:nil];
    [self setScrollView:nil];
    
    [[IncomingStreamsController sharedInstance] removeBadgeButton:sharedStreamsButton];
    [self setSharedStreamsButton:nil];
    
    [self setStreamsPopoverButton:nil];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustPageToInterfaceOrientation:toInterfaceOrientation];  
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (streamsPopover.popoverVisible) {
        [streamsPopover dismissPopoverAnimated:NO];
    }    
}

- (void)dealloc {    
    self.pages = nil;
    self.pageVCs = nil;
    self.iterator = nil;
    self.previewVC = nil;
    self.articleRetriever = nil;
    self.pageViewController = nil;
    self.scrollView = nil;
    
    [[IncomingStreamsController sharedInstance] removeBadgeButton:sharedStreamsButton];
    self.sharedStreamsButton = nil;
    
    self.componentVCs = nil;
    
    [pageBarVC release];
    [sharePopover release];
    [streamsPopover release];
    
    [streamTitleLabel release];
    [streamsPopoverButton release];
    [super dealloc];
}
@end
