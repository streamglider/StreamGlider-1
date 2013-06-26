//
//  OtherStreamTableViewCell.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 13/09/2010.
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

#import "OtherStreamTableViewCell.h"
#import "EditFrameViewController.h"
#import "Stream.h"
#import "EditStreamViewController.h"
#import "Feed.h"
#import "StreamTitleViewController.h"
#import "OtherStreamsTableViewController.h"
#import "Core.h"
#import "ScrollPagingClipView.h"

@interface OtherStreamTableViewCell ()

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *feedControllers;
@property (nonatomic, retain) EditFrameViewController *addNewViewController;

@end

@implementation OtherStreamTableViewCell {
    BOOL DNDStarted;
	int fromIndex;
	int toIndex;
	int gapIndex;
	
	CGPoint feedCenter;
	
	BOOL moving;
	BOOL feedWasAdded;
	HorizontalMoveDirection direction;
	
	NSTimer *moveTimer;
	
	CGPoint touchPoint;
}

#define GAP 20

@synthesize stream, scrollView, feedControllers, editStreamViewController, pagingView, titleViewController, animate,
	addNewViewController;

#pragma mark Title Label

- (void)setUpTitleLabel {
	[self.contentView addSubview:titleViewController.view];
}

- (void)adjustTableForKeyboardWithHeight:(int)kbHeight {
	// reveal this cell if necessary
	OtherStreamsTableViewController *tableVC = editStreamViewController.otherStreamsTableViewController;
	CGRect rect = [editStreamViewController.view convertRect:self.frame fromView:tableVC.tableView];
	
	int aH = tableVC.view.frame.size.height - kbHeight;
	int delta = aH - (rect.origin.y + rect.size.height);
	
	if (delta < 0) {
		CGPoint offset = tableVC.tableView.contentOffset;
		offset.y -= delta;
		[tableVC.tableView setContentOffset:offset animated:YES];
	}
}

#pragma mark DNDTarget

- (void)startMoving:(HorizontalMoveDirection)dir {
	if (!moving) {
		moving = YES;
		direction = dir;
		moveTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self 
														selector:@selector(handleMoveTimerFired:) userInfo:nil repeats:YES];
	}	
}

- (void)stopMoving {
	if (moving) {
		moving = NO;
		[moveTimer invalidate];
		moveTimer = nil;
	}
}

- (void)updateScrollViewForPoint:(CGPoint)point withEvent:(UIEvent*)event {
	// find a frame below the touch point
	int index = 0;	
	for (EditFrameViewController* c in feedControllers) {
		CGPoint framePt = [c.view convertPoint:point fromView:editStreamViewController.view];
		if ([c.view pointInside:framePt withEvent:event]) {
			if (index == gapIndex) {
				toIndex = index + 1;
			} else {
				toIndex = index;
			}
			self.animate = YES;
			[self setNeedsLayout];
			break;
		}
		index++; 
	}
	
	// adjust toIndex in case it's far on the right
	EditFrameViewController *c = [feedControllers lastObject];
	CGPoint framePt = [c.view convertPoint:point fromView:editStreamViewController.view];
	
	if (framePt.x > c.view.frame.size.width)
		toIndex = [feedControllers count];
	
	gapIndex = toIndex;
	
	//check if scroll position should be moved
	CGPoint scrollPt = [self convertPoint:point fromView:editStreamViewController.view];
	
	if (scrollPt.x < FRAME_WIDTH * 1.5) {
		[self startMoving:MoveDirectionLeft];
	} else if (scrollPt.x > self.frame.size.width - FRAME_WIDTH) {
		[self startMoving:MoveDirectionRight];
	} else {
		// cancel moving
		[self stopMoving];
	}

}

- (void)handleMoveTimerFired:(NSTimer*)timer {
	int offsetDelta;
	if (direction == MoveDirectionLeft) {
		if (scrollView.contentOffset.x > 0) {
			offsetDelta = MIN(90, scrollView.contentOffset.x);
			[scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - offsetDelta, 0) animated:YES];
			[self updateScrollViewForPoint:touchPoint withEvent:nil];
		}
	} else {
		int delta = scrollView.contentSize.width - (self.frame.size.width - pagingView.frame.origin.x);
		if (scrollView.contentOffset.x < delta) {
			offsetDelta = MIN(90, delta - scrollView.contentOffset.x);
			[scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + offsetDelta, 0) animated:YES];
			[self updateScrollViewForPoint:touchPoint withEvent:nil];
		}
	}
}

- (void)dragEnter:(EditFrameViewController*)frameController touch:(UITouch*)touch withEvent:(UIEvent*)event 
	frameImageCenter:(CGPoint)frameImageCenter {
	[self stopMoving];
	DNDStarted = YES;
	if (frameController.stream == stream) {
		fromIndex = [feedControllers indexOfObject:frameController];
		[feedControllers removeObjectAtIndex:fromIndex];
		frameController.view.hidden = YES;
	} else {
		fromIndex = -1;
	}
	
	[self updateScrollViewForPoint:frameImageCenter withEvent:event];
}

- (void)dragOver:(EditFrameViewController*)frameController touch:(UITouch*)touch withEvent:(UIEvent*)event 
	frameImageCenter:(CGPoint)frameImageCenter {
	touchPoint = [touch locationInView:editStreamViewController.view];
	[self updateScrollViewForPoint:frameImageCenter withEvent:event];
}

