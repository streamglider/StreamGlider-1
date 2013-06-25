//
//  FBSmallFrameViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/09/2010.
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

#import "FBSmallFrameViewController.h"
#import "FBFrame.h"
#import "StreamCastViewController.h"
#import "CacheController.h"
#import "HighlightedTextView.h"

@implementation FBSmallFrameViewController

@synthesize userImage, userNameLabel, messageText, messageImage, backImage;

#pragma mark Displaying Data

- (void)displayFrameData {
	[super displayFrameData];
	
	FBFrame *fb = (FBFrame*)frame;
	if (fb != nil) {
		userNameLabel.text = fb.userName;	
		
		// user image
		userImage.image = [[CacheController sharedInstance] getImage:fb.userPictureURL];
		
		// post picture
		if (fb.message != nil && ![fb.message isEqualToString:@""]) {
			messageText.text = fb.message;
			messageImage.hidden = YES;			
		} else if (fb.imageURL != nil) {
			
			UIImage *img;
			if (showThumbnail) {
				img = [[CacheController sharedInstance] getImage:fb.thumbURL];
				messageImage.contentMode = UIViewContentModeScaleAspectFill;
			} else {
				img = [[CacheController sharedInstance] getImage:fb.imageURL];
				messageImage.contentMode = UIViewContentModeScaleAspectFit;
			}
			
			messageImage.image = img;
			messageText.hidden = YES;
		} 
	} 
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	messageText.fontName = @"HelveticaNeue-Bold";
	messageText.color = [UIColor colorWithRed:0.69 green:0.753 blue:0.82 alpha:1];
	messageText.fontSize = 15;
	messageText.insets = UIEdgeInsetsMake(0, 0, 0, 0);
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
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [self setUserImage:nil];
    [self setMessageImage:nil];
    [self setMessageText:nil];
    [self setUserNameLabel:nil];
    [self setBackImage:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.userImage = nil;
	self.userNameLabel = nil;
	self.messageText = nil;
	self.messageImage = nil;
	self.backImage = nil;
    [super dealloc];
}


@end
