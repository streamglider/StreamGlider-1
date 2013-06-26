//
//  LocalLinksBrowserView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 07/10/2010.
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

#import "LocalLinksWebView.h"
#import "Core.h"
#import "BrowserViewController.h"
#import "StreamCastViewController.h"
#import "GenericPreviewViewController.h"


@implementation LocalLinksWebView

@synthesize streamCastViewController, text, previewController;

#pragma mark Properties

- (void)setText:(NSString*)t {
	text = [NSString stringWithFormat:@"<body style=\"font:14px Helvetica;background-color:white;color:black;\">%@</body>", t];
	self.delegate = self;
	self.dataDetectorTypes |= UIDataDetectorTypeLink;
	[self loadHTMLString:text baseURL:nil];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	if (previewController.waitView != nil) {
		[(UIActivityIndicatorView*)previewController.activityView stopAnimating];
		[previewController.waitView removeFromSuperview];
		previewController.waitView = nil;
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		// close preview
		[previewController closePreview];
		
		// open browser with the link clicked
		[streamCastViewController displayBrowserForRequest:request];		
		return NO;
	}
	return YES;
}

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
