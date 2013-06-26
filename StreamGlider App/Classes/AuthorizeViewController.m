    //
//  AuthorizeViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 05/08/2010.
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

#import "AuthorizeViewController.h"
#import "OAuth.h"

@interface AuthorizeViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)handleCloseTapped;

@end

@implementation AuthorizeViewController

@synthesize webView, request, oauth, tokenName, progressView, activityView;

#pragma mark Properties

- (void)setRequest:(NSURLRequest*)req {
	progressView.hidden = NO;
	[activityView startAnimating];
	
	if (request != nil) 
		[request release];
    
	request = req;
	
    if (request != nil) {
        [request retain];
        [webView loadRequest:request];
    }
}

#pragma mark Handlers

- (IBAction)handleCloseTapped {
	[webView loadHTMLString:@"" baseURL:nil];
	[oauth authorizationCancelled];			
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [self setWebView:nil];
    [self setProgressView:nil];
    [self setActivityView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityView stopAnimating];
	progressView.hidden = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req 
	navigationType:(UIWebViewNavigationType)navigationType {
	
	NSURL *url = [req URL];
	DebugLog(@"should start loading url: %@", url);
    
    NSString *siteHost = [[NSURL URLWithString:SITE_URL] host];
    
	if ([[url host] isEqualToString:siteHost]) {
		// extract verifier
		NSString *query = [url query];
		NSArray *params = [query componentsSeparatedByString:@"&"];
		
		for (NSString *pair in params) {
			NSArray *pairArray = [pair componentsSeparatedByString:@"="];
			NSString *key = [pairArray objectAtIndex:0];
			if ([key isEqualToString:tokenName]) {
				NSString* token = [pairArray objectAtIndex:1];
				[self dismissModalViewControllerAnimated:YES];
				[oauth authorizationGranted:token];
				return NO;
			}
		}
		
		// authorization cancelled
		[self dismissModalViewControllerAnimated:NO];
		[oauth authorizationCancelled];		
		return NO;
	}
	
	return YES;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.request = nil;
	self.tokenName = nil;
    self.webView = nil;
    self.progressView = nil;
    self.activityView = nil;
    
    [super dealloc];
}

@end
