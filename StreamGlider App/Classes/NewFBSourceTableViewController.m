//
//  NewFBSourceTableViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 27/09/2010.
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

#import "NewFBSourceTableViewController.h"
#import "Core.h"
#import "FeedSource.h"
#import "NamedFieldTableViewCell.h"
#import "SegmentedControlTableViewCell.h"
#import "NSString+OAuth.h"
#import "OAuthCore.h"
#import "OAuth2.h"
#import "JSON.h"
#import "SelectFBUserViewController.h"
#import "Feed.h"
#import "ImageTableViewCell.h"
#import "Stream.h"
#import "EditWindowViewController.h"

@interface NewFBSourceTableViewController ()

@property (nonatomic, retain) NSDictionary *fbData;
@property (nonatomic, retain) SelectFBUserViewController *selectViewController;
@property (nonatomic, retain) NSArray *albums;

@end

@implementation NewFBSourceTableViewController {
	SelectionType currentSelection;			
	BOOL titleWasEdited;
    
	int selectedAlbum;
	
	BOOL prepopulatingAlbums;
    
    SEL fbDataCallback;    
}

@synthesize titleString, queryString, selectViewController, editViewController, albums, fbData;

static NSString *UserURL = @"https://graph.facebook.com/";
static NSString *SearchURL = @"https://graph.facebook.com/search?q=";
static NSString *AlbumURL = @"https://graph.facebook.com/me/albums?fields=id,name,count&limit=100";

#pragma mark Utility Methods

- (void)getFBData:(NSMutableString*)urlString {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	OAuth2 *oauth = (OAuth2*)[[OAuthCore sharedInstance] getOAuthForRealm:FACEBOOK_REALM];
	
	NSString *normalizedAccessToken = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, 
																						  (CFStringRef)oauth.accessToken, 
																						  NULL, 
																						  (CFStringRef)@"￼|", 
																						  kCFStringEncodingUTF8);	
	
	if (normalizedAccessToken != nil) {
		[urlString appendFormat:@"&access_token=%@", normalizedAccessToken];
        CFRelease(normalizedAccessToken);
    }
	
	DebugLog(@"loading FB, full url: %@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];	
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];	
	
	NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	// read JSON data		
	self.fbData = [receivedString JSONValue];
	
	[receivedString release];
    
	[pool drain];	
    
    [self performSelectorOnMainThread:fbDataCallback withObject:fbData waitUntilDone:NO];
}

#pragma mark Albums

- (void)userAlbumsWereLoaded {
	NSArray *arr = [fbData objectForKey:@"data"];
	
	if (arr == nil) {
		// check if we need to request authentication
		NSDictionary *error = [fbData objectForKey:@"error"];
		NSString *type = [error objectForKey:@"type"];
		if ([type isEqualToString:@"OAuthException"]) {
            [[OAuthCore sharedInstance] requestAuthForRealm:FACEBOOK_REALM withDelegate:self viewController:editViewController askUser:YES reason:@"Facebook authentication is required in order to load albums list."];            
			return;
		}		
	}
	
	self.albums = arr;
	
	if (prepopulatingAlbums) {
		prepopulatingAlbums = NO;
		// extract album id from the URL
		NSRange rng = [feed.source.URLString rangeOfString:@"/" options:NSBackwardsSearch];
		rng.location++;
		NSRange endRng = [feed.source.URLString rangeOfString:@"?"];
		rng.length = endRng.location - rng.location;
		
		NSString *albumID = [feed.source.URLString substringWithRange:rng];
		
		// find corresponding album in the albums array
		int index = 0;
		for (NSDictionary *entry in albums) {
			NSString *s = [entry objectForKey:@"id"];
			if ([s isEqualToString:albumID]) {
				selectedAlbum = index;
				break;
			}
			index++;
		}		
	}
	
	[self.tableView reloadData];
	
	editViewController.waitView.hidden = YES;
	[editViewController.activityView stopAnimating];		    
}

- (void)loadUserAlbums {
	NSMutableString *urlString = [[NSMutableString alloc] initWithString:AlbumURL];
	
    fbDataCallback = @selector(userAlbumsWereLoaded);
    [self performSelectorInBackground:@selector(getFBData:) withObject:urlString];
	
	[urlString release];
}

#pragma mark User Lookup

- (void)selectionWasMade:(NSDictionary*)user {
	self.selectViewController = nil;
	feedSource.URLString = [NSString stringWithFormat:@"%@%@/feed?", UserURL, [user objectForKey:@"id"]];
	
	[[Core sharedInstance] addSource:feedSource];
	
	[self createOrEditFeed];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)selectCancelled {
	self.selectViewController = nil;
}

