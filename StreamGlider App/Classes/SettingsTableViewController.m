//
//  SettingsViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 05/05/2011.
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

#import "SettingsTableViewController.h"
#import "OAuthProtocol.h"
#import "OAuthCore.h"
#import "SettingsController.h"
#import "ColorTableViewController.h"
#import "SettingsViewController.h"
#import "GoogleReaderLoginViewController.h"
#import "FeedSourceCategory.h"
#import "Core.h"
#import "SliderTableViewCell.h"
#import "AutoLoader.h"

@implementation SettingsTableViewController {
    NSArray *newIndicatorImages;
}

@synthesize viewController, emailPanel, realm;

#pragma mark Utility Methods

- (FeedSourceCategory*)findGoogleReaderCategory {
    for (FeedSourceCategory *cat in [Core sharedInstance].rootCategory.children) {
        if ([cat.title isEqualToString:@"My Feeds"]) {
            for (FeedSourceCategory *cat1 in cat.children) {
                if ([cat1.title isEqualToString:@"Google Reader"]) {
                    return cat1;
                }
            }
        }
    }
    return nil;
}

#pragma mark Handlers

- (void)handleCloseTapped {
	[viewController dismissModalViewControllerAnimated:YES];
}

- (void)handleSliderValueChanged:(id)sender {
	UISlider *slider = (UISlider*)sender;
	int nv = round(slider.value);
	if ([SettingsController sharedInstance].cardsInterval != nv) {
		[SettingsController sharedInstance].cardsInterval = nv;
		[self.tableView reloadData];
	}
}

#pragma mark GoogleReaderLoginDelegate

- (void)loginSuccessful {
	[self.tableView reloadData];
}

#pragma mark OAuthDelegate

