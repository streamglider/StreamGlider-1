//
//  StreamCastViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/15/10.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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

#import "StreamCastViewController.h"
#import "Stream.h"
#import "Core.h"
#import "StreamsTableViewController.h"
#import "EditStreamViewController.h"
#import "RSSFrame.h"
#import "Feed.h"
#import "OAuthCore.h"
#import "OAuth.h"
#import "Loader.h"
#import "SlideShowViewController.h"
#import "PreviewFactory.h"
#import "PreviewViewController.h"
#import "CacheController.h"
#import "BrowserViewController.h"
#import "StreamCastStateController.h"
#import "AboutViewController.h"
#import "SmallFrameViewController.h"
#import "SettingsController.h"
#import "TutorialViewController.h" 
#import "IncomingViewController.h"
#import "LoginViewController.h"
#import "MagModeViewController.h"
#import "PageOfStreams.h"
#import "ButtonWithBadge.h"
#import "IncomingStreamsController.h"

@interface StreamCastViewController ()

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *tutorialButton;
@property (nonatomic, retain) IBOutlet UIButton *motifButton;
@property (nonatomic, retain) IBOutlet PageBarViewController *pageBarVC;
@property (nonatomic, retain) StartupAnimationViewController *startupViewController;
@property (retain, nonatomic) IBOutlet UIView *waitView;
@property (nonatomic, retain) ButtonWithBadge *sharedStreamsButton;

- (IBAction)handlePauseToggled;
- (IBAction)handleTutorialTapped;
- (IBAction)handleInfoTapped:(id)sender;
- (IBAction)handleMagModeTapped:(id)sender;

@end

@implementation StreamCastViewController {
    BOOL firstRun;
}

@synthesize waitView;
@synthesize pageBarVC;
@synthesize motifButton;
@synthesize sharedStreamsButton;

@synthesize tableViewController, editViewController, slideShowViewController, previewViewController, 
	playButton, tableView, startupViewController, displayingPreview, tutorialButton,
	tableViewContainer;

#pragma mark Properties

- (void)setPreviewViewController:(PreviewViewController*)pvc {
	if (pvc != previewViewController) {
		[previewViewController release];
		
		previewViewController = pvc;
		[previewViewController retain];
		
		if (previewViewController != nil) {
			playButton.enabled = NO;
		} else {
			playButton.enabled = YES;			
		}
	}
}

#pragma mark Pause/Resume

