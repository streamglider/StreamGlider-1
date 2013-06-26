//
//  SlideShowViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 20/10/2010.
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
#import "SlideShowViewController.h"
#import "Core.h"
#import "Frame.h"
#import "Feed.h"
#import "Stream.h"
#import "SmallFrameFactory.h"
#import "SmallFrameViewController.h"
#import "BrowserViewController.h"
#import "StreamCastViewController.h"
#import "StreamCastStateController.h"
#import "FrameView.h"
#import "SlideShowView.h"
#import "SettingsController.h"

@interface SlideShowViewController ()

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) BOOL incremented;

@property (nonatomic, retain) IBOutlet UIButton *playButton;


- (IBAction)handlePauseToggled;
- (IBAction)handleBackTapped;

@end

@implementation SlideShowViewController {
    BOOL skipNextShift;
	BOOL paused;
	BOOL dragging;
	BOOL removeCurrentFrame;
    
	NSMutableArray *otherViews;
	
	UIView *leftView;
	UIView *rightView;
}

@synthesize frame, stream, timer, scrollView, streamCastViewController, incremented, scale, currentView, playButton, shouldResumeTable;

#pragma mark Timer

- (void)startTimer {
	if (timer == nil) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:[SettingsController sharedInstance].cardsInterval
													  target:self 
													selector:@selector(handleTimerFired:) 
													userInfo:nil 
													 repeats:YES];	
	}
}

- (void)stopTimer {
	[timer invalidate];
	self.timer = nil;
}

#pragma mark Slideshow

-(FrameView*)createFrameView:(Frame*)f rect:(CGRect) rect {
	FrameView *fv = [[FrameView alloc] initWithFrame:rect];
	
	fv.streamCastViewController = streamCastViewController;
	fv.theFrame = frame;		
	
	return [fv autorelease];
}

- (void)decrementIndex:(BOOL)noAds {
	self.incremented = YES;
	
	int framesCount = [stream.frames count];
	
	if (framesCount == 0)
		return;
	
	int index = 0;	
	if (frame != nil) {
		index = [stream.frames indexOfObject:frame]; 
		if (index != NSNotFound) {
			index--;
			if (index < 0) {
				index = framesCount - 1;
			}	
		} else {
			index = framesCount - 1;
		}
	}
	
	frame = [stream.frames objectAtIndex:index];	
}

- (void)displayFrame {	
	((SlideShowView*)self.view).dontDoLayout = NO;
	[self.view setNeedsLayout];
	
    self.currentView = [self createFrameView:frame rect:CGRectOffset(scrollView.frame, self.view.frame.size.width,
                                                                     -scrollView.frame.origin.y)];
    [scrollView addSubview:currentView];
}

- (void)moveRight {	
	// populate other frames
	[otherViews addObject:currentView];
	
	if ([SettingsController sharedInstance].removeViewedFrames && removeCurrentFrame) {
		[[Core sharedInstance] removeAllFramesWithURL:((FrameView*)currentView).theFrame.URLString];		
	}
	
	removeCurrentFrame = NO;
	
    self.currentView = [self createFrameView:frame rect:CGRectOffset(scrollView.frame, 0, -scrollView.frame.origin.y)];
	
	[scrollView addSubview:currentView];
	
	[scrollView setContentOffset:CGPointZero animated:YES];	
}

- (void)incrementIndex:(BOOL)noAds {
	self.incremented = NO;
		
	int framesCount = [stream.frames count];
	if (framesCount == 0)
		return;
	
	int index = 0;
	if (frame != nil) {
		index = [stream.frames indexOfObject:frame]; 
		if (index != NSNotFound) {
			index++;
			if (index >= framesCount) {
				index = 0;
			}	
		} else {
			index = 0;
		}
		
	}
	
	frame = [stream.frames objectAtIndex:index];		
}

#pragma mark UIScrollViewDelegate

