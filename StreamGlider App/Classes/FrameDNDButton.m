//
//  FrameDNDButton.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 10/09/2010.
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
#import "FrameDNDButton.h"
#import "EditFrameViewController.h"
#import "EditStreamViewController.h"
#import "Stream.h"
#import "Feed.h"
#import "OtherStreamsTableViewController.h"
#import "OtherStreamTableViewCell.h"


@implementation FrameDNDButton

@synthesize frameViewController, frameImage, cell, tableView;

#pragma mark UIViewController

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


#pragma mark Touches

- (OtherStreamTableViewCell*)findCellForPoint:(CGPoint)point {
	for (OtherStreamTableViewCell *c in [tableView visibleCells]) {	
		CGPoint cellPoint = [c convertPoint:point fromView:frameViewController.editStreamViewController.view];
		
		if ([c pointInside:cellPoint withEvent:nil]) {
			return c;
		}		
	}
	return nil;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[frameViewController moveDNDButton];
	// prepare frame image
	UIGraphicsBeginImageContext(frameViewController.view.frame.size);
	
	[frameViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];	
	self.frameImage = [[[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()] autorelease];
	
	UIGraphicsEndImageContext();
	
	frameImage.alpha = 0.5;
	
	// position frame image
	CGPoint p = [frameViewController.editStreamViewController.view 
				 convertPoint:frameViewController.view.frame.origin 
				 fromView:frameViewController.view.superview];
	
	frameImage.frame = CGRectMake(p.x, p.y, frameImage.frame.size.width, 
								  frameImage.frame.size.height);
	
	// add frame image to the main view
	[frameViewController.editStreamViewController.view addSubview:frameImage]; 	
		
	UITouch *touch = [touches anyObject];
	// find underlying cell
	self.cell = [self findCellForPoint:[touch locationInView:frameViewController.editStreamViewController.view]];
	[cell dragEnter:frameViewController touch:touch withEvent:event frameImageCenter:frameImage.center];
	
	[frameViewController.editStreamViewController.otherStreamsTableViewController dragEnter:frameViewController 
																					  touch:touch 
																				  withEvent:event 
																		   frameImageCenter:frameImage.center];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:frameViewController.editStreamViewController.view];
	CGPoint prevPoint = [touch previousLocationInView:frameViewController.editStreamViewController.view];
	
	float xDelta = point.x - prevPoint.x;
	float yDelta = point.y - prevPoint.y;
		
	frameImage.frame = CGRectMake(frameImage.frame.origin.x + xDelta, 
								  frameImage.frame.origin.y + yDelta, 
								  frameImage.frame.size.width, 
								  frameImage.frame.size.height);
	
	OtherStreamTableViewCell *newCell = [self findCellForPoint:point];
	if (cell != newCell) {
		[cell dragCancelled:frameViewController];		
		self.cell = newCell;		
		[cell dragEnter:frameViewController touch:touch withEvent:event frameImageCenter:frameImage.center];
	} else {
		[cell dragOver:frameViewController touch:touch withEvent:event frameImageCenter:frameImage.center]; 
	}
	
	[frameViewController.editStreamViewController.otherStreamsTableViewController dragOver:frameViewController 
																					 touch:touch 
																				 withEvent:event 
																		  frameImageCenter:frameImage.center];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	[frameImage removeFromSuperview];
	if (cell != nil)
		[cell dragCancelled:frameViewController];
	[frameViewController.editStreamViewController.otherStreamsTableViewController dragCancelled:frameViewController];	
	[self removeFromSuperview];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if (cell != nil) 
		[cell dragDrop:frameViewController frameImageCenter:frameImage.center];
	[frameImage removeFromSuperview];
	[frameViewController.editStreamViewController.otherStreamsTableViewController dragDrop:frameViewController 
																		  frameImageCenter:frameImage.center];
	[self removeFromSuperview];
}

#pragma mark Lifecycle

- (void)dealloc {
	self.frameImage = nil;
	[super dealloc];
}

@end
