    //
//  EditWindowViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 28/02/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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

#import "EditWindowViewController.h"
#import "Feed.h"
#import "Core.h"
#import "BrowseTableViewController.h"
#import "FeaturedViewController.h"
#import "PersonalizeViewController.h"
#import "FeedSource.h"
#import "FeedSourceCategory.h"
#import "Stream.h"
#import "EditStreamViewController.h"

@interface EditWindowViewController ()

@property (nonatomic, retain) IBOutlet FeaturedViewController *featuredViewController;
@property (nonatomic, retain) IBOutlet PersonalizeViewController *personalizeViewController;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) NSMutableArray *navVCs;

@end

@implementation EditWindowViewController {
    UIViewController *currentPanel;    
}

@synthesize feed, browseViewController, featuredViewController, 
	personalizeViewController, stream, tabBar, containerView, addedFeeds, editStreamViewController,
	waitView, activityView, navVCs;

#pragma mark Callbacks

- (void)closeCallback {
	if (feed != nil) {
		feed.editing = NO;
	} else {
		for (Feed *f in addedFeeds) {
			f.editing = NO;
		}
		[addedFeeds removeAllObjects];
	}
	[editStreamViewController revertScrollToTheTop];
}

#pragma mark Editing

- (FeedSourceCategory*)searchInCategory:(FeedSourceCategory*)cat source:(FeedSource*)src {
	FeedSourceCategory *ret;
	for (NSObject* obj in cat.children) {		
		if ([obj isMemberOfClass:[FeedSource class]]) {
			if ([obj isEqual:src]) {
				return cat;
			}
		} else {
			ret = [self searchInCategory:(FeedSourceCategory*)obj source:src];
			if (ret != nil)
				return ret;
		}
	}
	
	return nil;
}

- (FeedSourceCategory*)findSourceCategory:(FeedSource*)src {
	if (src.category != nil) {
		return src.category;
	}
	return [self searchInCategory:[Core sharedInstance].rootCategory source:src];
}

- (void)switchToPanel:(UIViewController*)panel {
	[UIView beginAnimations:@"switchPanel" context:nil];
	[UIView setAnimationDuration:0.3];
	
	if (currentPanel != nil) {
		currentPanel.navigationController.view.alpha = 0;
	}
	currentPanel = panel;
	panel.navigationController.view.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)editFeed:(Feed*)newFeed {
	self.feed = newFeed;
	
	if (feed == nil) {
		tabBar.selectedItem = [tabBar.items objectAtIndex:1];
		[self switchToPanel:featuredViewController];		
		self.addedFeeds = [[[NSMutableArray alloc] init] autorelease];
	} else {
		feed.editing = YES;
		// find category of the feed source
		FeedSourceCategory *cat = [self findSourceCategory:feed.source];
		
		if ([tabBar.items count] > 2 && (cat == nil || [cat.title isEqualToString:@"My Feeds"])) {
			// open personalize
			tabBar.selectedItem = [tabBar.items objectAtIndex:2];
			[self switchToPanel:personalizeViewController];
			[personalizeViewController openEditorForSource:feed.source];
		} else if (cat != nil) {
			// open browse
			tabBar.selectedItem = [tabBar.items objectAtIndex:0];
			[self switchToPanel:browseViewController];
			[browseViewController openCategory:cat.parentCategory];
		} else {
            // open featured
			tabBar.selectedItem = [tabBar.items objectAtIndex:1];
			[self switchToPanel:featuredViewController];
        }
	}
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item.tag == 0) {
		[self switchToPanel:browseViewController];
	} else if (item.tag == 1) {
		[self switchToPanel:featuredViewController];
	} else if (item.tag == 2){
		[self switchToPanel:personalizeViewController];
	} 
}


#pragma mark UIViewController

- (void)createNavController:(UIViewController*)rootVC {
	UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:rootVC] autorelease];
    
    [navVCs addObject:nc];
    
	nc.navigationBar.barStyle = UIBarStyleBlackOpaque;
	nc.navigationBar.frame = CGRectMake(0, 0, 0, 44);
	[nc.navigationBar sizeToFit];
	nc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	CGRect rect = containerView.frame;
	rect.origin = CGPointMake(0, 0);
	nc.view.frame = rect;
	
	[containerView addSubview:rootVC.navigationController.view];
	rootVC.navigationController.view.alpha = 0;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	// create browse view controller
	browseViewController.editViewController = self;
	browseViewController.leafPage = NO;
	browseViewController.category = [Core sharedInstance].rootCategory;	
	
    self.navVCs = [[[NSMutableArray alloc] init] autorelease];
    
	// create browser nav controller
	[self createNavController:browseViewController];
	
	// featured panel
	featuredViewController.editViewController = self;	
	// create featured nav controller
	[self createNavController:featuredViewController];
		
	// personalized panel		
	// create featured nav controller
	[self createNavController:personalizeViewController];
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
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [self setBrowseViewController:nil];
    [self setFeaturedViewController:nil];
    [self setPersonalizeViewController:nil];
    [self setTabBar:nil];
    [self setContainerView:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
    [self setNavVCs:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.feed = nil;	
	
	self.browseViewController = nil;
	self.featuredViewController = nil;
	self.personalizeViewController = nil;
	
	self.tabBar = nil;
	self.containerView = nil;
	self.addedFeeds = nil;
	
	self.waitView = nil;
	self.activityView = nil;
    self.navVCs = nil;
	
    [super dealloc];
}


@end