- (void)exchangeWasFinished:(id <OAuthProtocol>)oauth {
	if ([oauth authenticated]) {
		[self.tableView reloadData];
        
        // ask user if he want to auto generate a stream for this realm
        NSString *msg;
        if ([realm isEqualToString:TWITTER_REALM]) {
            msg = @"Do you want to auto build a stream for Twitter?";
        } else if ([realm isEqualToString:FACEBOOK_REALM]) {
            msg = @"Do you want to auto build streams for Facebook?";
        } else if ([realm isEqualToString:YOUTUBE_REALM]) {
            msg = @"Do you want to auto build a stream for YouTube";
        } else if ([realm isEqualToString:FLICKR_REALM]) {
            msg = @"Do you want to auto build a stream for Flickr?";
        } else {
            msg = @"Do you want to auto build streams for Google Reader?";            
        }
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Autobuild Streams" 
                                                     message:msg
                                                    delegate:self 
                                           cancelButtonTitle:@"No" 
                                           otherButtonTitles:@"Yes", nil];
        [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];	
        [av release];   
        
	}
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (emailPanel) 
        return 1;
	else
		return 2;        
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    // Return the number of rows in the section.
	if (section == 0) {
		return 5;
	} else {
		return 6;
	}     
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *SliderCellIdentifier = @"SliderCell";
	
    
    UITableViewCell *cell;
    
	if (indexPath.section == 1 && indexPath.row == 4) {
		cell = [tableView dequeueReusableCellWithIdentifier:SliderCellIdentifier];
		if (cell == nil) {
			cell = [[[SliderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
										   reuseIdentifier:SliderCellIdentifier] autorelease];
			[((SliderTableViewCell*)cell).slider addTarget:self action:@selector(handleSliderValueChanged:) 
										  forControlEvents:UIControlEventValueChanged];
		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
										   reuseIdentifier:CellIdentifier] autorelease];
		}
	}
    
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Twitter";
					id<OAuthProtocol> oa = [[OAuthCore sharedInstance] getOAuthForRealm:TWITTER_REALM];
					if ([oa authenticated]) {
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
						cell.detailTextLabel.text = @"Tap to deauthorize Twitter";
					} else {
						cell.accessoryType = UITableViewCellAccessoryNone;
						cell.detailTextLabel.text = @"Tap to authorize Twitter";
					}
					
					cell.imageView.image = [UIImage imageNamed:@"CAT_TWITTER.png"];
					
					break;
				case 1:
					cell.textLabel.text = @"Facebook";
					oa = [[OAuthCore sharedInstance] getOAuthForRealm:FACEBOOK_REALM];
					if ([oa authenticated]) {
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
						cell.detailTextLabel.text = @"Tap to deauthorize Facebook";
					} else {
						cell.accessoryType = UITableViewCellAccessoryNone;
						cell.detailTextLabel.text = @"Tap to authorize Facebook";
					}
					
					cell.imageView.image = [UIImage imageNamed:@"CAT_FACEBOOK.png"];
					
					break;
				case 2:
					cell.textLabel.text = @"Flickr";
					oa = [[OAuthCore sharedInstance] getOAuthForRealm:FLICKR_REALM];
					if ([oa authenticated]) {
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
						cell.detailTextLabel.text = @"Tap to deauthorize Flickr";
					} else {
						cell.accessoryType = UITableViewCellAccessoryNone;
						cell.detailTextLabel.text = @"Tap to authorize Flickr";
					}
					
					cell.imageView.image = [UIImage imageNamed:@"CAT_FLICKR.png"];
					
					break;
				case 4:
					cell.textLabel.text = @"Google Reader";
					NSString *email = [OAuthCore getValueFromKeyChainFor:@"google-reader-login"];
					NSString *password = [OAuthCore getValueFromKeyChainFor:@"google-reader-password"];
					
					if (email != nil && password != nil) {
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
						cell.detailTextLabel.text = @"Tap to deauthorize Google Reader";
					} else {
						cell.accessoryType = UITableViewCellAccessoryNone;
						cell.detailTextLabel.text = @"Tap to authorize Google Reader";
					}
					
					cell.imageView.image = [UIImage imageNamed:@"CAT_GOOGLEREADER.png"];
					
					break;
				case 3:
					cell.textLabel.text = @"YouTube";
					oa = [[OAuthCore sharedInstance] getOAuthForRealm:YOUTUBE_REALM];
					
					if ([oa authenticated]) {
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
						cell.detailTextLabel.text = @"Tap to deauthorize YouTube";
					} else {
						cell.accessoryType = UITableViewCellAccessoryNone;
						cell.detailTextLabel.text = @"Tap to authorize YouTube";
					}
					
					cell.imageView.image = [UIImage imageNamed:@"CAT_YOUTUBE.png"];
					
					break;					
			}
			break;
        case 1:   
			switch (indexPath.row) {
				case 0:					
					cell.textLabel.text = @"New frame indicator color";
					cell.detailTextLabel.text = @"Tap to select the indicator color for new frames";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.imageView.image = [[SettingsController sharedInstance].niColorImages objectAtIndex:
											[SettingsController sharedInstance].niCurrentColor];
					break;
				case 1:
					cell.textLabel.text = @"Gray out viewed frames";
					cell.detailTextLabel.text = @"Tap to gray out frames once they have been viewed";
					if ([SettingsController sharedInstance].grayOutViewedFrames) 
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else 
						cell.accessoryType = UITableViewCellAccessoryNone;					
					break;
				case 2:
					cell.textLabel.text = @"Remove viewed frames";
					cell.detailTextLabel.text = @"Tap to remove frames once they have been viewed";
					if ([SettingsController sharedInstance].removeViewedFrames) 
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else 
						cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 3:
					cell.accessoryType = UITableViewCellAccessoryNone;
					if ([SettingsController sharedInstance].plusMode) { 
						cell.textLabel.text = @"Switch to Compact View";
                        cell.detailTextLabel.text = @"Tap to show the stream title to the left of each stream";
					} else {
						cell.textLabel.text = @"Switch to Expanded View";
                        cell.detailTextLabel.text = @"Tap to show the stream title above each stream";
					}
					break;
				case 4:
					cell.textLabel.text = @"Stream scrolling speed";
					NSString *cur = [NSString stringWithFormat:@"%d seconds per frame", [SettingsController sharedInstance].cardsInterval];
					cell.detailTextLabel.text = cur;
					((SliderTableViewCell*)cell).slider.value = [SettingsController sharedInstance].cardsInterval;					
					break;
				case 5:
					cell.textLabel.text = @"Paginate feeds";
					cell.detailTextLabel.text = @"Tap to allow feeds to paginate to older frames";
					if ([SettingsController sharedInstance].paginateFeeds)
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else
						cell.accessoryType = UITableViewCellAccessoryNone;
					break;
			}
			break;
	}
    
    return cell;
}

