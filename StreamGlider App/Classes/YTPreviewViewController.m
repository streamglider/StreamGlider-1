    //
//  YTPreviewViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 27/10/2010.
//  Copyright 2010 SemantiStar, Inc. All rights reserved.
//

#import "YTPreviewViewController.h"
#import "LocalLinksWebView.h"
#import "YTFrame.h"


@implementation YTPreviewViewController

@synthesize webView, publishedLabel, titleLabel;

- (void)displayFrameData {
	if (frame != nil) {
		YTFrame *yf = (YTFrame*)frame;
		
		NSString* embedHTML = @"\
			<html><head>\
			<style type=\"text/css\">\
			body {\
			background-color: transparent;\
			color: white;\
			}\
			</style>\
			</head><body style=\"margin:0\">\
			<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
			width=\"%0.0f\" height=\"%0.0f\"></embed>\
			</body></html>";  		
				
		NSString *htmlString = [NSString stringWithFormat:embedHTML, yf.URLString, 
								webView.frame.size.width, webView.frame.size.height];
		
		[webView loadHTMLString:htmlString baseURL:nil];
		
		titleLabel.text = yf.title;
		
		publishedLabel.text = [Frame formatDate:yf.published];
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
    [super viewDidLoad];
	webView.streamCastViewController = streamCastViewController;
}

- (void)previewWasClosed {
	[webView loadHTMLString:@"" baseURL:nil];	
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
