//
//  GoogleReaderLoginViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 04/05/2011.
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

#import "GoogleReaderLoginViewController.h"
#import "GReaderLoader.h"
#import "BrowseTableViewController.h"
#import "EditWindowViewController.h"
#import "OAuthCore.h"
#import "Core.h"
#import "FeedSourceCategory.h"

@interface GoogleReaderLoginViewController ()

@property (nonatomic, retain) IBOutlet UIBarButtonItem *loginButton;
@property (nonatomic, retain) IBOutlet UIView *waitView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)handleLoginTapped:(id)sender;
- (IBAction)handleCancelTapped:(id)sender;

@end

@implementation GoogleReaderLoginViewController {
	BOOL loadFinished;    
}

@synthesize loginButton, email, password, delegate, waitView, activityView;

#pragma mark Handlers

- (void)loadSourcesInBackground {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	[[GReaderLoader sharedInstance] getGoogleReaderSourcesForUser:email 
														 password:password];	
	
	while (loadFinished) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];	
}

- (IBAction)handleLoginTapped:(id)sender {
    waitView.hidden = NO;
    [activityView startAnimating];
    // store login/password in the keychain
    [OAuthCore storeKeychainValue:email forKey:@"google-reader-login"];
    [OAuthCore storeKeychainValue:password forKey:@"google-reader-password"];
    
    [GReaderLoader sharedInstance].delegate = self;
    
    [self performSelectorInBackground:@selector(loadSourcesInBackground) withObject:nil];
}

- (IBAction)handleCancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if (textField.tag == 0) {
		self.email = s;
	} else {
		self.password = s;
	}

	loginButton.enabled = email != nil && [email length] > 5 && password != nil && [password length] > 3;	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 	
    
	if (loginButton.enabled) {
		[self handleLoginTapped:nil];
	}
    
	return YES; 
} 

- (void)textFieldDidEndEditing:(UITextField *)textField {	
	if (textField.tag == 0) {
		self.email = textField.text;
	} else {
		self.password = textField.text;
	}
	
	loginButton.enabled = email != nil && [email length] > 5 && password != nil && [password length] > 3;	
}


#pragma mark GReaderProtocol

- (void)loadFinishedForeground {	
	[self retain];	
	
	[delegate loginSuccessful];	
	loadFinished = YES;
		
	[self release];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)loadFailedForeground {
	waitView.hidden = YES;
	[activityView stopAnimating];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google Reader Login" 
													message:@"Incorrect email or password. Please try again." 
												   delegate:nil 
										  cancelButtonTitle:@"Close" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)loadFailed {
	loadFinished = YES;	
	[OAuthCore deleteKeychainValueForKey:@"google-reader-login"];
	[OAuthCore deleteKeychainValueForKey:@"google-reader-password"];
	
	
	[self performSelectorOnMainThread:@selector(loadFailedForeground) 
						   withObject:nil waitUntilDone:NO];	
}

- (void)loadFinished {	
    for (FeedSourceCategory *cat in [Core sharedInstance].rootCategory.children) {
        if ([cat.title isEqualToString:@"My Feeds"]) {
            for (FeedSourceCategory *cat1 in cat.children) {
                if ([cat1.title isEqualToString:@"Google Reader"]) {
                    [[GReaderLoader sharedInstance] addSourcesToCategory:cat1];                    
                    break;
                }
            }
            
            break;            
        }
    }
    [self performSelectorOnMainThread:@selector(loadFinishedForeground) withObject:nil 
                        waitUntilDone:NO];	                        
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	loadFinished = NO;
	
	self.email = [OAuthCore getValueFromKeyChainFor:@"google-reader-login"];
	self.password = [OAuthCore getValueFromKeyChainFor:@"google-reader-password"];
	
	if (email != nil && password != nil) {
		waitView.hidden = NO;
		[activityView startAnimating];
		[GReaderLoader sharedInstance].delegate = self;		
		[self performSelectorInBackground:@selector(loadSourcesInBackground) withObject:nil];		
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
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [self setLoginButton:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.email = nil;
	self.password = nil;
	self.loginButton = nil;
	self.waitView = nil;
	self.activityView = nil;
	
    [super dealloc];
}


@end
