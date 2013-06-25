    //
//  TwitterPreviewViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/10/2010.
//  Copyright 2010 SemantiStar, Inc. All rights reserved.
//

#import "TwitterPreviewViewController.h"
#import "LocalLinksWebView.h"
#import "TwitterFrame.h"
#import "Core.h"
#import "StreamCastViewController.h"
#import "CacheController.h"


@implementation TwitterPreviewViewController

@synthesize webView, userNameLabel, userImage, createdAtLabel, textView;

- (void)displayFrameData {
	if (frame != nil) {
		TwitterFrame *tf = (TwitterFrame*)frame;
		
		NSURL *url = [NSURL URLWithString:tf.URLString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[webView loadRequest:request];
		
		userNameLabel.text = tf.userName;
		
		userImage.image = [[CacheController sharedInstance]	getImage:tf.imageURL];	 
		
		createdAtLabel.text = [NSString stringWithFormat:@"%@ via Twitter", 
							   [Frame formatDate:tf.createdAt]];
		textView.text = tf.text;
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	webView.streamCastViewController = streamCastViewController;
    [super viewDidLoad];
} 



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
