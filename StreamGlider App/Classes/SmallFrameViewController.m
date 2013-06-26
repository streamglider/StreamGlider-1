//
//  SmallFrameController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 30/07/2010.
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

#import <QuartzCore/QuartzCore.h>
#import "SmallFrameViewController.h"
#import "Feed.h"
#import "StreamCastViewController.h"
#import "StreamTableViewCell.h"
#import "Stream.h"
#import "Frame.h"
#import "Core.h"
#import "DogEarView.h"

@interface SmallFrameViewController ()

@property (nonatomic, retain) NSTimer *hideTimer;

- (void)installHideTimer;
- (void)dismissHideTimer;
- (void)resetHideTimer;

@end

@implementation SmallFrameViewController

@synthesize target, tapAction, doubleTapTarget, doubleTapAction, dogEarView, zooming, grayView, hideTimer, sourceBarIsHidden, contentImage;

#pragma mark Source Bar Hiding

- (BOOL)supportsSourceBarHiding {
	// override in frames that support hiding
	return NO;
}

- (UIView*)getSourceBarView {
	return nil;
}

- (void)hideSourceBarWithAnimation:(BOOL)animated {
	if (![self supportsSourceBarHiding])
		return;
	
	sourceBarIsHidden = YES;
	if (animated) {
		[UIView beginAnimations:@"hidingAnimation" context:nil];
		[UIView setAnimationDuration:0.3];
	}
	
	[self getSourceBarView].alpha = 0;
	dogEarView.alpha = 0;
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)displaySourceBarHandler:(Frame*)f {
	if (![self supportsSourceBarHiding])
		return;
	
	if (!sourceBarIsHidden) {
		[self hideSourceBarWithAnimation:NO];
		return;
	}
	
	sourceBarIsHidden = NO;
	
	[self getSourceBarView].alpha = 1;
	dogEarView.alpha = 1;
	
	[self installHideTimer];
}

- (void)dismissHideTimer {
	[hideTimer invalidate];
	self.hideTimer = nil;
}

- (void)hideTimerHandler {
	[self hideSourceBarWithAnimation:YES];
	
}

- (void)resetHideTimer {
	[self dismissHideTimer];
	[self installHideTimer];
}

- (void)installHideTimer {
	if (!sourceBarIsHidden) {
		self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 
														  target:self 
														selector:@selector(hideTimerHandler) 
														userInfo:nil 
														 repeats:NO];
	}
}

#pragma mark Graying Out

- (void)grayOut {
	grayView.hidden = NO;
}

- (void)cancelGrayOut {
	grayView.hidden = YES;
}

#pragma mark Zooming

- (UIImageView*)createImageForView:(UIView*)v {
	UIGraphicsBeginImageContext(v.frame.size);
	
	[v.layer renderInContext:UIGraphicsGetCurrentContext()];	
	UIImageView *img = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
	
	UIGraphicsEndImageContext();	
	return [img autorelease];
}

- (void)setZooming:(BOOL)nz {
	if (zooming != nz) {
		zooming = nz;
		if (zooming) {
			self.contentImage = [self createImageForView:self.view];
			CGRect rect = self.view.frame;
			rect.origin = CGPointMake(0, 0);
			contentImage.frame = rect;
			contentImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			contentImage.contentMode = UIViewContentModeScaleToFill;
			[self.view addSubview:contentImage];
		} else {
			[contentImage removeFromSuperview];
            self.contentImage = nil;
		}
	}
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *t = [touches anyObject];
	
	if (dogEarView != nil) 
		[[Core sharedInstance] viewFrame:self.frame.URLString];
	
	if (t.tapCount == 1) {
		if (tapAction != nil) {
			UIImageView *iv = [self createImageForView:self.view];
			[Core sharedInstance].cardImage = iv.image;
			[target performSelector:tapAction withObject:frame afterDelay:0.30f];		
		}
	} else if (t.tapCount == 2) {
		if (doubleTapTarget != nil && doubleTapAction != nil) {
			[doubleTapTarget performSelector:doubleTapAction withObject:frame];
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	frame.feed.stream.skipNextFrameAddition = YES;
	
	UITouch *touch = [touches anyObject]; 
	if(touch.tapCount == 2) {
		NSObject *obj = (NSObject*)target;
		[[obj class] cancelPreviousPerformRequestsWithTarget:target selector:tapAction object:frame];
	}
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	zooming = NO;
	if (dogEarView) {
		dogEarView.isNew = NO;
		dogEarView.viewed = [[Core sharedInstance] frameWasViewed:self];
		
		[dogEarView attachSettingsDelegate];
		dogEarView.viewController = self;
	}	
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
    [self setGrayView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	[dogEarView detachSettingsDelegate];
	self.grayView = nil;
	self.dogEarView = nil;
    self.contentImage = nil;
	[self dismissHideTimer];
	
	DebugLog(@"Releasing small frame: %@", [self class]);
	[super dealloc];
}


@end
