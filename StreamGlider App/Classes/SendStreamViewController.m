//
//  SendStreamViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 30/08/2011.
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

#import "SendStreamViewController.h"
#import "StreamSender.h"

@interface SendStreamViewController ()

@property (nonatomic, retain) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, retain) StreamSender *sender;

@property (nonatomic, copy) NSString *password;

- (IBAction)handleShareTapped;

@end

@implementation SendStreamViewController

@synthesize shareButton, email, stream, popover, sender, password;

#pragma mark Handlers

- (void)sendStream {
	self.sender = [[[StreamSender alloc] init] autorelease];	
    if (password != nil) {
        [sender sendDefaultStream:stream email:email password:password];
    } else {
        [sender sendStream:stream email:email];        
    }
}

- (IBAction)handleShareTapped {
	[self performSelectorInBackground:@selector(sendStream) withObject:nil];
	[popover dismissPopoverAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)isValidEmail:(NSString*)text {
	if (text == nil || [text length] < 4)
		return NO;
	
	NSString *regex = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL val = [predicate evaluateWithObject:[text uppercaseString]];
    
    if (!val) {
        // check if a user is trying to send a default stream
        if ([text rangeOfString:@"default:"].location == 0 && ![text isEqualToString:@"default:"]) {
            NSString *s = [text substringFromIndex:@"default:".length];
            int loc = [s rangeOfString:@":"].location;
            if (loc != NSNotFound && (loc + 1) != [s length]) {
                NSString *p = [s substringFromIndex:loc + 1];
                s = [s substringToIndex:loc];
                val = [predicate evaluateWithObject:[s uppercaseString]];   
                if (val) {
                    self.email = s;
                    self.password = p;
                }
            }
        }
    } else {
        self.password = nil;
    }
    
	return val;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self.email = [textField.text stringByReplacingCharactersInRange:range withString:string];		
	shareButton.enabled = [self isValidEmail:email];
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 
	
	if (shareButton.enabled) {
		[self handleShareTapped];
	}
	
	return YES; 
} 

- (void)textFieldDidEndEditing:(UITextField *)textField {	
	self.email = textField.text;
	shareButton.enabled = [self isValidEmail:email];	
}


#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.contentSizeForViewInPopover = CGSizeMake(460, 137);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Overriden to allow any orientation.
//    return YES;
//}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [self setShareButton:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.shareButton = nil;
	self.email = nil;
	self.sender = nil;
    self.password = nil;
	
    [super dealloc];
}


@end
