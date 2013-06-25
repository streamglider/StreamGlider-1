    //
//  TutorialPageViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 20/04/2011.
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

#import "TutorialPageViewController.h"
#import "TutorialViewController.h"
#import "Core.h"


@implementation TutorialPageViewController

@synthesize imageView, firstPage, viewController;

#define FIRST_PAGE_IMAGE_PORTRAIT @"TutorialGridPortrait.png"
#define SECOND_PAGE_IMAGE_PORTRAIT @"TutorialEditPortrait.png"
#define FIRST_PAGE_IMAGE_LANDSCAPE @"TutorialGridLandscape.png"
#define SECOND_PAGE_IMAGE_LANDSCAPE @"TutorialEditLandscape.png"

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *t = [touches anyObject];
	CGPoint pt = [t locationInView:self.view];
	
	float h = self.view.frame.size.height;
	float w = self.view.frame.size.width;
	
	if (firstPage) {
		if (pt.x > (w - 250) && pt.y > (h - 60)) {
			[viewController.navigationController popViewControllerAnimated:YES];
		} else if (pt.x > (w - 250) && pt.y > (h - 120))	{
			[viewController.scrollView setContentOffset:CGPointMake(w, 0) animated:YES];
		}
		
	} else {
		if (pt.x > (w - 250) && pt.y > (h - 60)) {
			[viewController.navigationController popViewControllerAnimated:YES];
		} else if (pt.x < 200 && pt.y > (h - 60))	{
			[viewController.scrollView setContentOffset:CGPointZero animated:YES];
		}
	}
}

#pragma mark UIViewController

- (void)displayImageForOrientation:(UIInterfaceOrientation)orientation {
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		imageView.image = firstPage ? [UIImage imageNamed:FIRST_PAGE_IMAGE_PORTRAIT] : [UIImage imageNamed:SECOND_PAGE_IMAGE_PORTRAIT];
	} else {
		imageView.image = firstPage ? [UIImage imageNamed:FIRST_PAGE_IMAGE_LANDSCAPE] : [UIImage imageNamed:SECOND_PAGE_IMAGE_LANDSCAPE];		
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.imageView = nil;
    [super dealloc];
}


@end
