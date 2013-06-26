//
//  ChangePasswordViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 16/09/2011.
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

#import "ChangePasswordViewController.h"
#import "Core.h"
#import "LoginController.h"

@interface ChangePasswordViewController ()

@property (nonatomic, retain) IBOutlet UIButton *changeButton;
@property (nonatomic, retain) IBOutlet UIView *waitView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic, copy) NSString *oldPassword;
@property (nonatomic, copy) NSString *thePassword;
@property (nonatomic, copy) NSString *confirmPassword;

@property (nonatomic, retain) LoginController *loginController;

- (IBAction)handleChangeTapped:(id)sender;
- (IBAction)handleCancelTapped:(id)sender;

@end

@implementation ChangePasswordViewController

@synthesize changeButton;
@synthesize waitView;
@synthesize activityView;
@synthesize oldPassword, thePassword, confirmPassword;
@synthesize loginController;

#pragma mark Utility Methods

- (void)displayAlertWithTitle:(NSString*)title text:(NSString*)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark LoginDelegate

- (void)foregroundDismiss {
    [self dismissModalViewControllerAnimated:YES];        
}

- (void)loginActionOK {
	waitView.hidden = YES;
	[activityView stopAnimating];	
    
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Password Change" 
												 message:@"Your password has been successfully changed"
												delegate:nil 
									   cancelButtonTitle:@"Close" 
									   otherButtonTitles:nil];
	[av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];		
	[av release];
    
    [self performSelectorOnMainThread:@selector(foregroundDismiss) withObject:nil waitUntilDone:NO];
}

- (void)loginActionFailed:(NSString*)msg {
	waitView.hidden = YES;
	[activityView stopAnimating];
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"User Login" 
												 message:msg
												delegate:nil 
									   cancelButtonTitle:@"Close" 
									   otherButtonTitles:nil];
	[av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];		
	[av release];
}


#pragma mark Handlers

- (void)doChangePassword {
	self.loginController = [[[LoginController alloc] init] autorelease];
	loginController.delegate = self;
	[loginController changePassword:oldPassword newPassword:thePassword];
}

- (IBAction)handleChangeTapped:(id)sender {
    BOOL flag = oldPassword != nil && [oldPassword length] > 0 && thePassword != nil && [thePassword length] > 0 && confirmPassword != nil && [confirmPassword length] > 0;
    
    if (!flag) {
        [self displayAlertWithTitle:@"Change Password Error" text:@"Please provide old password, new password and new password confirmation."];
        return;
    }
    
    if (![thePassword isEqualToString:confirmPassword]) {
        [self displayAlertWithTitle:@"Change Password Error" text:@"New password and new password confirmation do not match."];
    } else {
        [self performSelectorInBackground:@selector(doChangePassword) withObject:nil];
    }
}

- (IBAction)handleCancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];		
	if (textField.tag == 0) {
		self.oldPassword = s;
	} else if (textField.tag == 1){
		self.thePassword = s;		
	} else {
        self.confirmPassword = s;
    }
    
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 
	
	if (changeButton.enabled) {
		[self handleChangeTapped:nil];
	}
	
	return YES; 
} 

- (void)textFieldDidEndEditing:(UITextField *)textField {	
	if (textField.tag == 0) {
		self.oldPassword = textField.text;
	} else if (textField.tag == 1) {
		self.thePassword = textField.text;
	} else {
        self.confirmPassword = textField.text;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *disabledColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1];
    [changeButton setTitleColor:disabledColor forState:UIControlStateDisabled];    
}

- (void)viewDidUnload
{
    [self setChangeButton:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
    
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
    self.oldPassword = nil;
    self.thePassword = nil;
    self.confirmPassword = nil;
    self.loginController = nil;
    
    [changeButton release];
    [waitView release];
    [activityView release];
    [super dealloc];
}
@end
