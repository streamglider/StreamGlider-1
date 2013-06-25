//
//  RssSmallFrameViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 16/08/2010.
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

#import "RSSSmallFrameViewController.h"
#import "RSSFrame.h"
#import "RSSFeed.h"
#import "StreamCastViewController.h"
#import "CacheController.h"
#import "Stream.h"
#import "HighlightedTextView.h"
#import "DogEarView.h"


@implementation RSSSmallFrameViewController

@synthesize titleView, imageView, fontSize, feedTitleView, backImage, 
	imageTitleView, imageFeedTitleView, textPanel, imagePanel, hasImage;

#pragma mark Source Bar Hiding

- (BOOL)supportsSourceBarHiding {
	RSSFrame *rf = (RSSFrame*)frame;
	return rf.imageURL != nil;
}

- (UIView*)getSourceBarView {
	return imagePanel;
}

#pragma mark Displaying Data

- (void)displayFrameData {
	[super displayFrameData];
	
	RSSFrame *rf = (RSSFrame*)frame;
	
	self.hasImage = rf.imageURL != nil;
	
	if (rf != nil) {								
		UIImage *img = nil;
		if (rf.imageURL != nil) {
			if (showThumbnail) {
				img = [[CacheController sharedInstance] getImage:rf.thumbURL];
//				if (img.size.width < 220 || img.size.height < 155) 
//					img = nil;
				imageView.contentMode = UIViewContentModeScaleAspectFill; 
			} else { 
				img = [[CacheController sharedInstance] getImage:rf.imageURL];
//				if (img.size.width < 220 || img.size.height < 155) 
//					img = nil;
				imageView.contentMode = UIViewContentModeScaleAspectFit;				
			}
			
//			dogEarView.frame = CGRectOffset(dogEarView.frame, 0, -imagePanel.frame.size.height);
		}
		
		if (img == nil) {			
			[imageView removeFromSuperview];
		} else {
			imageView.image = img;						
		}
		
		RSSFeed *f = (RSSFeed*)rf.feed;
		
		if (rf.imageURL == nil) {
			[imagePanel removeFromSuperview]; 
			feedTitleView.text = f.feedTitle;		
			titleView.text = rf.title;			
		} else {
			[textPanel removeFromSuperview];			
			imageFeedTitleView.text = f.feedTitle;		
			imageTitleView.text = rf.title;			
		}

	} 	
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// text panel
	titleView.fontName = @"HelveticaNeue-Bold";
	titleView.color = [UIColor colorWithRed:0.69 green:0.753 blue:0.82 alpha:1];
	titleView.fontSize = 20;
	
	titleView.insets = UIEdgeInsetsMake(0, 0, 0, 0);	
	
	feedTitleView.fontName = @"HelveticaNeue-Bold";
	feedTitleView.color = [UIColor colorWithRed:0.5 green:0.57 blue:0.66 alpha:1];
	feedTitleView.fontSize = 14;
	
	feedTitleView.insets = UIEdgeInsetsMake(5, 0, 0, 0);		
	feedTitleView.oneLiner = YES;

	// image panel
	imageTitleView.fontName = @"HelveticaNeue-Bold";
//	imageTitleView.highlightColor = [UIColor colorWithRed:0.067 green:0.098 blue:0.141 alpha:1];
	imageTitleView.color = [UIColor colorWithRed:0.69 green:0.753 blue:0.82 alpha:1];
	imageTitleView.fontSize = 13;
	
	imageTitleView.insets = UIEdgeInsetsMake(3, 10, 3, 3);	
	
	imageFeedTitleView.fontName = @"HelveticaNeue-Bold";
//	imageFeedTitleView.highlightColor = [UIColor colorWithRed:0.067 green:0.098 blue:0.141 alpha:1];
	imageFeedTitleView.color = [UIColor colorWithRed:0.5 green:0.57 blue:0.66 alpha:1];
	imageFeedTitleView.fontSize = 11;
		
	imageFeedTitleView.insets = UIEdgeInsetsMake(3, 10, 3, 3);		
	imageFeedTitleView.oneLiner = YES;
	
	imagePanel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:CAPTION_BAR_OPACITY];	
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
    [self setTitleView:nil];
    [self setFeedTitleView:nil];
    [self setImageTitleView:nil];
    [self setImageFeedTitleView:nil];
    [self setTextPanel:nil];
    [self setImagePanel:nil];
    [self setImageView:nil];
    [self setBackImage:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.titleView = nil;
	self.imageView = nil;	
	self.feedTitleView = nil;
	self.backImage = nil;
	self.imageTitleView = nil;
	self.imageFeedTitleView = nil;
	self.textPanel = nil;
	self.imagePanel = nil;
    [super dealloc];
}


@end
