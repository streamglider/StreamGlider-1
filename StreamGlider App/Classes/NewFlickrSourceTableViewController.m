//
//  NewFlickrSourceTableViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 05/10/2010.
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

#import "NewFlickrSourceTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Core.h"
#import "FeedSource.h"
#import "NamedFieldTableViewCell.h"
#import "SegmentedControlTableViewCell.h"
#import "NSString+OAuth.h"
#import "AuthFlickr.h"
#import "OAuthCore.h"
#import "FeedSource.h"
#import "Feed.h"
#import "ImageTableViewCell.h"
#import "Stream.h"
#import "EditWindowViewController.h"
#import "LocationController.h"

@interface NewFlickrSourceTableViewController ()

@property (nonatomic, retain) NSMutableString *receivedData;

@end

@implementation NewFlickrSourceTableViewController {
	BOOL isUserSelected;				
	BOOL titleWasEdited;  
    BOOL locationEnabled;
}

@synthesize titleString, queryString, receivedData, editViewController;

static NSString *UserURL = @"http://api.flickr.com/services/rest/?method=flickr.people.getPhotos&extras=date_upload,owner_name&user_id=";
static NSString *SearchURL = @"http://api.flickr.com/services/rest/?method=flickr.photos.search&extras=date_upload,owner_name&content_type=7&text=";
static NSString *UserLookupURL = @"http://api.flickr.com/services/rest/?method=flickr.people.findByUsername&username=";

#pragma mark User Lookup

- (void)findUserID {
	editViewController.waitView.hidden = NO;
	[editViewController.activityView startAnimating];	
	NSMutableString *str = [[NSMutableString alloc] init];
	self.receivedData = str;
	[str release];
		
	// perform user ID lookup
	AuthFlickr *auth = (AuthFlickr*)[[OAuthCore sharedInstance] getOAuthForRealm:FLICKR_REALM];
	NSString *urlString = [NSString stringWithFormat:@"%@%@&api_key=%@", 
						   UserLookupURL, 
						   [NSString URLEncodeString:queryString], 
						   auth.apiKey];
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	[con release];
}

#pragma mark NSURLConnectionDelegate

 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	 NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	 
	 if (str != nil)
		 [self.receivedData appendString:str];
	 
	 [str release];	
 }
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	 	 
	 NSRange rngStart = [receivedData rangeOfString:@"nsid=\""];
	 if (rngStart.location != NSNotFound) {
		 NSRange rng;
		 rng.location = rngStart.location;
		 rng.length = [receivedData length] - rng.location;
		 NSRange rngEnd = [receivedData rangeOfString:@"\">" options:NSCaseInsensitiveSearch range:rng];
		 rng.location = rngStart.location + rngStart.length;
		 rng.length = rngEnd.location - rng.location;
		 NSString *userID = [receivedData substringWithRange:rng];
		 feedSource.URLString = [NSString stringWithFormat:@"%@%@", UserURL, userID];
		 [[Core sharedInstance] addSource:feedSource];				
		 [self createOrEditFeed];
		 [self.navigationController popViewControllerAnimated:YES];		 
	 } else {
		 UIAlertView *msgView = [[UIAlertView alloc] initWithTitle:@"User Lookup" 
														   message:@"A user with the specified name was not found." 
														  delegate:nil 
												 cancelButtonTitle:@"OK" 
												 otherButtonTitles:nil];
		 [msgView show];
		 [msgView release];
	 }
	 editViewController.waitView.hidden = YES;
	 [editViewController.activityView stopAnimating];		 
 }
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	 //TODO: display something to user
	 editViewController.waitView.hidden = YES;
	 [editViewController.activityView stopAnimating];	
	 NSLog(@"failed, error: %@", error);	
}

#pragma mark Handlers

