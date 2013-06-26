//
//  UniversalPreviewViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 31/01/2011.
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

#import "GenericPreviewViewController.h"
#import "Frame.h"
#import "YTFrame.h"
#import "FlickrFrame.h"
#import "LocalLinksWebView.h"
#import "CacheController.h"

@interface GenericPreviewViewController ()

@property (nonatomic, retain) IBOutlet LocalLinksWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@property (retain, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)handleDoneTapped;

@end

@implementation GenericPreviewViewController

@synthesize closeButton;

@synthesize webView, titleLabel, imageView, waitView, activityView;

- (IBAction)handleDoneTapped {
	[self closePreview];
}

#pragma mark FrameViewController

- (void)displayFrameData {
	if (frame != nil) {
		
		if ([frame isMemberOfClass:[YTFrame class]]) {
			YTFrame *yf = (YTFrame*)frame;
			
			NSString* embedHTML = @"<html><head><style type=\"text/css\"> body { background-color: black; color: black;} </style> </head><body style=\"margin:0\"> <embed id=\"yt\" src=\"http://www.youtube.com/v/%@\" type=\"application/x-shockwave-flash\" width=\"100%%\" height=\"100%%\"></embed></body></html>";  		
			
            // extract YT video ID
            int start = [yf.URLString rangeOfString:@"watch?v="].location + @"watch?v=".length;
            int length = [yf.URLString rangeOfString:@"&"].location - start;
            
            NSString *videoID = [yf.URLString substringWithRange:NSMakeRange(start, length)];
            
			NSString *htmlString = [NSString stringWithFormat:embedHTML, videoID];
			
			[webView loadHTMLString:htmlString baseURL:nil];			
		} else if ([frame isMemberOfClass:[FlickrFrame class]]) {
			[webView removeFromSuperview];
			FlickrFrame *ff = (FlickrFrame*)frame;			
			imageView.image = [[CacheController sharedInstance] getImage:ff.imageURL];
		} else {
			waitView.hidden = NO;
			[activityView startAnimating];
			NSURL *url = [NSURL URLWithString:frame.URLString];
			NSURLRequest *request = [NSURLRequest requestWithURL:url];
			[webView loadRequest:request];			
		}

		titleLabel.text = [frame description];
	}
}

#pragma mark PreviewViewController

- (void)previewWasClosed {
	[webView loadHTMLString:@"" baseURL:nil];	
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	webView.streamCastViewController = self.streamCastViewController;	
	webView.delegate = webView;
	titleLabel.font = [UIFont fontWithName:@"Lexia" size:15];
    
    if (self.magMode) {
        closeButton.imageView.image = [UIImage imageNamed:@"magazine_mode.png"];
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
    [self setCloseButton:nil];
    [self setWebView:nil];
    [self setTitleLabel:nil];
    [self setImageView:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
        
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	webView.delegate = nil;
	self.webView = nil;
	self.titleLabel = nil;
	self.imageView = nil;
	self.waitView = nil;
	self.activityView = nil;
    [closeButton release];
    [super dealloc];
}


@end