- (void)userIDWasFound {
	NSArray *arr = [fbData objectForKey:@"data"];
	
	if (arr == nil) {
		// check if we need to request authentication
		NSDictionary *error = [fbData objectForKey:@"error"];
		NSString *type = [error objectForKey:@"type"];
		if ([type isEqualToString:@"OAuthException"]) {
			[[OAuthCore sharedInstance] requestAuthForRealm:FACEBOOK_REALM withDelegate:self viewController:editViewController askUser:YES reason:@"Facebook authentication is required in order to do user lookup."];
			return;
		}		
	}
	
	if ([arr count] == 1) {
		// construct URL and exit
		NSDictionary *userDict = [arr objectAtIndex:0];
		feedSource.URLString = [NSString stringWithFormat:@"%@%@/feed?", UserURL, [userDict objectForKey:@"id"]];
		
		[[Core sharedInstance] addSource:feedSource];
        
		[self createOrEditFeed];
		
		[self.navigationController popViewControllerAnimated:YES];
		
	} else if ([arr count] == 0) {
		// show alert
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Lookup" 
														message:@"A user with the specified name was not found" 
													   delegate:nil 
											  cancelButtonTitle:@"Close" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];		
	} else {				
		// display selection popup
		self.selectViewController = [[[SelectFBUserViewController alloc] 
                                      initWithNibName:@"SelectFBUserViewController" bundle:nil] autorelease];
		selectViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		selectViewController.fbTableViewController = self;
		selectViewController.users = arr;
		[self presentModalViewController:selectViewController animated:YES];
	}	
	
	editViewController.waitView.hidden = YES;
	[editViewController.activityView stopAnimating];    
}

- (void)findUserID {		
	NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@%@&type=user&limit=20", SearchURL, 
								  [NSString URLEncodeString:queryString]];

	fbDataCallback = @selector(userIDWasFound);
	[self performSelectorInBackground:@selector(getFBData:) withObject:urlString];
	
	[urlString release];	
}

#pragma mark OAuthDelegate

- (void)exchangeWasFinished:(id<OAuthProtocol>)oauth {	
	if ([oauth authenticated]) {
		if (currentSelection == SelectionTypeUser) {	
			editViewController.waitView.hidden = YES;
			[editViewController.activityView stopAnimating];
            [self findUserID];
		} else {
            [self loadUserAlbums];
		}
	} else {
		editViewController.waitView.hidden = YES;
		[editViewController.activityView stopAnimating];		
	}
}

#pragma mark Handlers

- (void)handleDoneButtonTapped {
	feedSource.title = titleString;
	
	switch (currentSelection) {
		case SelectionTypeAlbum:	
			// dummy check, doesn't allow variable declaration at the beginning of the block
			if (selectedAlbum == -1)
				return;
			
			NSDictionary *entry = [albums objectAtIndex:selectedAlbum];
			feedSource.URLString = [NSString stringWithFormat:@"%@%@?fields=photos&", 
									UserURL, [entry objectForKey:@"id"]];
			feedSource.title = [entry objectForKey:@"name"];
			
			[self createOrEditFeed];
			
			[self.navigationController popViewControllerAnimated:YES];
			break;
		case SelectionTypeUser:	
			[self resignEditing];
			editViewController.waitView.hidden = NO;
			[editViewController.activityView startAnimating];
            [self findUserID];
			break;
		case SelectionTypeFind:
			feedSource.URLString = [NSString stringWithFormat:@"%@%@&type=post&", SearchURL, 
									[NSString URLEncodeString:queryString]];
			[[Core sharedInstance] addSource:feedSource];
			
			[self createOrEditFeed];
			
			[self.navigationController popViewControllerAnimated:YES];
			break;
	}
}

#pragma mark Prepopulating