- (void)dragDrop:(EditFrameViewController*)frameController frameImageCenter:(CGPoint)frameImageCenter {
	
	[self stopMoving];
	
	feedCenter = [scrollView convertPoint:frameImageCenter fromView:editStreamViewController.view];
	
	toIndex = MAX(0, toIndex);
	
	if (fromIndex != -1) {		
		// reposition feed
		[feedControllers insertObject:frameController atIndex:toIndex];
		
		frameController.view.hidden = NO;
		if (toIndex != fromIndex) {
			// notify stream
			[stream moveFeed:frameController.feed fromIndex:fromIndex toIndex:toIndex];
		} 
		
	} else {
		// copy feed
		Feed *copy = [frameController.feed copy];
		copy.stream = stream;
		
		[stream insertFeed:copy atIndex:toIndex];		
        [copy release];
	}
	
	DNDStarted = NO;
	fromIndex = -1;
	toIndex = -1;
	
	self.animate = YES;
	
	[self setNeedsLayout];	
}

- (void)dragCancelled:(EditFrameViewController*)frameController {
	[self stopMoving];
	
	if (fromIndex != -1) {
		[feedControllers insertObject:frameController atIndex:fromIndex];
		frameController.view.hidden = NO;		
	}
	DNDStarted = NO;
	fromIndex = -1;
	toIndex = -1;
	[self setNeedsLayout];
}

#pragma mark Properties

- (EditFrameViewController*)createEditFrameVCForFeed:(Feed*)feed {
	EditFrameViewController *c = [[EditFrameViewController alloc] 
								  initWithNibName:@"EditFrameViewController" bundle:nil];
	c.feed = feed;
	c.editStreamViewController = editStreamViewController;
	c.stream = stream;
	return [c autorelease];
}

- (void)setStream:(Stream*)aStream {
	if (stream != nil) {
		[stream removeStreamDelegate:self];
		// remove all feed subviews
		for (EditFrameViewController *c in feedControllers) {
			[c.view removeFromSuperview];
		}		
		
		[addNewViewController.view removeFromSuperview];
	}
		
	stream = aStream;	
	[stream addStreamDelegate:self];
	
	if (stream == nil)
		return;
	
	titleViewController.stream = stream;
	
	self.feedControllers = [[[NSMutableArray alloc] init] autorelease];
	
	// create dummy feed
	self.addNewViewController = [self createEditFrameVCForFeed:nil];		
	[pagingView addSubview:addNewViewController.view];
	addNewViewController.view.frame = CGRectMake(16, 17, FRAME_WIDTH, FRAME_HEIGHT);
	
	((ScrollPagingClipView*)pagingView).additionalView = addNewViewController.view;
	
	// create feed subviews
	for (Feed *feed in stream.feeds) {		
		EditFrameViewController *c = [self createEditFrameVCForFeed:feed];		
		[scrollView addSubview:c.view];
		[feedControllers addObject:c];
	}			
}

#pragma mark StreamDelegate

- (void)feedWasRemoved:(Feed *)feed {
	int count = [feedControllers count];
	for (int i = count - 1; i >= 0; i--) {
		EditFrameViewController *c = [feedControllers objectAtIndex:i];
		if (c.feed == feed) {	
			[c.view removeFromSuperview];						
			[feedControllers removeObject:c];
			break;
		}
	}
	
	self.animate = YES;
	
	[self setNeedsLayout];
}

- (void)feedWasAdded:(Feed*)feed {
	// add new feed frame
	EditFrameViewController *c = [self createEditFrameVCForFeed:feed];
	
	feedWasAdded = YES;
	
	[scrollView insertSubview:c.view atIndex:0];
	[feedControllers insertObject:c atIndex:0];
	
	[scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	
	self.animate = YES;
	
	[self setNeedsLayout];		
}	

- (void)feedWasInserted:(Feed*)feed atIndex:(NSInteger)atIndex {
	// insert 
	EditFrameViewController *c = [self createEditFrameVCForFeed:feed];	
	//position frame
	c.view.center = feedCenter;
	
	[scrollView insertSubview:c.view atIndex:atIndex];
	[feedControllers insertObject:c atIndex:atIndex];
	
	[self setNeedsLayout];	
}

- (void)feedWasMoved:(Feed *)feed fromIndex:(NSInteger)fromInd toIndex:(NSInteger)toInd {
	EditFrameViewController *c = [feedControllers objectAtIndex:toInd];	
	c.view.center = feedCenter;	
	[self setNeedsLayout];
}

#pragma mark UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// layout feed frames
	if (animate) {
		[UIView beginAnimations:@"FeedFramesLayout" context:nil];
		[UIView setAnimationDuration:0.4];
	}
	
	int index = 0;
	for (UIViewController *c in feedControllers) {				
		if (DNDStarted && index == gapIndex)
			index++;
		
		c.view.frame = CGRectMake(index * (FRAME_WIDTH + GAP), 0, FRAME_WIDTH, FRAME_HEIGHT);
		index++;
	}
	
	int count = [feedControllers count];	
	if (DNDStarted)
		count++;
	
	CGSize s = CGSizeMake(count * (FRAME_WIDTH + GAP), FRAME_HEIGHT);
	
	scrollView.contentSize = s;
	
	if (animate) 
		[UIView commitAnimations];
	
	self.animate = NO;
}

#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {		
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark Lifecycle

- (void)dealloc {
	self.feedControllers = nil;
	self.addNewViewController = nil;
	
	stream = nil;
	
	self.scrollView = nil;
	self.pagingView = nil;
	self.titleViewController = nil;
	
    [super dealloc];
}

@end
