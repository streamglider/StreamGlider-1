//
//  IncomingTableViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 31/08/2011.
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

#import "IncomingTableViewController.h"
#import "StreamsLoader.h"
#import "APIReader.h"
#import "Stream.h"
#import "Core.h"
#import "IncomingStreamsController.h"

@interface IncomingTableViewController () 

@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, retain) StreamsLoader *loader;
@property (nonatomic, retain) APIReader *apiLoader;

@property (nonatomic, retain) NSMutableArray *downloadedStreams;

@end

@implementation IncomingTableViewController

@synthesize data, streamID, loader, apiLoader, downloadedStreams, viewController;

#pragma mark Remote IDs methods

- (void)collectRemoteIDs {
    downloadedStreams = [[NSMutableArray alloc] init];
    
    for (Stream *s in [Core sharedInstance].streams) {
        if (s.remoteID != nil && ![downloadedStreams containsObject:s.remoteID]) {
            [downloadedStreams addObject:s.remoteID];
        }
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [data count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSDictionary *s = [data objectAtIndex:indexPath.row];
	cell.textLabel.text = [s objectForKey:@"title"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@", [s objectForKey:@"email"]];
    
    NSString *remoteID = [[s objectForKey:@"stream_id"] description];
    
    if ([downloadedStreams containsObject:remoteID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *s = [data objectAtIndex:indexPath.row];
    
    NSNumber *remoteID = [s objectForKey:@"stream_id"];
    BOOL added = [[IncomingStreamsController sharedInstance].addedStreams containsObject:remoteID];
    if (!added) {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }    
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *s = [data objectAtIndex:indexPath.row];
		NSString *sid = [[s objectForKey:@"share_to_id"] description]; 
		
		self.apiLoader = [[[APIReader alloc] init] autorelease];
        apiLoader.viewController = viewController;
		[apiLoader loadAPIDataFor:[NSString stringWithFormat:@"share_tos/%@.json", sid] withMethod:@"DELETE"];
		
		NSMutableArray *arr = [data mutableCopy];
		[arr removeObjectAtIndex:indexPath.row];
		self.data = [arr autorelease];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];		
    }   
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        
		self.loader = [[[StreamsLoader alloc] init] autorelease];
        loader.delegate = self;
		[loader performSelectorInBackground:@selector(loadStreamWithID:) withObject:streamID];
	} 
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSDictionary *s = [data objectAtIndex:indexPath.row];
	self.streamID = [[s objectForKey:@"stream_id"] description];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stream Load" 
													message:@"Do you want to download this stream?" 
												   delegate:self 
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

#pragma mark StreamsLoaderDelegate

- (void)streamLoadFailed {
    
}

- (void)streamWasLoaded:(NSString*)remoteID {
	if (![downloadedStreams containsObject:remoteID]) {
        [downloadedStreams addObject:remoteID];
        [self.tableView reloadData];
    }    
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];	
    [self collectRemoteIDs];
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
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.data = nil;
	self.streamID = nil;
	self.loader = nil;
	self.apiLoader = nil;
    self.downloadedStreams = nil;
	
    [super dealloc];
}


@end