#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		id<OAuthProtocol> oa;
		GoogleReaderLoginViewController *gvc;
		NSString *email, *password;
		switch (indexPath.row) {
			case 0:
                self.realm = TWITTER_REALM;
				oa = [[OAuthCore sharedInstance] getOAuthForRealm:TWITTER_REALM];
				if ([oa authenticated]) {
					// deauth twitter
                    [[OAuthCore sharedInstance] clearTokenForRealm:TWITTER_REALM];
					
					[self.tableView reloadData];
					
					UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Twitter Authorization" 
																 message:@"You have deauthorized Twitter successfully." 
																delegate:nil 
													   cancelButtonTitle:@"Close" 
													   otherButtonTitles:nil];
					[av show];
					[av release];				
				} else {
					[[OAuthCore sharedInstance] requestAuthForRealm:TWITTER_REALM 
													   withDelegate:self 
													 viewController:self];
				}
				
				break;
			case 1:
                self.realm = FACEBOOK_REALM;
				oa = [[OAuthCore sharedInstance] getOAuthForRealm:FACEBOOK_REALM];
				if ([oa authenticated]) {
					// deauth FB
                    [[OAuthCore sharedInstance] clearTokenForRealm:FACEBOOK_REALM];                    
					[self.tableView reloadData];
					
					UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Facebook Authorization" 
																 message:@"You have deauthorized Facebook successfully." 
																delegate:nil 
													   cancelButtonTitle:@"Close" 
													   otherButtonTitles:nil];
					[av show];
					[av release];				
				} else {
					[[OAuthCore sharedInstance] requestAuthForRealm:FACEBOOK_REALM 
													   withDelegate:self 
													 viewController:self];
				}
				
				break;
			case 2:
                self.realm = FLICKR_REALM;
				oa = [[OAuthCore sharedInstance] getOAuthForRealm:FLICKR_REALM];
				
				if ([oa authenticated]) {
					// deauth FB
                    [[OAuthCore sharedInstance] clearTokenForRealm:FLICKR_REALM];
					[self.tableView reloadData];
					
					UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Flickr Authorization" 
																 message:@"You have deauthorized Flickr successfully." 
																delegate:nil 
													   cancelButtonTitle:@"Close" 
													   otherButtonTitles:nil];
					[av show];
					[av release];				
				} else {
					[[OAuthCore sharedInstance] requestAuthForRealm:FLICKR_REALM 
													   withDelegate:self 
													 viewController:self];
				}
				break;
			case 3:
                self.realm = YOUTUBE_REALM;
				oa = [[OAuthCore sharedInstance] getOAuthForRealm:YOUTUBE_REALM];
				if ([oa authenticated]) {
					// deauth YouTube
                    [[OAuthCore sharedInstance] clearTokenForRealm:YOUTUBE_REALM];					
					[self.tableView reloadData];
					
					UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"YouTube Authorization" 
																 message:@"You have deauthorized YouTube successfully." 
																delegate:nil 
													   cancelButtonTitle:@"Close" 
													   otherButtonTitles:nil];
					[av show];
					[av release];				
				} else {
					[[OAuthCore sharedInstance] requestAuthForRealm:YOUTUBE_REALM 
													   withDelegate:self 
													 viewController:self];
				}
				
				break;
			case 4:
                self.realm = @"Google Reader";
				email = [OAuthCore getValueFromKeyChainFor:@"google-reader-login"];
				password = [OAuthCore getValueFromKeyChainFor:@"google-reader-password"];
				
				if (email == nil && password == nil) {
					gvc = [[GoogleReaderLoginViewController alloc] 
														initWithNibName:@"GoogleReaderLoginViewController" 
														bundle:nil];
					gvc.delegate = self;
					gvc.modalPresentationStyle = UIModalPresentationFormSheet;
					[viewController presentModalViewController:gvc animated:YES];
					[gvc release];			
				} else {
					// remove GR sources from the tree
                    // find GR category
                    FeedSourceCategory *cat = [self findGoogleReaderCategory];
                    if (cat != nil) 
                        [cat.children removeAllObjects];
					
					[OAuthCore deleteKeychainValueForKey:@"google-reader-login"];
					[OAuthCore deleteKeychainValueForKey:@"google-reader-password"];
					
					[self.tableView reloadData];
					
					UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Google Reader Authorization" 
																 message:@"You have deauthorized Google Reader successfully." 
																delegate:nil 
													   cancelButtonTitle:@"Close" 
													   otherButtonTitles:nil];
					[av show];
					[av release];									
				}

				break;
		}
    } else {		
		ColorTableViewController *cvc;		
		SettingsController *sc = [SettingsController sharedInstance];
		switch (indexPath.row) {
			case 0:
				cvc = [[ColorTableViewController alloc] initWithStyle:UITableViewStylePlain];
				cvc.tableViewController = self;
				[self.navigationController pushViewController:cvc animated:YES];
				[cvc release];				
				break;
			case 1:
				sc.grayOutViewedFrames = !sc.grayOutViewedFrames;
				[self.tableView reloadData];	
				break;
			case 2:
				sc.removeViewedFrames = !sc.removeViewedFrames;
				[self.tableView reloadData];				
				break;
			case 3:
				sc.plusMode = !sc.plusMode;
				[self.tableView reloadData];				
				break;
            case 5:
				sc.paginateFeeds = !sc.paginateFeeds;
				[self.tableView reloadData];
                break;
                
		}
	}	        
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return emailPanel ? @"Sign on to your accounts and we'll remember them later" : @"Link your Accounts";
			break;
		case 2:
			return @"Appearance";
			break;
	}
	return nil;
}

#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!emailPanel) {
        
		self.title = @"Settings";
		
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
									   target:self 
									   action:@selector(handleCloseTapped)];
		
		self.navigationItem.leftBarButtonItem = backButton;
		
		[backButton release];
	}
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
    [super dealloc];
}


@end

