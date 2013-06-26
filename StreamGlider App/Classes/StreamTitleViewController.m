//
//  StreamTitleViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 05/11/2010.
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

#import "StreamTitleViewController.h"
#import "Stream.h"
#import "OtherStreamTableViewCell.h"

@interface StreamTitleViewController ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) IBOutlet UIImageView *backImage;

@end

@implementation StreamTitleViewController {
    BOOL isActive;
}

@synthesize titleLabel, titleTextField, stream, backImage, cell;

#pragma mark Properties

- (void)setStream:(Stream*)s {
	stream = s;
	titleLabel.text = stream.title;
	titleTextField.text = stream.title;
}

#pragma mark Editing

- (void)setupEditing {
	if (isActive)
		return;
	
	isActive = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];	
	
	[UIView beginAnimations:@"StreamTitleRotation" context:nil];
	[UIView setAnimationDuration:0.4];
	
	CGPoint pt = self.view.center;
	pt.x += 50;
	self.view.center = pt;
	self.view.transform = CGAffineTransformIdentity;
	
	titleLabel.hidden = YES;
	titleTextField.hidden = NO;
	[titleTextField becomeFirstResponder];
	
	pt = cell.pagingView.center;
	pt.x += 100;
	cell.pagingView.center = pt;
	
	[UIView commitAnimations];		
}

- (void)dropEditing {
	if (isActive) {
		isActive = NO;
		
		[titleTextField resignFirstResponder];
		
		NSString *newTitle = titleTextField.text;
		if ([newTitle isEqualToString:@""]) {
			newTitle = @"Please Enter Stream Title!";
			titleTextField.text = newTitle;
		}
		titleLabel.text = newTitle;
		stream.title = newTitle;
		
		[UIView beginAnimations:@"StreamTitleRotation" context:nil];
		[UIView setAnimationDuration:0.4];
		
		CGPoint pt = self.view.center;
		pt.x -= 50;
		self.view.center = pt;
		
		self.view.transform = CGAffineTransformMakeRotation(-(M_PI / 2));
		
		titleLabel.hidden = NO;
		titleTextField.hidden = YES;
		
		pt = cell.pagingView.center;
		pt.x -= 100;
		cell.pagingView.center = pt;
		
		[UIView commitAnimations];
	}
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 1 || touch.tapCount == 2) {
		[self setupEditing];
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

#pragma mark Keyboard Notifications

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	[cell adjustTableForKeyboardWithHeight:MIN(kbSize.height, kbSize.width)];	
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self];		
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	isActive = NO;
	self.view.frame = CGRectMake(0, 0, 131, 29);
	self.view.center = CGPointMake(31, 104);
	backImage.transform = CGAffineTransformMakeRotation((M_PI / 2));
	self.view.transform = CGAffineTransformMakeRotation(-(M_PI / 2));		
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
    [self setTitleLabel:nil];
    [self setTitleTextField:nil];
    [self setBackImage:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.titleLabel = nil;
	self.titleTextField = nil;
	self.backImage = nil;
	self.stream = nil;
	
    [super dealloc];
}


@end
