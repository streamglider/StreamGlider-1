//
//  OtherStreamsTableViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 13/09/2010.
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

#import <QuartzCore/QuartzCore.h>

#import "OtherStreamsTableViewController.h"
#import "Core.h"
#import "OtherStreamTableViewCell.h"
#import "Stream.h"
#import "EditStreamViewController.h"
#import "StreamTitleViewController.h"

@interface OtherStreamsTableViewController ()

@property (nonatomic, retain) IBOutlet OtherStreamTableViewCell *tableViewCell;
@property (nonatomic, retain) NSMutableDictionary *cells;

@end

@implementation OtherStreamsTableViewController {
	BOOL moving;
	VerticalMoveDirection direction;
	
	NSTimer *moveTimer;
	CGPoint touchPoint;	    
}

@synthesize tableViewCell, editStreamViewController, cells;

#pragma mark Editing

- (void)dropEditing {
	for (int i = 0; i < [[Core sharedInstance].streams count]; i++) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
		OtherStreamTableViewCell *cell = (OtherStreamTableViewCell*)[self.tableView 
																	 cellForRowAtIndexPath:path];
		[cell.titleViewController dropEditing];
	}	
}

#pragma mark DNDTarget

- (void)handleMoveTimerFired:(NSTimer*)timer {
	if (direction == MoveDirectionTop) {
		UITableViewCell *firstCell = [[self.tableView visibleCells] objectAtIndex:0];
		if (firstCell) {
			NSIndexPath *path = [self.tableView indexPathForCell:firstCell];
			if (path.row != 0) {
				NSIndexPath *revealPath = [NSIndexPath indexPathForRow:(path.row - 1) inSection:path.section];
				[self.tableView scrollToRowAtIndexPath:revealPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
			} else {
				NSIndexPath *revealPath = [NSIndexPath indexPathForRow:0 inSection:path.section];
				[self.tableView scrollToRowAtIndexPath:revealPath atScrollPosition:UITableViewScrollPositionTop animated:YES];				
			}
		}
	} else {
		UITableViewCell *lastCell = [[self.tableView visibleCells] lastObject];
		if (lastCell) {
			NSIndexPath *path = [self.tableView indexPathForCell:lastCell];
			int rowCount = [self tableView:self.tableView numberOfRowsInSection:path.section];
			if (path.row < (rowCount - 1)) {
				NSIndexPath *revealPath = [NSIndexPath indexPathForRow:(path.row + 1) inSection:path.section];
				[self.tableView scrollToRowAtIndexPath:revealPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
			} else {				
				NSIndexPath *revealPath = [NSIndexPath indexPathForRow:(path.row) inSection:path.section];
				[self.tableView scrollToRowAtIndexPath:revealPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
			}
		}
	}
}

- (void)startMoving:(VerticalMoveDirection)dir {
	if (!moving) {
		direction = dir;
		moving = YES;
		moveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self 
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

- (void)dragEnter:(EditFrameViewController*)frameController touch:(UITouch*)touch withEvent:(UIEvent*)event 
 frameImageCenter:(CGPoint)frameImageCenter {
	
}

- (void)dragOver:(EditFrameViewController*)frameController touch:(UITouch*)touch withEvent:(UIEvent*)event 
frameImageCenter:(CGPoint)frameImageCenter {
	CGPoint pt = [touch locationInView:editStreamViewController.view];
	
	int delta = self.tableView.rowHeight;
	
	if (pt.y < delta) {
		[self startMoving:MoveDirectionTop];
	} else if (pt.y > (self.tableView.frame.size.height - delta)) {
		[self startMoving:MoveDirectionBottom];
	} else {
		[self stopMoving];
	}
}

- (void)dragDrop:(EditFrameViewController*)frameController frameImageCenter:(CGPoint)frameImageCenter {
	[self stopMoving];
}

- (void)dragCancelled:(EditFrameViewController*)frameController {
	[self stopMoving];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[Core sharedInstance].streams count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (cells == nil) {
		self.cells = [[[NSMutableDictionary alloc] init] autorelease];
	}
    
	Stream *stream = [[Core sharedInstance].streams objectAtIndex:indexPath.row];
    OtherStreamTableViewCell *cell = [cells objectForKey:stream.objectID];
	
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OtherStreamTableViewCell" owner:self options:nil];
		cell = tableViewCell;		
		self.tableViewCell = nil;
				
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.editStreamViewController = editStreamViewController;
		
		cell.pagingView.layer.cornerRadius = 15;
		
		UIImage *bImg = [UIImage imageNamed:@"Background_Pattern_100x100.png"];
		cell.contentView.backgroundColor = [UIColor colorWithPatternImage:bImg];
		cell.contentView.opaque = YES;
		
		[cell setUpTitleLabel];
		cell.titleViewController.cell = cell;
		
		cell.animate = NO;
		cell.stream = stream;
		
		[cells setObject:cell forKey:stream.objectID];
    }
    
    // Configure the cell...
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (editingStyle == UITableViewCellEditingStyleDelete) {			
		// delete stream from Core
		Stream *s = [[Core sharedInstance].streams objectAtIndex:indexPath.row];
		[cells removeObjectForKey:s.objectID];
		[[Core sharedInstance] removeStream:s];		
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:UITableViewRowAnimationTop];		
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {	
	Stream *s = [[Core sharedInstance].streams objectAtIndex:fromIndexPath.row]; 
	[[Core sharedInstance] moveStream:s fromIndex:fromIndexPath.row toIndex:toIndexPath.row]; 
}

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark CoreDelegate

- (void)activePageWasChangedToPage:(PageOfStreams *)page {
    [self.tableView reloadData];
}

- (void)streamWasAdded:(Stream*)stream {
	int index = [[Core sharedInstance].streams indexOfObject:stream];
	NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:YES];
	[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];		
	
	[[Core sharedInstance] addCoreDelegate:self];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
}

- (void)viewDidUnload {
    [self setTableViewCell:nil];
    
    [super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.cells = nil;
	[[Core sharedInstance] removeCoreDelegate:self];
    [super dealloc];
}


@end

