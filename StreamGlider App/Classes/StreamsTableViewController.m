//
//  StreamsTableViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/20/10.
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

#import "StreamsTableViewController.h"
#import "Config.h"
#import "Core.h"
#import "Stream.h"
#import "StreamTableViewCell.h"
#import "StreamCastViewController.h"
#import "SlideShowViewController.h"
#import "StreamCastStateController.h"
#import "Frame.h"
#import "Feed.h"
#import "SmallFrameViewController.h"
#import "SettingsController.h"
#import "UIColor+SG.h"

@interface StreamsTableViewController ()

@property (nonatomic, retain) IBOutlet StreamTableViewCell *tableViewCell;
@property (nonatomic, retain) NSMutableDictionary *cells;

@end

@implementation StreamsTableViewController {
    int zoomingHeight;
	int currentHeight;	
	StreamTableViewCell *zoomingCell;
	int zFrameIndex;
	
	
	BOOL delayPlayPreviewAnimation;
	
	CGPoint pinchPoint;
	CGPoint framePoint;
	int initialCellOffset;
}

@synthesize tableViewCell, streamCastViewController, cells, zoomingRow, dataWasLoaded;

#pragma mark Zooming

- (void)dropZoom {	
	zoomingCell.scrollView.contentOffset = CGPointMake(zFrameIndex * FRAME_WIDTH, 0);
	
	// change x offset for cell		
	currentHeight = CELL_HEIGHT;
	zoomingHeight = CELL_HEIGHT;
	zFrameIndex = -1;
	zoomingCell.zoomingFrameIndex = -1;
	zoomingRow = -1;	
	
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

- (CGRect)rectForFrame:(Frame*)frame {
	Stream *s = frame.feed.stream;
	int rowIndex = [[Core sharedInstance].streams indexOfObject:s]; 
	StreamTableViewCell *cell = (StreamTableViewCell*)[self.tableView cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:rowIndex inSection:0]];
	
	int shift = cell.scrollView.contentOffset.x / (FRAME_WIDTH + FRAMES_GAP);	
	int len = [s.frames count] - shift;
	int frameIndex = [s.frames indexOfObject:frame inRange:NSMakeRange(shift, len)];	
	
	if (frameIndex == NSNotFound) {
		return CGRectMake(0, 0, 0, 0);
	}
	
	SmallFrameViewController *vc = [cell.frameControllers objectAtIndex:frameIndex];
	
	CGRect rect = vc.view.frame;	
	rect = [cell.scrollView convertRect:rect toView:cell];	
	rect = [cell convertRect:rect toView:streamCastViewController.view];
	
	return rect;
}

- (void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	if (delayPlayPreviewAnimation) {
		[streamCastViewController performSelector:@selector(playPreviewAnimation) 
									   withObject:nil afterDelay:0.3];
	} else {
		[streamCastViewController playPreviewAnimation];
	}
}

- (void)findSurroundingFramesForFrame:(Frame*)frame selectedFrameIndex:(int*)selectedFrameIndex {	
	// get a cell for the frame
	Stream *s = frame.feed.stream;
	int rowIndex = [[Core sharedInstance].streams indexOfObject:s]; 
	StreamTableViewCell *cell = (StreamTableViewCell*)[self.tableView cellForRowAtIndexPath:
								 [NSIndexPath indexPathForRow:rowIndex inSection:0]];
	
	[UIView beginAnimations:@"previewOffsetChanges" context:nil];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	if (cell.scrollView.contentOffset.x < 0)
		cell.scrollView.contentOffset = CGPointZero;
	
    CGFloat frameWidthWithGap = FRAME_WIDTH + FRAMES_GAP;
    
	int shift = cell.scrollView.contentOffset.x / frameWidthWithGap;	
	int len = [s.frames count] - shift;
	int frameIndex = [s.frames indexOfObject:frame inRange:NSMakeRange(shift, len)];	
	
	if (frameIndex == NSNotFound) {
		return;
	}
	
	int screenIndex = frameIndex - shift;
	
	if (screenIndex > 1)
		*selectedFrameIndex = 2;
	else
		*selectedFrameIndex = 0;
	
	delayPlayPreviewAnimation = YES;	
	   
	if (cell.frame.origin.y != self.tableView.contentOffset.y) {
		self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, 
												   cell.frame.origin.y);
        
		delayPlayPreviewAnimation = NO;
    }
	
    CGFloat xOffset = frameIndex * frameWidthWithGap;
    if (xOffset != cell.scrollView.contentOffset.x) {
        delayPlayPreviewAnimation = NO;
        cell.scrollView.contentOffset = CGPointMake(xOffset, 0);
    }
    
	[UIView commitAnimations];	
}

- (void)setZooming:(BOOL)z forCell:(StreamTableViewCell*)cell {
	for (SmallFrameViewController *vc in cell.frameControllers) {
		vc.zooming = z;
	}
}

#pragma mark SettingsDelegate

- (void)propertyChanged:(SettingsPropertyType)propertyName oldValue:(NSObject*)oldValue newValue:(NSObject*)newValue {
	[self.tableView reloadData];
}

#pragma mark CoreDelegate

- (void)activePageWasChangedToPage:(PageOfStreams *)page {    
	[self.tableView reloadData];
}

- (void)streamWasAdded:(Stream*)stream {
	// add new row to the table
	[self.tableView reloadData];
}

- (void)streamWasRemoved:(Stream*)stream index:(NSInteger)index {	
	NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:NO];
	[cells removeObjectForKey:stream.objectID];
}

- (void)streamWasMoved:(Stream*)stream fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	[self.tableView reloadData];
}

