//
//  PageLabel.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 26/10/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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

#import "PageLabelViewController.h"
#import "PageOfStreams.h"
#import "Core.h"
#import "UIColor+SG.h"
#import "PageBarViewController.h"

@interface PageLabelViewController ()

@property (nonatomic, retain) IBOutlet UIImageView *addImage;

- (IBAction)handleDeleteTapped:(id)sender;

@end

@implementation PageLabelViewController

@synthesize addImage;
@synthesize deleteButton;
@synthesize editField;

@synthesize page, newPageButton, editMode, barVC;

#pragma mark Editing

- (void)setupEditing {
    self.titleLabel.hidden = YES;
    editField.text = self.titleLabel.text;
    editField.hidden = NO;
    [editField becomeFirstResponder];
}

- (void)dropEditing {
    self.titleLabel.hidden = NO;
    editField.hidden = YES;
    
    if (editField.text != nil && ![editField.text isEqualToString:@""]) {
        page.title = editField.text;
        self.titleLabel.text = page.title;
        [barVC layoutPageLabels];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 
	return YES; 
} 

- (void)textFieldDidEndEditing:(UITextField *)textField {	
	[self dropEditing];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[Core sharedInstance] removePage:page];        
    }
}

#pragma mark Handlers

- (IBAction)handleDeleteTapped:(id)sender {
    if ([[Core sharedInstance].pages count] == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Page Delete Failed" 
                                                        message:@"We can't delete the last page" delegate:nil 
                                              cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the \"%@\" page?", page.title];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Page Delete" 
                                                    message:message delegate:self 
                                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];    
}

#pragma mark PageOfStreamsDelegate

- (void)pageTitleWasChanged:(PageOfStreams*)p {
    self.titleLabel.text = page.title;
    [barVC layoutPageLabels];
}

#pragma mark CoreDelegate

- (void)activePageWasChangedToPage:(PageOfStreams*)p {
    [self setActive:page.activePage];
}

- (void)pageWasRemoved:(PageOfStreams *)p {
    if (page == p)
        [[Core sharedInstance] removeCoreDelegate:self];    
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (newPageButton) {
        // create new page
        PageOfStreams *p = [[PageOfStreams alloc] init];
        p.title = @"New Page";
        [[Core sharedInstance] addPage:p makeActive:YES];
        [p release];
    } else if (!page.activePage) {
        // switch active page
        [[Core sharedInstance] setActivePage:page];
    } else if (editMode) {
        [self setupEditing];
    }
}

#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
       
    if (!editMode) {
        [deleteButton removeFromSuperview];
        [editField removeFromSuperview];
        [page addDelegate:self];
    } else {
        [self.view bringSubviewToFront:deleteButton];
        [self.view bringSubviewToFront:editField];
    }
    
    self.view.backgroundColor = [UIColor gridCellBackgroundColor];            
    
    if (newPageButton) {    
        self.titleLabel.text = @"";
        [deleteButton removeFromSuperview];
        [editField removeFromSuperview];
    } else {
        [addImage removeFromSuperview];
        
        [[Core sharedInstance] addCoreDelegate:self];
        
        self.titleLabel.text = page.title;
            
        [self setActive:page.activePage];
    }
}

- (void)viewDidUnload
{
    [self setAddImage:nil];
    [self setDeleteButton:nil];
    [self setEditField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark Lifecycle

- (void)dealloc {
    if (!newPageButton)
        [[Core sharedInstance] removeCoreDelegate:self];

    self.page = nil;    
    
    [addImage release];
    [deleteButton release];
    [editField release];
    [super dealloc];
}
@end