- (void)updateButtons {
	NSString *imageName = [StreamCastStateController sharedInstance].isPlaying ? @"PAUSE_ICON.png" : @"PLAY_ICON.png";
	[playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)pause {
	[[Core sharedInstance] pauseAllStreams];
	[self updateButtons];
}

- (void)resume {
	[[Core sharedInstance] resumeAllStreams];
	[self updateButtons];
}

#pragma mark Handlers

- (IBAction)handleTutorialTapped {
	TutorialViewController *tvc = [[TutorialViewController alloc] 
								   initWithNibName:@"TutorialViewController" 
								   bundle:nil];
	
	[self.navigationController pushViewController:tvc animated:YES];
	[tvc release];
	
	[tutorialButton removeFromSuperview];
	self.tutorialButton = nil;
}

- (IBAction)handlePauseToggled {
	[StreamCastStateController sharedInstance].isPlaying = ![StreamCastStateController sharedInstance].isPlaying;
}

- (IBAction)handleEditTapped {
	[self setEditing:YES animated:NO];
}

- (IBAction)handleSharedStreamsTapped {
    if (![Core sharedInstance].userEmail) {        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shared Streams" message:@"In order to use shared streams functionality please register with the system." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
	IncomingViewController *ivc = [[IncomingViewController alloc]	initWithNibName:@"IncomingViewController" 
																					 bundle:nil];
	
	ivc.modalPresentationStyle = UIModalPresentationFormSheet;
	ivc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	[self presentModalViewController:ivc animated:YES];
	
	[ivc release];
}

- (IBAction)handleInfoTapped:(id)sender {
	AboutViewController *vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" 
																	bundle:nil];
    vc.shouldKillTimers = YES;
    
	vc.modalPresentationStyle = UIModalPresentationFormSheet;
	vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	vc.navController = self.navigationController;
	[self presentModalViewController:vc animated:YES];
	
	[vc release];
}

- (IBAction)handleMagModeTapped:(id)sender {

    if ([[Core sharedInstance].streams count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Magazine Mode" message:@"This page nas no streams, can't open magazine mode." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    MagModeViewController *mvc = [[MagModeViewController alloc] initWithNibName:@"MagModeViewController" bundle:nil];
    
    int index = [[Core sharedInstance] getActivePage].magModeIndex;
    
    mvc.stream = [[Core sharedInstance].streams objectAtIndex:index];
    mvc.openStreamsPanel = YES;
    
    [self.navigationController pushViewController:mvc animated:YES];
    [mvc autorelease];        
}

#pragma mark Displaying Views

- (void)playPreviewAnimation {	
	[self.previewViewController play];
}

- (void)displayPreviewForFrame:(Frame*)frame {
	[[StreamCastStateController sharedInstance] switchToState:StreamLayoutPreview];	
	
	self.previewViewController = [PreviewFactory createPreviewFor:frame];
	previewViewController.magMode = NO;
    	
	// gather surrounding frames
	int selectedFrameIndex;
	[tableViewController findSurroundingFramesForFrame:frame selectedFrameIndex:&selectedFrameIndex];
		
	previewViewController.firstFrameRect = [tableViewController rectForFrame:frame];
	
	if (previewViewController.firstFrameRect.size.width == 0) {
		self.previewViewController = nil;
		return;
	}
	
	previewViewController.selectedFrameIndex = selectedFrameIndex;
	
	previewViewController.streamCastViewController = self;
	
	previewViewController.view.frame = self.view.frame;
	
	[self.view addSubview:previewViewController.view];
    
	previewViewController.frame = frame;	    
}

- (void)displayViewForFrame:(Frame*)frame {	
	if ([StreamCastStateController sharedInstance].animationInProgress)
		return;
	
	if (self.displayingPreview)
		return;
	else 
		self.displayingPreview = YES;
	
	if (frame == nil) {
		return;
	}
			
	if (tableViewController.zoomingRow != -1) {
		[tableViewController dropZoom];
		[self performSelector:@selector(displayPreviewForFrame:) withObject:frame afterDelay:0.5];
		return;
	}
	[self displayPreviewForFrame:frame];
}

- (void)displayBrowserForFrame:(Frame*)frame {
	
	BrowserViewController *bvc = [Core sharedInstance].browserViewController;
	
	if ([self.navigationController topViewController] == bvc) {
		return;
	}
	
	if (frame == nil) {
		return;
	}
	
	[self.navigationController pushViewController:bvc animated:YES];	
	bvc.frame = frame;			
	
	[[StreamCastStateController sharedInstance] switchToState:StreamLayoutBrowser];
}

- (void)displayBrowserForRequest:(NSURLRequest*)req {
	
	BrowserViewController *bvc = [Core sharedInstance].browserViewController;
	
	if ([self.navigationController topViewController] == bvc) {
		return;
	}
	
	if (req == nil) {
		return;
	}
		
	[self.navigationController pushViewController:bvc animated:YES];	
	bvc.request	= req;		
	
	[[StreamCastStateController sharedInstance] switchToState:StreamLayoutBrowser];
}

#pragma mark LoaderDelegate

static BOOL loaded = NO;

- (void)addPageBar {
    // add page bar
    [self.view addSubview:pageBarVC.view];
    pageBarVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageBarVC.view.frame = CGRectMake(0, 60, self.view.frame.size.width, 39);
}

- (void)dataWasLoaded {
	
	if (!loaded) {		
        
        [waitView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        
        [self performSelectorOnMainThread:@selector(addPageBar) withObject:nil waitUntilDone:YES];
                
		loaded = YES;
		if ([[Core sharedInstance].streams count] != 0)
			slideShowViewController.stream = [[Core sharedInstance].streams objectAtIndex:0];
		
		tableViewController.dataWasLoaded = YES;
        [tableViewController.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		                
        if ([Core sharedInstance].apiToken == nil && firstRun) {
            [[Core sharedInstance] killTimers];
        }        
	}
}

#pragma mark UIViewController

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[[StreamCastStateController sharedInstance] switchToState:StreamLayoutEditing];
	[self.navigationController pushViewController:editViewController animated:YES];		
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
        
    // force init
    [IncomingStreamsController sharedInstance];
    
    self.sharedStreamsButton = [[[ButtonWithBadge alloc] initWithFrame:CGRectMake(60, 9, 42, 42)] autorelease];
    [sharedStreamsButton setImage:[UIImage imageNamed:@"share_box.png"] forState:UIControlStateNormal];
    [sharedStreamsButton addTarget:self action:@selector(handleSharedStreamsTapped) forControlEvents:UIControlEventTouchUpInside];    
    [self.view insertSubview:sharedStreamsButton atIndex:7];
        
    [[IncomingStreamsController sharedInstance] addBadgeButton:sharedStreamsButton];
    
	self.displayingPreview = NO;
	
	// oauth needs access to the root view controller in order to display modal view
	[OAuthCore sharedInstance].streamCastViewController = self;
	
	tableViewController.streamCastViewController = self;
	UIImage *img = [UIImage imageNamed:@"Background_Pattern_100x100.png"];
	tableViewController.tableView.backgroundColor = [UIColor colorWithPatternImage:img];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:img];
	
	slideShowViewController.streamCastViewController = self;
	slideShowViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
					
	[StreamCastStateController sharedInstance].streamCastViewController = self;
	
//	slideShowViewController.view.frame = self.view.frame;
	
	// update logo and build labels
	NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
	NSString *s = [NSString stringWithFormat:@"%@.%@",									
				   				  [dict objectForKey:@"CFBundleShortVersionString"],
				   				  [dict objectForKey:@"CFBundleVersion"]];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject:s forKey:@"version_pref"];	
	
	NSString *installedDate = [defaults objectForKey:@"installed_date"];
	if (installedDate == nil) {
        firstRun = YES;
        [Core sharedInstance].apiToken = nil;
        
        [[OAuthCore sharedInstance] clearAllTokens];
        
		NSDate *d = [[NSDate alloc] init];
		int seconds = [d timeIntervalSince1970];
		installedDate = [NSString stringWithFormat:@"%d", seconds];
		[d release];
		[defaults setObject:installedDate forKey:@"installed_date"];
		
		[[SettingsController sharedInstance] storeDefaults]; 
	} else {
        firstRun = NO;
		[tutorialButton removeFromSuperview];
		self.tutorialButton = nil;
	}

	[defaults synchronize];	
	
	if (!loaded && firstRun) {
        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" 
                                                                        bundle:nil];
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        vc.panelType = LoginPanelTypeFirstRun;
        [self presentModalViewController:vc animated:YES];
        [vc release];
        
	} else {
        [waitView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
		tableViewController.dataWasLoaded = YES;
		[tableViewController.tableView reloadData];
	}
	
	[Loader sharedInstance].delegate = self;
	[[Loader sharedInstance] performSelectorInBackground:@selector(loadWithCore:) withObject:[Core sharedInstance]];	
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
	
	self.startupViewController = nil;
	
	// Release any cached data, images, etc that aren't in use.
	DebugLog(@"!!!got memory warning, attention!!!");
}

- (void)viewDidUnload {
    [self setWaitView:nil];
    [self setPlayButton:nil];
    [self setTutorialButton:nil];
    [self setTableView:nil];
    [self setTableViewContainer:nil];
    
    [[IncomingStreamsController sharedInstance] removeBadgeButton:sharedStreamsButton];
    [self setSharedStreamsButton:nil];    
    
    [self setPageBarVC:nil];
    [self setMotifButton:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.tableViewController = nil;
	self.editViewController = nil;
	self.slideShowViewController = nil;
	self.previewViewController = nil; 
	self.playButton = nil;
	self.tableView = nil;
	self.startupViewController = nil;   
	self.tableViewContainer = nil;
	self.tutorialButton = nil;
    
    [[IncomingStreamsController sharedInstance] removeBadgeButton:sharedStreamsButton];
    self.sharedStreamsButton = nil;
    	
    [motifButton release];
    [pageBarVC release];
    [waitView release];
	[super dealloc];
}

@end
