//
//  RSSArticleViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 03/11/2011.
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

#import <QuartzCore/QuartzCore.h>

#import "RSSArticleViewController.h"
#import "RSSFrame.h"
#import "DTAttributedTextView.h"
#import "DTAttributedTextContentView.h"
#import "DTLinkButton.h"
#import "UIColor+SG.h"
#import "CacheController.h"
#import "StreamCastStateController.h"
#import "StreamCastViewController.h"
#import "MagModeViewController.h"

@interface RSSArticleViewController ()

@property (retain, nonatomic) IBOutlet UIView *waitView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableArray *lazyImages;

@end

@implementation RSSArticleViewController
@synthesize titleLabel;
@synthesize textArea;
@synthesize waitView;
@synthesize activityView;
@synthesize magModeVC;
@synthesize lazyImages;

#pragma mark Handlers

- (void)linkTapped:(DTLinkButton*)button {
    [[StreamCastStateController sharedInstance].streamCastViewController displayBrowserForRequest:[NSURLRequest requestWithURL:button.url]];
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    if (t.tapCount == 1) {
        [magModeVC displayPreviewForFrame:frame];
    }
}

#pragma mark DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    
	NSURL *url = lazyImageView.url;
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [textArea.contentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
		oneAttachment.originalSize = size;
        
        CGFloat ratio = size.height / (textArea.frame.size.width - 20.0);
        CGSize displaySize = size;
        if (ratio > 1)
            displaySize = CGSizeMake(size.width / ratio, size.height / ratio);
		
		if (!CGSizeEqualToSize(displaySize, oneAttachment.displaySize))
		{
			oneAttachment.displaySize = displaySize;
		}
	}
	
	// redo layout
	// here we're layouting the entire string, might be more efficient to only relayout the paragraphs that contain these attachments
	[textArea.contentView relayoutText];
}

#pragma mark DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)f
{
	if (attachment.contentType == DTTextAttachmentTypeImage) {
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[[DTLazyImageView alloc] initWithFrame:f] autorelease];
                
		imageView.delegate = self;
        
        [lazyImages addObject:imageView];
        
        NSURL *url = attachment.contentURL;
        if (url.host == nil) {
            NSURL *frameURL = [NSURL URLWithString:frame.URLString];
            NSString *path = url.path;
            if ([path rangeOfString:@"/"].location != 0) 
                path = [NSString stringWithFormat:@"/%@", path];
            
            NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", frameURL.scheme, frameURL.host, path];
            url = [NSURL URLWithString:urlString];
        }
        
		// url for deferred loading
		imageView.url = url;
		
		return imageView;
	}
	
	return nil;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)f
{
    if (url.host == nil) {
        NSURL *frameURL = [NSURL URLWithString:frame.URLString];
        NSString *path = url.path;
        if ([path rangeOfString:@"/"].location != 0) 
            path = [NSString stringWithFormat:@"/%@", path];
        
        NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", frameURL.scheme, frameURL.host, path];
        url = [NSURL URLWithString:urlString];
    }
    
	DTLinkButton *button = [[[DTLinkButton alloc] initWithFrame:f] autorelease];
	button.url = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.guid = identifier;
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkTapped:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}


#pragma mark FrameViewController

- (void)displayFrameData {
    RSSFrame *f = (RSSFrame*)frame;
    titleLabel.text = f.title;
    
    if (!f.articleRetrieved) {
        return;
    }
        
    [activityView stopAnimating];
    waitView.hidden = YES;
    
	// Load HTML data
	NSData *data;
    
    if (f.articleBodyURL != nil) {
        data = [[CacheController sharedInstance] getResourceData:f.articleBodyURL];
    } else {
        data = [f.frameDescription dataUsingEncoding:NSUTF8StringEncoding];         
    }
    
	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(textArea.frame.size.width - 20.0, 0);
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.4], NSTextSizeMultiplierDocumentOption, 
                             [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize, 
                             @"Georgia", DTDefaultFontFamily,  
                             [UIColor colorWithRed:0.631 green:0.694 blue:0.776 alpha:1], DTDefaultTextColor,
                             [UIColor colorWithRed:0.2 green:0.412 blue:0.824 alpha:1], DTDefaultLinkColor, 
                             nil, NSBaseURLDocumentOption, nil]; 
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:NULL];
	
	// Display string
	self.textArea.attributedString = string;
    [string release];    
}

#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    activityView.center = waitView.center;
    [activityView startAnimating];
    
    self.lazyImages = [[[NSMutableArray alloc] init] autorelease];
    
	[DTAttributedTextContentView setLayerClass:[CATiledLayer class]];
    CGRect f = self.view.frame;
    f.origin = CGPointMake(10, 80);
    f.size = CGSizeMake(f.size.width - 20, f.size.height - 90);
    self.textArea = [[[DTAttributedTextView alloc] initWithFrame:f] autorelease];
    
    self.textArea.textDelegate = self;
    
	self.textArea.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;  
    self.textArea.backgroundColor = [UIColor gridCellBackgroundColor];
    
    self.view.backgroundColor = [UIColor gridCellBackgroundColor];
    
    [self.view insertSubview:textArea atIndex:1];
        
    [self displayFrameData];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTextArea:nil];
    [self setWaitView:nil];
    [self setActivityView:nil];
    [self setLazyImages:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark Lifecycle

- (void)dealloc {
    for (DTLazyImageView *lv in lazyImages) {
        lv.delegate = nil;
    }
    [lazyImages release];
    
    [titleLabel release];
    [textArea release];
    [waitView release];
    [activityView release];
    [super dealloc];
}
@end
