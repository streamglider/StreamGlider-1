//
//  BrowserViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 24/08/2010.
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

#import "BrowserViewController.h"
#import "Frame.h"
#import "Feed.h"
#import "Stream.h"
#import "Core.h"
#import "StreamCastStateController.h"
#import "UIColor+SG.h"

@interface BrowserViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *navButtons;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;

- (IBAction)handleNavValueChanged;
- (IBAction)handleStreamsTapped;

@end

@implementation BrowserViewController
@synthesize activityView;
@synthesize backButton;

#define GAP 20

@synthesize webView, frame, progressView, request, navButtons, titleLabel;

#pragma mark Utility Methods

- (void)updateNavButtons {
	[navButtons setEnabled:[webView canGoBack] forSegmentAtIndex:0];	
	[navButtons setEnabled:[webView canGoForward] forSegmentAtIndex:1];	    
}

#pragma mark Properties

- (void)setRequest:(NSURLRequest*)req {
	request = req;
	
	progressView.hidden = NO;
    
	[activityView startAnimating];
	
	titleLabel.text = @"";
	
	[webView loadRequest:request];		
}

- (void)setFrame:(Frame*)newFrame {	
	frame = newFrame;
	
	progressView.hidden = NO;
	[activityView startAnimating];
	
	titleLabel.text = frame.description;
	
	NSURL *url = [NSURL URLWithString:frame.URLString];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	
	[webView loadRequest:req];		
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[activityView stopAnimating];
	titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	progressView.hidden = YES;
    [self updateNavButtons];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[self.webView loadRequest:req];
		return NO;
	}
    [self updateNavButtons];
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)webViewDidStartLoad:(UIWebView *)wv {
    [self updateNavButtons];
}

#pragma mark Handlers

- (IBAction)handleNavValueChanged {
	if (navButtons.selectedSegmentIndex == 0) {
		[webView goBack];		
	} else {
		[webView goForward];		
	}
}

- (IBAction)handleStreamsTapped {
	[self.navigationController popViewControllerAnimated:YES];
	
	[webView stopLoading];
	[webView loadHTMLString:@"" baseURL:nil];
    
	[[StreamCastStateController sharedInstance] exitBrowser];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	[navButtons setEnabled:NO forSegmentAtIndex:0];
	[navButtons setEnabled:NO forSegmentAtIndex:1];
    backButton.title = APP_NAME;
    
    
    progressView.backgroundColor = [UIColor gridCellBackgroundColor];
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
    [self setBackButton:nil];
    [self setActivityView:nil];
    [self setWebView:nil];
    [self setNavButtons:nil];
    [self setProgressView:nil];
    [self setTitleLabel:nil];    
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.webView = nil;
	self.progressView = nil;
	self.navButtons = nil;
	self.titleLabel = nil;
	
    [backButton release];
    [activityView release];
    [super dealloc];
}

@end
