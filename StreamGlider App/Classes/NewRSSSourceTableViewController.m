//
//  NewRSSSourceTableViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 07/09/2010.
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

#import "NewRSSSourceTableViewController.h"
#import "NamedFieldTableViewCell.h"
#import "FeedSource.h"
#import "Core.h"
#import "Feed.h"
#import "ImageTableViewCell.h"
#import "Stream.h"


@implementation NewRSSSourceTableViewController

@synthesize urlString, titleString;

#pragma mark Handlers

- (void)handleDoneButtonTapped {
	feedSource.title = titleString;
        
	feedSource.URLString = urlString;
	[[Core sharedInstance] addSource:feedSource];
	
	// 
	[self createOrEditFeed];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Prepopulating

- (void)prepopulateFields {
	if (feed != nil && feed.source.type == FeedSourceTypeRSS) {
		// pre populate fields with data from the source
		self.titleString = feed.source.title;
		self.urlString = feed.source.URLString;		
	} else {
		self.titleString = @"";
		self.urlString = @"";
	}	
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0)
		return 1;
	else 
		return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EditableCell";
    static NSString *ImageCellIdentifier = @"ImageCell";
    
	
	if (indexPath.section == 0) {
		ImageTableViewCell *cell = (ImageTableViewCell*)[tableView 
														 dequeueReusableCellWithIdentifier:ImageCellIdentifier];
		
		if (cell == nil) {
			cell = [[[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
											 reuseIdentifier:ImageCellIdentifier] autorelease];
			cell.imageName = @"RSS_Panel_Borderless.png";	
		}
		
		return cell;
	} else {
		NamedFieldTableViewCell *cell = (NamedFieldTableViewCell*)[tableView 
																 dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[NamedFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
												 reuseIdentifier:CellIdentifier] autorelease];		
			if (indexPath.row == 1)
				cell.titleValueTextField.text = titleString;
			else 
				cell.titleValueTextField.text = urlString;
		}
		
		if (indexPath.row == 1) { 
			cell.textLabel.text = @"Title for this Feed:";
		} else { 
			cell.textLabel.text = @"URL:";
			cell.titleValueTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			cell.titleValueTextField.keyboardType = UIKeyboardTypeURL;
		}
		
		cell.titleValueTextField.tag = indexPath.row;
		cell.titleValueTextField.delegate = self;					
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 150;
	} else {
		return tableView.rowHeight;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1)
		return @"RSS Feed:";
	else 
		return nil;
}

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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 
	return YES; 
} 

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (textField.tag == 1)
		self.titleString = value;
	else 
		self.urlString = value;
	
	doneButton.enabled = ![titleString isEqualToString:@""] && ![urlString isEqualToString:@""];	
	
	return YES;
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"RSS Feed";
	
	self.feedSource = [[[FeedSource alloc] init] autorelease];
	feedSource.type = FeedSourceTypeRSS;		
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
	self.urlString = nil;
    [super dealloc];
}

@end

