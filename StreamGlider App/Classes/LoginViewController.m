//
//  LoginViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 09/09/2011.
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

#import "LoginViewController.h"
#import "LoginController.h"
#import "APIReader.h"
#import "SocialNetworksViewController.h"
#import "StreamCastStateController.h"
#import "StreamCastViewController.h"
#import "OAuthCore.h"
#import "Core.h"
#import "ChangePasswordViewController.h"
#import "JSON.h"

@interface LoginViewController ()

@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, retain) IBOutlet UIView *waitView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic, retain) LoginController *loginController;
@property (nonatomic, retain) APIReader *apiReader;

@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

@property (nonatomic, retain) IBOutlet UIButton *loginButton;

@property (nonatomic, retain) IBOutlet UIButton *registerButton;

@property (nonatomic, retain) IBOutlet UILabel *textLabel;

@property (nonatomic, retain) IBOutlet UILabel *tagLineLabel;

@property (nonatomic, retain) IBOutlet UIButton *changePasswordButton;

@property (nonatomic, retain) IBOutlet UILabel *loggedInLabel;

@property (nonatomic, retain) IBOutlet UIButton *yesButton;

@property (nonatomic, retain) IBOutlet UIButton *noButton;

@property (retain, nonatomic) IBOutlet UIButton *resetButton;

@property (nonatomic, copy) NSString *okMessage;

- (IBAction)handleCancelTapped:(id)sender;
- (IBAction)handleRegisterTapped:(id)sender;
- (IBAction)handleLoginTapped:(id)sender;
- (IBAction)handleChangeTapped:(id)sender;
- (IBAction)handleYesNoTapped:(id)sender;
- (IBAction)handleResetTapped:(id)sender;

@end

@implementation LoginViewController {
    BOOL resettingPassword;
    BOOL receiveNewsletter;
}

@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize email;
@synthesize password;
@synthesize waitView;
@synthesize activityView;
@synthesize loginController;
@synthesize apiReader;
@synthesize cancelButton;
@synthesize loginButton;
@synthesize registerButton;
@synthesize textLabel;
@synthesize tagLineLabel;
@synthesize changePasswordButton;
@synthesize loggedInLabel;
@synthesize yesButton;
@synthesize noButton;
@synthesize resetButton;
@synthesize okMessage;
@synthesize panelType;
@synthesize delegate;

#pragma mark Utility Methods

- (void)displayAlertWithTitle:(NSString*)title text:(NSString*)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark UITextFieldDelegate

- (BOOL)isValidEmail:(NSString*)text {
	NSString *regex = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
	return [predicate evaluateWithObject:[text uppercaseString]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 0) {
		self.email = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else {
		self.password = [textField.text stringByReplacingCharactersInRange:range withString:string];				
	}
    
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 
	
    [self handleLoginTapped:nil];
	
	return YES; 
} 

- (void)textFieldDidEndEditing:(UITextField *)textField {	
	if (textField.tag == 0) {
		self.email = textField.text;
        self.email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else {
		self.password = textField.text;
	}	
}

#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
	waitView.hidden = YES;
	[activityView stopAnimating];	
    
    NSDictionary *d = (NSDictionary*)data;
    NSString *msg;
    if ([d.allKeys containsObject:@"error"]) {
        msg = @"The email was not found in our DB. Please try again.";
    } else {
        msg = @"You will receive an email with instructions about how to reset your password in a few minutes.";
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Password Reset" 
                                                 message:msg
                                                delegate:nil 
                                       cancelButtonTitle:@"Close" 
                                       otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];		
    [av release];    
}

- (void)apiLoadFailed:(APIReader*)reader {
	waitView.hidden = YES;
	[activityView stopAnimating];	
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Password Reset" 
                                                 message:@"Reset password email was not sent due to a server problem."
                                                delegate:nil 
                                       cancelButtonTitle:@"Close" 
                                       otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];		
    [av release];
}


#pragma mark LoginDelegate

- (void)foregroundDismiss {
    if (panelType == LoginPanelTypeFirstRun) {        
        SocialNetworksViewController *evc = [[SocialNetworksViewController alloc] 
                                    initWithNibName:@"SocialNetworksViewController" bundle:nil];
        evc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self retain];
        
        [self dismissModalViewControllerAnimated:NO];            
        
        [[StreamCastStateController sharedInstance].streamCastViewController presentModalViewController:evc animated:YES];
        
        [evc release];                
        
        [self release];
    } else {
        [self dismissModalViewControllerAnimated:YES];        
    }        
}

- (void)loginActionOK {
	waitView.hidden = YES;
	[activityView stopAnimating];	
    
    // store email
    [Core sharedInstance].userEmail = email;
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"User Login" 
                                                 message:okMessage
                                                delegate:nil 
                                       cancelButtonTitle:@"Close" 
                                       otherButtonTitles:nil];
    
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];		
    [av release];
    
    [delegate loginOK];
        
    [self performSelectorOnMainThread:@selector(foregroundDismiss) withObject:nil waitUntilDone:NO];
}

- (void)loginActionFailed:(NSString*)msg {
	waitView.hidden = YES;
	[activityView stopAnimating];
	
    NSString *errorMessage;
    if ([msg isEqualToString:@"Email is not found"]) {
         errorMessage = @"That Userid was not found\nPlease try again";
    } else if ([msg isEqualToString:@"This email has already been taken"]) {
        errorMessage = @"This email has already been taken";
    } else {
        errorMessage = @"Incorrect Password\nPlease try again";
    }
            
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"User Login" 
												 message:errorMessage
												delegate:nil 
									   cancelButtonTitle:@"Close" 
									   otherButtonTitles:nil];
	[av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];		
	[av release];
}