#pragma mark Gestures

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		DebugLog(@"in state began...");
		CGPoint pt = [recognizer locationInView:self.tableView];
		NSIndexPath *path = [self.tableView indexPathForRowAtPoint:pt];
		
		zoomingCell = (StreamTableViewCell*)[self.tableView cellForRowAtIndexPath:path];		
		zFrameIndex = [zoomingCell frameIndexForPoint:[recognizer locationInView:zoomingCell]];
		zoomingCell.zoomingFrameIndex = zFrameIndex;
				
		if (zFrameIndex == -1)
			return;		
		
		SmallFrameViewController *zFrameController = [zoomingCell.frameControllers objectAtIndex:zFrameIndex];
		zoomingCell.zoomingFrameOffset = [zoomingCell.scrollView convertPoint:zFrameController.view.center 
																	   toView:zoomingCell].x;
		
		zoomingCell.scrollView.pagingEnabled = NO;
		
		if (zoomingRow != path.row) {
			zoomingHeight = CELL_HEIGHT;
			zoomingRow = path.row;
		}
		currentHeight = zoomingHeight;
		
		[self setZooming:YES forCell:zoomingCell];
			
	} else if (recognizer.state == UIGestureRecognizerStateChanged && zFrameIndex != -1) {	
		int h = zoomingHeight * recognizer.scale;
        
		currentHeight = h;
        
		if (currentHeight < CELL_HEIGHT) {
			currentHeight = CELL_HEIGHT;
		} else if (currentHeight > CELL_HEIGHT * 3.5) {
			SmallFrameViewController *vc = [zoomingCell.frameControllers objectAtIndex:zFrameIndex];
			[StreamCastStateController sharedInstance].animateView = vc.view;
			
			CGRect rect = [zoomingCell.scrollView convertRect:vc.view.frame toView:zoomingCell];
			rect = [zoomingCell convertRect:rect toView:streamCastViewController.view];
			[StreamCastStateController sharedInstance].animateRect = rect;
			
			[[StreamCastStateController sharedInstance] switchToState:StreamLayoutSlideshow];
			streamCastViewController.slideShowViewController.frame = vc.frame;
			streamCastViewController.slideShowViewController.shouldResumeTable = NO;            
			[self dropZoom];
			zoomingCell.scrollView.pagingEnabled = YES;
			[self setZooming:NO forCell:zoomingCell];
		}
		        
        BOOL animationsEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:animationsEnabled];
                
	} else if (recognizer.state == UIGestureRecognizerStateEnded && zFrameIndex != -1) {
                
		float k = (float)currentHeight / (float)CELL_HEIGHT;
		        
		int fw = k * FRAME_WIDTH;	
		int xOffset = (int)zoomingCell.scrollView.contentOffset.x % fw; 
		
		if (xOffset < fw / 2 && xOffset != 0) {
			zoomingCell.scrollView.contentOffset = CGPointMake(zoomingCell.scrollView.contentOffset.x - xOffset, 0);			
		} else {
			zoomingCell.scrollView.contentOffset = CGPointMake(zoomingCell.scrollView.contentOffset.x + (fw - xOffset), 0);			
		}

		zoomingCell.scrollView.pagingEnabled = YES;
		zoomingCell.zoomingFrameIndex = -1;
		
		zoomingHeight = currentHeight;
		[self setZooming:NO forCell:zoomingCell];
	}
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (self.dataWasLoaded)
		return [[Core sharedInstance].streams count];
	else 
		return 0;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.editing) {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
	if (cells == nil) {
		self.cells = [[[NSMutableDictionary alloc] init] autorelease];
	}
	
	Stream *stream = [[Core sharedInstance].streams objectAtIndex:indexPath.row];
	
    StreamTableViewCell *cell = (StreamTableViewCell*)[cells objectForKey:stream.objectID];
    
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"StreamTableViewCell" owner:self options:nil];
		cell = tableViewCell;
		self.tableViewCell = nil;
		
		cell.streamCastViewController = streamCastViewController;
		cell.zoomingFrameIndex = -1;
		cell.animate = NO;
		
		[cells setObject:cell forKey:stream.objectID];
		
		// Configure the cell...
		cell.stream = stream;
		cell.contentView.backgroundColor = [UIColor gridCellBackgroundColor];
    } 
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int delta = 0;
	if ([SettingsController sharedInstance].plusMode) 
		delta = PLUS_MODE_CELL_HEIGHT - CELL_HEIGHT;
	if (indexPath.row == zoomingRow) {
		return currentHeight + delta;
	}
    
	return CELL_HEIGHT + delta;
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	zoomingRow = -1;
	zoomingHeight = CELL_HEIGHT;
	self.dataWasLoaded = NO;
	
	[[Core sharedInstance] addCoreDelegate:self];
	
	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];	
	[self.tableView addGestureRecognizer:pinch];	
	[pinch release];
	
	[[SettingsController sharedInstance] addDelegate:self forProperty:SettingsPropertyTypePlusMode];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;
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
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
	NSArray *visibleCells = [self.tableView visibleCells];
	for (StreamTableViewCell *cell in visibleCells) {
		[cell releaseFrames];
	}
	
	// clear cells cache
	NSMutableSet *toDelete = [[NSMutableSet alloc] init];
	for (NSString *key in [cells allKeys]) {
		StreamTableViewCell *cell = [cells objectForKey:key];
		if (![visibleCells containsObject:cell]) {
			[toDelete addObject:key];
		}
	}	
	
	for (NSString *key in toDelete) {
		DebugLog(@"removing row %@, memory warning handling", key);
		[cells removeObjectForKey:key];
	}
	
	[toDelete release];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.tableViewCell = nil;
	self.cells = nil;
	[[Core sharedInstance] removeCoreDelegate:self]; 
    [super dealloc];
}


@end