- (void)prepopulateFields {
	prepopulatingAlbums = NO;
	if (feed != nil && feed.source.type == FeedSourceTypeFacebook) {
		// pre populate fields with data from the source
		self.titleString = feed.source.title;
		if ([feed.source.URLString rangeOfString:@"search?q="].location != NSNotFound) {
			currentSelection = SelectionTypeFind;
		} else if ([feed.source.URLString rangeOfString:@"fields=photos"].location != NSNotFound) {
			currentSelection = SelectionTypeAlbum;
		} else {
			currentSelection = SelectionTypeUser;
		}
		
		if (currentSelection == SelectionTypeFind) {
			// extract query string
			NSRange rng = [feed.source.URLString rangeOfString:@"search?q="];
			if (rng.location != NSNotFound) {
				rng.location += rng.length;
				rng.length = [feed.source.URLString length] - rng.location;
				NSRange end = [feed.source.URLString rangeOfString:@"&" options:NSCaseInsensitiveSearch range:rng];
				if (end.location != NSNotFound) {
					rng.length = end.location - rng.location;
				}
				self.queryString = [NSString URLDecodeString:[feed.source.URLString substringWithRange:rng]];
			}
		} else if (currentSelection == SelectionTypeAlbum) {
			editViewController.waitView.hidden = NO;
			[editViewController.activityView startAnimating];
			prepopulatingAlbums = YES;
            [self loadUserAlbums];
		}
		
	} else {
		self.titleString = @"";
		self.queryString = @"";
		currentSelection = SelectionTypeUser;
	}
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 2) {
		if (currentSelection == SelectionTypeAlbum) {
			if (albums != nil)
				return [albums count];
			else 
				return 0;
		} else {
			return 2;
		}
	} else {
		return 1;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *EditableCellIdentifier = @"EditableCell";
    static NSString *SegmentedCellIdentifier = @"SegmentedCell";
    static NSString *ImageCellIdentifier = @"ImageCell";
	static NSString *AlbumCellIdentifier = @"AlbumCell";
	
	if (indexPath.section == 0) {
		ImageTableViewCell *cell = (ImageTableViewCell*)[tableView 
														 dequeueReusableCellWithIdentifier:ImageCellIdentifier];
		
		if (cell == nil) {
			cell = [[[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
											 reuseIdentifier:ImageCellIdentifier] autorelease];
			cell.imageName = @"Facebook_Panel_Borderless.png";	
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
			[cell.segmentedControl insertSegmentWithTitle:@"Album" atIndex:2 animated:NO];
			cell.segmentedControl.selectedSegmentIndex = currentSelection;
			[cell.segmentedControl addTarget:self 
									  action:@selector(handleSegmentSelectionChanged:) 
							forControlEvents:UIControlEventValueChanged];
		}
		
		return cell;
	} else if (indexPath.section == 2) {
		if (currentSelection == SelectionTypeAlbum) {
			// TODO create album rows
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
											  reuseIdentifier:AlbumCellIdentifier] autorelease];
			}
			
			NSDictionary *entry = [albums objectAtIndex:indexPath.row];
			cell.textLabel.text = [entry objectForKey:@"name"];
			
			int count = [[entry objectForKey:@"count"] intValue];
			NSString *s;
			if (count > 1 || count == 0) {
				s = [NSString stringWithFormat:@"%d photos", count];				
			} else {
				s = [NSString stringWithFormat:@"%d photo", count];				
			}
			
			cell.detailTextLabel.text = s;
			
			if (selectedAlbum == indexPath.row) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}

			
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
			
			if (indexPath.row == 1) 
				cell.textLabel.text = @"Title for this Feed:";
			else {
				if (currentSelection == SelectionTypeUser)
					cell.textLabel.text = @"User Name:";
				else 
					cell.textLabel.text = @"Find:";
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

- (void)handleSegmentSelectionChanged:(id)sender {
	UISegmentedControl *sc = (UISegmentedControl*)sender;
	currentSelection = sc.selectedSegmentIndex;
	
	if (currentSelection == SelectionTypeAlbum && albums == nil) {
		editViewController.waitView.hidden = NO;
		[editViewController.activityView startAnimating];
        [self loadUserAlbums];
	} 
	
	if (currentSelection == SelectionTypeAlbum) {
		doneButton.enabled = selectedAlbum != -1;	
	} else {
		doneButton.enabled = ![titleString isEqualToString:@""] && ![queryString isEqualToString:@""];	
	}
	
	[self.tableView reloadData];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (currentSelection == SelectionTypeAlbum) {
		if (indexPath.section == 2) {
			selectedAlbum = indexPath.row;
			doneButton.enabled = YES;
			[self.tableView reloadData];
		}
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
	
	doneButton.enabled = ![titleString isEqualToString:@""] && ![queryString isEqualToString:@""];	
	
	return YES;
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleWasEdited = NO;
	selectedAlbum = -1;
	
	self.title = @"Facebook Feed";
	
	self.feedSource = [[[FeedSource alloc] init] autorelease];
	feedSource.type = FeedSourceTypeFacebook;
	
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
	self.albums = nil;
    self.fbData = nil;
    
    [super dealloc];
}

@end