#pragma mark Handlers

- (void)doLogin {    
	[loginController loginWithEmail:email password:password];
}

- (void)doRegister {    
	[loginController registerWithEmail:email password:password newsletter:receiveNewsletter];
}

- (void)doResetPassword {
	self.apiReader = [[[APIReader alloc] init] autorelease];
	apiReader.delegate = self;
    
    NSString *q = [NSString stringWithFormat:@"users/password.json?email=%@", email];
	[apiReader loadAPIDataFor:q withMethod:@"POST" addAuthToken:NO handleAuthError:NO];
}

- (IBAction)handleCancelTapped:(id)sender {
    if (panelType == LoginPanelTypeFirstRun) {        
        SocialNetworksViewController *evc = [[SocialNetworksViewController alloc] 
                                             initWithNibName:@"SocialNetworksViewController" bundle:nil];
        evc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self retain];
        
        [self dismissModalViewControllerAnimated:NO];            
        
        [[StreamCastStateController sharedInstance].streamCastViewController presentModalViewController:evc animated:YES];
        
        [evc release];                
        
        [self release];
    } else {
        [self dismissModalViewControllerAnimated:YES];        
    }
    
    [delegate loginFailed];
}

- (IBAction)handleRegisterTapped:(id)sender {
    
    if (![self isValidEmail:self.email] || [self.password length] == 0) {
        [self displayAlertWithTitle:@"Register Error" text:@"To register please provide a valid email and a password"];
        return;
    }
    
	waitView.hidden = NO;
	[activityView startAnimating];
	
    self.okMessage = [NSString stringWithFormat:@"You created a new account named %@ ", email];
    
	self.loginController = [[[LoginController alloc] init] autorelease];
	loginController.delegate = self;
	[self performSelectorInBackground:@selector(doRegister) withObject:nil];        
}

- (IBAction)handleLoginTapped:(id)sender {
    if (![self isValidEmail:self.email] || [self.password length] == 0) {
        [self displayAlertWithTitle:@"Login Error" text:@"To login please provide a valid email and a password"];
        return;
    }
    
	waitView.hidden = NO;
	[activityView startAnimating];
	
    self.okMessage = [NSString stringWithFormat:@"You were logged in successfully as %@", email];
    
    self.loginController = [[[LoginController alloc] init] autorelease];
	loginController.delegate = self;

	[self performSelectorInBackground:@selector(doLogin) withObject:nil];        
}

- (IBAction)handleChangeTapped:(id)sender {    
    if (![Core sharedInstance].userEmail) {        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"In order to change password you have to log in or register with the system first." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    ChangePasswordViewController *cvc = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
    cvc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:cvc animated:YES];
    [cvc release];
}

- (IBAction)handleYesNoTapped:(id)sender {
    UIButton *b = (UIButton*)sender;
    if (b.tag == 0) {
        receiveNewsletter = YES;
        yesButton.selected = YES;
        noButton.selected = NO;
    } else {
        receiveNewsletter = NO;
        yesButton.selected = NO;
        noButton.selected = YES;
    }
}

- (IBAction)handleResetTapped:(id)sender {
    if (![self isValidEmail:self.email]) {
        [self displayAlertWithTitle:@"Reset Password Error" text:@"To reset password please provide your email"];
        return;
    }
    
	waitView.hidden = NO;
	[activityView startAnimating];
    resettingPassword = YES;
	
	[self performSelectorInBackground:@selector(doResetPassword) withObject:nil];        
}

#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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

- (void)configurePanelType {
    textLabel.text = [NSString stringWithFormat:@"Welcome to %@ for iPad!", APP_NAME];    
    tagLineLabel.text = TAG_LINE;
    
    if (panelType == LoginPanelTypeFirstRun) {
//        [cancelButton removeFromSuperview];
        [changePasswordButton removeFromSuperview];  
        [loggedInLabel removeFromSuperview];
    } else {
        if ([Core sharedInstance].userEmail) {
            loggedInLabel.text = [NSString stringWithFormat:@"You are currently logged in as: %@", [Core sharedInstance].userEmail];            
        } else {
            loggedInLabel.text = @"You are not logged in";
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    resettingPassword = NO;
    receiveNewsletter = YES;
    yesButton.selected = YES;
    
    UIColor *disabledColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1];
    [registerButton setTitleColor:disabledColor forState:UIControlStateDisabled];
    [loginButton setTitleColor:disabledColor forState:UIControlStateDisabled];
    
    [self configurePanelType];
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
    [self setCancelButton:nil];
    [self setLoginButton:nil];
    [self setRegisterButton:nil];
    [self setTextLabel:nil];
    [self setChangePasswordButton:nil];
    [self setLoggedInLabel:nil];
    [self setYesButton:nil];
    [self setNoButton:nil];
    [self setTagLineLabel:nil];
    [self setResetButton:nil];
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
    [emailTextField release];
    [passwordTextField release];
    
    self.email = nil;
    self.password = nil;
    self.okMessage = nil;
    self.loginController = nil;
    self.apiReader = nil;
    
    [waitView release];
    [activityView release];
    
    [cancelButton release];
    [loginButton release];
    [registerButton release];
    [textLabel release];
    [changePasswordButton release];
    [loggedInLabel release];
    [yesButton release];
    [noButton release];
    [tagLineLabel release];
    [resetButton release];
    [super dealloc];
}

@end
