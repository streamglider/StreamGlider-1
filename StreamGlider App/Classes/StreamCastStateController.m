//
//  StreamCastStateController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 17/12/2010.
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
#import "StreamCastStateController.h"
#import "SlideShowViewController.h"
#import "StreamCastViewController.h"
#import "Core.h"

@interface StreamCastStateController ()

@property (nonatomic, retain) UIImageView *animationImage;

@end

@implementation StreamCastStateController {
	MainScreenLayoutType previousState;    
}

@synthesize streamCastViewController, isPlaying, currentState, animateView, animateRect, animationInProgress, animationImage;

#pragma mark Singleton

static StreamCastStateController *instance = nil;

+ (StreamCastStateController*)sharedInstance {
	if (instance == nil) {
		instance = [[StreamCastStateController alloc] init];		
	}
	
	return instance;		
}

#pragma mark Properties

- (void)setIsPlaying:(BOOL)val {
	if (isPlaying != val) {
		isPlaying = val;
		if (currentState == StreamLayoutTable) {
			if (isPlaying) {
				[streamCastViewController resume];
			} else {
				[streamCastViewController pause];
			}
			[streamCastViewController.slideShowViewController updateButtons];
		} else if (currentState == StreamLayoutSlideshow) {
			if (isPlaying) {
				[streamCastViewController.slideShowViewController resume];
			} else {
				[streamCastViewController.slideShowViewController pause];
			}
			[streamCastViewController updateButtons];
		}
	}
}

#pragma mark Animation

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[animationImage removeFromSuperview];
    self.animationImage = nil;
	
	if (previousState == StreamLayoutTable && currentState == StreamLayoutSlideshow) {
		[streamCastViewController.navigationController pushViewController:streamCastViewController.slideShowViewController 
																 animated:NO];		
	} 
	
	self.animationInProgress = NO;
}

- (UIImageView*)createImageForView:(UIView*)v {
	UIGraphicsBeginImageContext(v.frame.size);
	
	[v.layer renderInContext:UIGraphicsGetCurrentContext()];	
	UIImageView *img = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
	
	UIGraphicsEndImageContext();	
	return [img autorelease];
}

- (void)animateStateTransition {
	if (currentState != previousState) {
		self.animationInProgress = YES;
		CGRect rect = streamCastViewController.view.frame;	
		rect.origin.y += 60;
		rect.size.height -= 60;
        
        UIView *topView = streamCastViewController.navigationController.topViewController.view;
        
		if (currentState == StreamLayoutTable) {
            rect.origin.y += 39;
            rect.size.height -= 39;
			// create frame image				
			self.animationImage = [self createImageForView:animateView];
			animationImage.center = streamCastViewController.view.center;
			streamCastViewController.tableViewContainer.frame = rect;
			
			animationImage.layer.transform = CATransform3DMakeScale(streamCastViewController.slideShowViewController.scale, 
																	streamCastViewController.slideShowViewController.scale, 1);
						
			[streamCastViewController.view addSubview:animationImage];
			
			[streamCastViewController.navigationController popViewControllerAnimated:NO];
			
			[UIView beginAnimations:@"switchToTable" context:nil];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			
			animationImage.frame = CGRectMake(streamCastViewController.view.center.x - FRAME_WIDTH / 2, 
											  streamCastViewController.view.center.y - FRAME_HEIGHT / 2, 
											  FRAME_WIDTH, FRAME_HEIGHT);				
			animationImage.alpha = 0;
			streamCastViewController.tableViewContainer.alpha = 1;
						
			[UIView commitAnimations];	
			
		} else {
			// create frame image				
			self.animationImage = [self createImageForView:animateView];
			animationImage.frame = animateRect;
			
			[topView addSubview:animationImage];
			
			[UIView beginAnimations:@"switchToSlideshow" context:nil];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			
			animationImage.frame = rect;					
			animationImage.alpha = 0;
			streamCastViewController.tableViewContainer.alpha = 0;
									
			[UIView commitAnimations];			
		}
	}
}

#pragma mark State Transitions

#define EDIT_IMAGE @"SOURCES_ICON.png"
#define STREAMS_IMAGE @"STREAMS_ICON.png"

- (void)switchToState:(MainScreenLayoutType)state {	
	if (currentState == StreamLayoutSlideshow || currentState == StreamLayoutTable)	
		previousState = currentState;
	
	currentState = state;
	switch (state) {
		case StreamLayoutSlideshow:	
			if (isPlaying) {
				[[Core sharedInstance] pauseAllStreamsExcept:streamCastViewController.slideShowViewController.stream];			
				[streamCastViewController.slideShowViewController resume];
			} else {
				[[Core sharedInstance] pauseAllStreams];
			}
			
			[self animateStateTransition];
						
			break;
		case StreamLayoutPreview:			
			[streamCastViewController pause];
			[streamCastViewController.slideShowViewController pause];
			break;
		case StreamLayoutBrowser:	
			[streamCastViewController pause];
			[streamCastViewController.slideShowViewController pause];
			break;
		case StreamLayoutTable:						
			[streamCastViewController.slideShowViewController pause];		
						
			if (isPlaying) {
				[[Core sharedInstance] resumeAllStreams];
			}			
			
			[self animateStateTransition];
			
			break;
		case StreamLayoutEditing:
			[[Core sharedInstance] killTimers];
			[streamCastViewController pause];
			[streamCastViewController.slideShowViewController pause];			
			break;
        case StreamLayoutCombined:
            // empty 
            break;
	}
}

- (void)exitBrowser {	
	currentState = previousState;
	switch (currentState) {
		case StreamLayoutTable:
			if (isPlaying)
				[streamCastViewController resume];
			break;
		case StreamLayoutSlideshow:
			if (isPlaying)
				[streamCastViewController.slideShowViewController resume];
			break;
        default:
            // empty
            break;
	}
}

- (void)exitPreview {
	[self exitBrowser];
}

- (void)exitEditing {
	[self exitBrowser];
	[[Core sharedInstance] installTimers];
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		isPlaying = YES;
		currentState = StreamLayoutTable;
		self.animationInProgress = NO;
	}
	return self;
}

@end