- (void)handleDoneButtonTapped {
	feedSource.title = titleString;
	if (isUserSelected) {
		[self resignEditing];
		[self findUserID];
	} else {
		feedSource.URLString = [NSString stringWithFormat:@"%@%@", SearchURL, [NSString URLEncodeString:queryString]];
                
        if (locationEnabled) {
            CLLocation *loc = [LocationController sharedInstance].location;
            if (loc != nil) {
                feedSource.URLString = [NSString stringWithFormat:@"%@&lat=%+.6f&lon=%+.6f&radius=10", feedSource.URLString, loc.coordinate.latitude, loc.coordinate.longitude];                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Error" message:@"Unfortunately we don't have access to your location now." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
                [alert show];
                [alert release];                
            }
        }
        
		[[Core sharedInstance] addSource:feedSource];				
		[self createOrEditFeed];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark Prepopulating

- (void)prepopulateFields {
	if (feed != nil && feed.source.type == FeedSourceTypeFlickr) {
		// pre populate fields with data from the source
		self.titleString = feed.source.title;
		isUserSelected = [feed.source.URLString rangeOfString:@"user_id="].location != NSNotFound;
        locationEnabled = [feed.source.URLString rangeOfString:@"radius="].location != NSNotFound;
        
		if (!isUserSelected) {
			// extract query string
			NSRange rng = [feed.source.URLString rangeOfString:@"text="];
			if (rng.location != NSNotFound) {
				rng.location += rng.length;
				rng.length = [feed.source.URLString length] - rng.location;
				NSRange end = [feed.source.URLString rangeOfString:@"&" options:NSCaseInsensitiveSearch range:rng];
				if (end.location != NSNotFound) {
					rng.length = end.location - rng.location;
				}
				self.queryString = [NSString URLDecodeString:[feed.source.URLString substringWithRange:rng]];
			}
		}
	} else {
		self.titleString = @"";
		self.queryString = @"";
		isUserSelected = YES;		
	}
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 2)
        if (!isUserSelected)
            return 3;
        else
            return 2;
	else 
		return 1;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *EditableCellIdentifier = @"EditableCell";
    static NSString *SegmentedCellIdentifier = @"SegmentedCell";
    static NSString *ImageCellIdentifier = @"ImageCell";
    static NSString *CheckCellIdentifier = @"CheckCell";
	
	if (indexPath.section == 0) {
		ImageTableViewCell *cell = (ImageTableViewCell*)[tableView 
														 dequeueReusableCellWithIdentifier:ImageCellIdentifier];
		
		if (cell == nil) {
			cell = [[[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
											 reuseIdentifier:ImageCellIdentifier] autorelease];
			cell.imageName = @"Flickr_Panel_Borderless.png";	
		}
		
		return cell;
	} else if (indexPath.section == 1) {
		SegmentedControlTableViewCell *cell = (SegmentedControlTableViewCell*)[tableView 
																			   dequeueReusableCellWithIdentifier:SegmentedCellIdentifier];
		
		if (cell == nil) {
			cell = [[[SegmentedControlTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
														reuseIdentifier:SegmentedCellIdentifier] autorelease];
			[cell.segmentedControl insertSegmentWithTitle:@"User" atIndex:0 animated:NO];
			[cell.segmentedControl insertSegmentWithTitle:@"Find" atIndex:1 animated:NO];
			cell.segmentedControl.selectedSegmentIndex = 0;
			cell.segmentedControl.selectedSegmentIndex = isUserSelected ? 0 : 1;
			[cell.segmentedControl addTarget:self 
									  action:@selector(handleSegmentSelectionChanged) 
							forControlEvents:UIControlEventValueChanged];
		}
		
		
		return cell;
	} else if (indexPath.section == 2) {
        if (indexPath.row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CheckCellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckCellIdentifier] autorelease];
            }
            
            cell.textLabel.text = @"Search for photos near you";
            if (locationEnabled) 
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
        } else {
            NamedFieldTableViewCell *cell = (NamedFieldTableViewCell*)[tableView 
                                                                     dequeueReusableCellWithIdentifier:EditableCellIdentifier];
            if (cell == nil) {
                cell = [[[NamedFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                                     reuseIdentifier:EditableCellIdentifier] autorelease];			
                if (indexPath.row == 1) {
                    cell.titleValueTextField.text = titleString;
                } else {
                    cell.titleValueTextField.text = queryString;				
                }
            }
            
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Title for this Feed:";
            } else {
                if (isUserSelected) {
                    cell.textLabel.text = @"User Name:";
                } else {
                    cell.textLabel.text = @"Find:";
                }
            }
            
            cell.titleValueTextField.delegate = self;
            cell.titleValueTextField.tag = indexPath.row;
            
            return cell;
        }
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 150;
	} else {
		return tableView.rowHeight;
	}
}

- (void)handleSegmentSelectionChanged {
	isUserSelected = !isUserSelected;
	[self.tableView reloadData];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 2) {
        if (!locationEnabled) {
            if (![LocationController sharedInstance].locationAvailable) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Location services are not available." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];                
                [alert show];
                [alert release];
                
                return;
            }
        }
        
        locationEnabled = !locationEnabled;        
        [self.tableView reloadData];
		doneButton.enabled = ![titleString isEqualToString:@""] && ![queryString isEqualToString:@""];	
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 
	return YES; 
} 

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField.tag == 0 && !titleWasEdited) {
		if (![queryString isEqualToString:titleString]) {
			self.titleString = self.queryString;
			// update the cell
			NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:2];
			NamedFieldTableViewCell *cell = (NamedFieldTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
			cell.titleValueTextField.text = titleString;
		}
		doneButton.enabled = ![titleString isEqualToString:@""] && ![queryString isEqualToString:@""];	
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if (textField.tag == 1) {		
		titleWasEdited = YES;
		self.titleString = value;	
	} else {
		self.queryString = value;
	}
	
	// enable/disable done button
	doneButton.enabled = ![titleString isEqualToString:@""] && ![queryString isEqualToString:@""];	
	
	return YES;
} 

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleWasEdited = NO;
	
	self.title = @"Flickr Feed";
	
	self.feedSource = [[[FeedSource alloc] init] autorelease];
	feedSource.type = FeedSourceTypeFlickr;
	
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.titleString = nil;
	self.queryString = nil;
	self.receivedData = nil;
	
    [super dealloc];
}

@end

