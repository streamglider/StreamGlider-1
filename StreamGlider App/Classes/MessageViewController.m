//
//  SendToFBMessageViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 11/11/2010.
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

#import <QuartzCore/QuartzCore.h>
#import "MessageViewController.h"
#import "FBFrame.h"
#import "Core.h"

@interface MessageViewController ()

@property (nonatomic, retain) IBOutlet UIImageView *cardImage;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

- (IBAction)handleCancelTapped;
- (IBAction)handleShareTapped;

@end

@implementation MessageViewController

@synthesize textView, target, callback, shareButton, maxCharCount, statusLabel, cardImage;

#pragma mark Handlers

- (IBAction)handleCancelTapped {
	[self dismissModalViewControllerAnimated:YES];	
}

- (IBAction)handleShareTapped {
	[self dismissModalViewControllerAnimated:NO];
	[target performSelector:callback withObject:textView.text];
}

- (void)updateStatusForText:(NSString*)text {
	shareButton.enabled = text != nil && ![text isEqualToString:@""];
	if (maxCharCount != -1 && shareButton.enabled) {
		shareButton.enabled = [text length] <= maxCharCount;
		
		int rem = maxCharCount - [text length];
		statusLabel.text = [NSString stringWithFormat:@"%d", rem];
		if (rem >= 20) {
			statusLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
		} else if (rem < 20 && rem >= 10) {
			statusLabel.textColor = [UIColor colorWithRed:0.361 green:0 blue:0.071 alpha:1];			
		} else {
			statusLabel.textColor = [UIColor colorWithRed:0.831 green:0.051 blue:0.071 alpha:1];						
		}
	}
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)tv shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSString *textToBe = [tv.text stringByReplacingCharactersInRange:range withString:text];
	[self updateStatusForText:textToBe];
	return YES;
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[textView.layer setBorderColor:[UIColor grayColor].CGColor];
	[textView.layer setBorderWidth:1.0];
	[textView.layer setCornerRadius:4.0f];
	[textView.layer setMasksToBounds:YES];
	
	cardImage.image = [Core sharedInstance].cardImage;
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
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [self setTextView:nil];
    [self setShareButton:nil];
    [self setStatusLabel:nil];
    [self setCardImage:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.textView = nil;
	self.shareButton = nil;
	self.statusLabel = nil;
	self.cardImage = nil;
    [super dealloc];
}


@end
