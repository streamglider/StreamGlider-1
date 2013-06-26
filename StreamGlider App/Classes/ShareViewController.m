//
//  ShareViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 21/04/2011.
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

#import "ShareViewController.h"
#import "OAuthCore.h"
#import "OAuth2.h"
#import "OAuth.h"
#import "Frame.h"
#import "NSString+OAuth.h"


@interface ShareViewController () 

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *waitView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)handleCloseTapped:(id)sender;

@end

@implementation ShareViewController

@synthesize webView, waitView, activityView;

#pragma mark Handlers

- (IBAction)handleCloseTapped:(id)sender {
	[webView loadHTMLString:@"" baseURL:nil];
	[self dismissModalViewControllerAnimated:YES];    
}


#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
    
    NSString *siteHost = [[NSURL URLWithString:SITE_URL] host];
    
	if ([[url host] isEqualToString:siteHost]) {
		[self dismissModalViewControllerAnimated:YES];
		return NO;
	}
	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityView stopAnimating];
	waitView.hidden = YES;
}

#pragma mark Sharing

- (void)shareFrameWithFB:(Frame*)f {
	OAuth2 *oauth = (OAuth2*)[[OAuthCore sharedInstance] getOAuthForRealm:FACEBOOK_REALM];
	
    NSString *gs = [NSString stringWithFormat:@"[{\"name\":\"Get %@\", \"link\":\"%@\"}]", APP_NAME, SITE_URL];
    
    NSString *redirectString = [NSString stringWithFormat:@"%@/share_redirect", SITE_URL];
    
	NSString *urlString = [NSString stringWithFormat:@"http://www.facebook.com/dialog/feed?app_id=%@&link=%@&name=%@&display=touch&redirect_uri=%@&actions=%@",
						   oauth.clientID,
						   [NSString URLEncodeString:f.URLString],
						   [NSString URLEncodeString:[f description]],
						   [NSString URLEncodeString:redirectString],
						   [NSString URLEncodeString:gs]];
	
	DebugLog(@"%@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	
	[webView loadRequest:req];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[activityView startAnimating];
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
    [self setWebView:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.webView = nil;
	self.waitView = nil;
	self.activityView = nil;
    [super dealloc];
}


@end