- (void)clearOthersAndAdjustScrollView {
	// remove other views from scroll view
	for (UIView *v in otherViews) {
		[v removeFromSuperview];
	}
	
	[otherViews removeAllObjects];
	
	// adjust scroll view position
	scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);	
	currentView.frame = CGRectMake(self.view.frame.size.width, 0, 
								   self.view.frame.size.width, scrollView.frame.size.height);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sv {
	[self clearOthersAndAdjustScrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)sv {
	dragging = YES;
	skipNextShift = YES;
	[self stopTimer];
	
	// create left and right frames
	[self decrementIndex:YES];	
	leftView = [self createFrameView:frame rect:CGRectOffset(scrollView.frame, 0, -scrollView.frame.origin.y)];
	[scrollView addSubview:leftView];
	
	[self incrementIndex:YES];
	[self incrementIndex:YES];
	
	rightView = [self createFrameView:frame rect:CGRectOffset(scrollView.frame, 2 * self.view.frame.size.width, 
															  -scrollView.frame.origin.y)];
	[scrollView addSubview:rightView];
	
	[self decrementIndex:YES];	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
	dragging = NO;
	
	if (scrollView.contentOffset.x < self.view.frame.size.width) {
		// change current frame to the left frame
		[otherViews addObject:currentView];
		[otherViews addObject:rightView];
		// 
		if ([SettingsController sharedInstance].removeViewedFrames) {			
			[[Core sharedInstance] removeAllFramesWithURL:((FrameView*)currentView).theFrame.URLString];
		}
		self.currentView = leftView;	
		[self decrementIndex:YES];
		
	} else if (scrollView.contentOffset.x > self.view.frame.size.width) {
		// change current frame to the right frame
		[otherViews addObject:currentView];
		[otherViews addObject:leftView];
		//
		if ([SettingsController sharedInstance].removeViewedFrames) {			
			[[Core sharedInstance] removeAllFramesWithURL:((FrameView*)currentView).theFrame.URLString];
		}
		self.currentView = rightView;		
		[self incrementIndex:YES];
	} else {
		[otherViews addObject:rightView];
		[otherViews addObject:leftView];		
	}
	
	removeCurrentFrame = YES;
	
	[self startTimer];	
	[self clearOthersAndAdjustScrollView];	
}

#pragma mark Properties

- (void)setStream:(Stream*)newStream {	
	stream = newStream;	
	self.title = stream.title;	
}

- (void)setFrame:(Frame*)newFrame {
	skipNextShift = YES;	
	frame = newFrame;
	self.stream = frame.feed.stream;
	
	self.title = stream.title;
	
	[self displayFrame];
}

#pragma mark Handlers

- (void)handleTimerFired:(NSTimer*)t {	
	if (skipNextShift) {
		skipNextShift = NO;
		return;
	}
		
	[self decrementIndex:NO];
	[self moveRight];
}

- (IBAction)handlePauseToggled {
    self.shouldResumeTable = NO;
	[StreamCastStateController sharedInstance].isPlaying = ![StreamCastStateController sharedInstance].isPlaying;
}

- (IBAction)handleBackTapped {	
	StreamCastStateController *sc = [StreamCastStateController sharedInstance];
	sc.animateView = currentView;
	[sc switchToState:StreamLayoutTable];
	[currentView removeFromSuperview];
	self.currentView = nil;
    
    if (shouldResumeTable)
        [StreamCastStateController sharedInstance].isPlaying = YES;
}

#pragma mark Play/Pause

- (void)updateButtons {
	NSString *imageName = [StreamCastStateController sharedInstance].isPlaying ? @"PAUSE_ICON.png" : @"PLAY_ICON.png";
	[playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)pause {
	paused = YES;
	[[Core sharedInstance] pauseAllStreams];
	[self stopTimer];
	[self updateButtons];
}

- (void)resume {
	paused = NO;
	[[Core sharedInstance] pauseAllStreamsExcept:stream];
	[self startTimer];
	[self updateButtons];
}

#pragma mark Gestures

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer {
	if (recognizer.state == UIGestureRecognizerStateChanged) {	
		if (!paused)
			[self stopTimer];
		if (recognizer.scale < 1) {
			self.scale = recognizer.scale;
			scrollView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
			if (scale < 0.7) {
				// exit full screen
				[StreamCastStateController sharedInstance].animateView = currentView;
				[[StreamCastStateController sharedInstance] switchToState:StreamLayoutTable];
				scrollView.layer.transform = CATransform3DIdentity;
				[currentView removeFromSuperview];
				self.currentView = nil;
                if (shouldResumeTable)
                    [StreamCastStateController sharedInstance].isPlaying = YES;
			} 
		}
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
		if (!paused)
			[self startTimer];
		scrollView.layer.transform = CATransform3DIdentity;
	}
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	
	removeCurrentFrame = NO;
	
	otherViews = [[NSMutableArray alloc] initWithCapacity:2];
	incremented = YES;
	skipNextShift = NO;
	dragging = NO;
	
	self.scale = 0.7;
	
	UIImage *img = [UIImage imageNamed:@"Background_Pattern_100x100.png"];
	self.view.backgroundColor = [UIColor colorWithPatternImage:img];
		
	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] 
											initWithTarget:self action:@selector(handlePinchGesture:)];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];		
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	((SlideShowView*)self.view).dontDoLayout = NO;
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setPlayButton:nil];
    [self setScrollView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.scrollView = nil;
	self.currentView = nil;
	self.playButton = nil;
	[otherViews release];
    [super dealloc];
}

@end
