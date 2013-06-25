//
//  LocalLinksBrowserView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 07/10/2010.
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
