//
//  PreviewViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/10/2010.
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

#import <QuartzCore/QuartzCore.h>
#import "PreviewViewController.h"
#import "Core.h"
#import "StreamCastViewController.h"
#import "Frame.h"
#import "SlideShowViewController.h"
#import "TwitterFrame.h"
#import "ShareViaTwitter.h"
#import "SmallFrameViewController.h"
#import "PreviewView.h"
#import "StreamsTableViewController.h"
#import "OAuthCore.h"
#import "OAuth.h"
#import "OAuth2.h"
#import "StreamCastStateController.h"
#import "ShareViewController.h"
#import "SettingsController.h"
#import "MagModeViewController.h"

@interface PreviewViewController ()

@property (nonatomic, retain) IBOutlet UIButton *shareButton;

@property (nonatomic, retain) ShareViaTwitter *twitterShare;

@property (nonatomic, retain) NSArray *frames;

@property (assign) int phasesLeft;

@property (assign) BOOL playing;

- (IBAction)handleOpenInBrowserTapped;
- (IBAction)handleSlideshowTapped;
- (IBAction)closeTappedHandler;
- (IBAction)handleShareTapped;

- (void)previewWasClosed;

@end

@implementation PreviewViewController {
    CGFloat frameHeight;
    UIActionSheet *actionSheet;
}

@synthesize streamCastViewController, shareButton, twitterShare, 
	firstFrameRect, panelView, frames, phasesLeft, selectedFrameIndex, playing, magMode, magModeVC;

#pragma mark Preview Animation

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self.view removeFromSuperview];	
    
    if (!magMode) {    
        streamCastViewController.previewViewController = nil;
        [[StreamCastStateController sharedInstance] exitPreview]; 	
        
        if ([SettingsController sharedInstance].removeViewedFrames)
            [[Core sharedInstance] removeAllFramesWithURL:self.frame.URLString];
    } else {
        magModeVC.previewVC = nil;
    }
}

- (UIImageView*)prepareImageForFrame:(SmallFrameViewController*)vc {
	UIGraphicsBeginImageContext(vc.view.frame.size);
	
	[vc.view.layer renderInContext:UIGraphicsGetCurrentContext()];	
	UIImageView *ret = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
	
	UIGraphicsEndImageContext();
	return [ret autorelease];
}

- (void)displayPanel {
    panelView.hidden = NO;

    self.playing = NO;

    if (!magMode)
        streamCastViewController.displayingPreview = NO;	
}

- (void)play {
    [self.view setNeedsLayout];
    
    [self displayPanel];
    
    return;    
}

#pragma mark Handlers

- (IBAction)closeTappedHandler {
	actionSheet = nil;
	[self previewWasClosed];
	[UIView beginAnimations:@"closingAnimation" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.view.alpha = 0;
	
	[UIView commitAnimations];
}

- (IBAction)handleOpenInBrowserTapped {
	if (actionSheet != nil) {
		[actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
		actionSheet = nil;
	}
	[self previewWasClosed];
	[self.view removeFromSuperview];	
	[streamCastViewController displayBrowserForFrame:self.frame];
    
    if (!magMode)
        streamCastViewController.previewViewController = nil;
    else
        magModeVC.previewVC = nil;
}

- (IBAction)handleSlideshowTapped {
	if (actionSheet != nil) {
		[actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
		actionSheet = nil;
	}
	[self previewWasClosed];	
	
	[StreamCastStateController sharedInstance].animateView = panelView;
	CGRect rect = panelView.frame;
	[StreamCastStateController sharedInstance].animateRect = rect;
	streamCastViewController.slideShowViewController.frame = self.frame;
	[[StreamCastStateController sharedInstance] switchToState:StreamLayoutSlideshow];
	
    if (!magMode && [StreamCastStateController sharedInstance].isPlaying) {
        streamCastViewController.slideShowViewController.shouldResumeTable = YES;
    } else {
        streamCastViewController.slideShowViewController.shouldResumeTable = NO;
    }
    
	[StreamCastStateController sharedInstance].isPlaying = NO;
	[self.view removeFromSuperview];
	
    if (!magMode)
        streamCastViewController.previewViewController = nil;	
    else
        magModeVC.previewVC = nil;
}

- (IBAction)handleShareTapped {
	if (actionSheet == nil) {
		if ([self.frame isMemberOfClass:[TwitterFrame class]]) {
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Using" 
													  delegate:self 
											 cancelButtonTitle:nil 
										destructiveButtonTitle:nil 
											 otherButtonTitles:@"Email", @"Twitter", @"Retweet", @"Facebook", nil];
		} else {
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Using" 
													  delegate:self 
											 cancelButtonTitle:nil 
										destructiveButtonTitle:nil 
											 otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
		}
		
		[actionSheet showFromRect:CGRectMake(0, 0, 30, 30) inView:shareButton animated:YES];
	}
}

#pragma mark Closing Preview

- (void)closePreview {
	[self previewWasClosed];
	[self.view removeFromSuperview];
	
    if (!magMode) {
        [[StreamCastStateController sharedInstance] exitPreview]; 		
        streamCastViewController.previewViewController = nil;
    } else {
        magModeVC.previewVC = nil;
    }        
}


- (void)previewWasClosed {
	[Core sharedInstance].cardImage = nil;
}


#pragma mark UIActionSheetDelegate

- (void)displayALert:(NSString*)title message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message 
												   delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

- (void)actionSheet:(UIActionSheet*)acSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	actionSheet = nil;
	ShareViewController *sc;
	switch (buttonIndex) {
		case 0:
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
				emailVC.modalPresentationStyle = UIModalPresentationFormSheet;
				emailVC.mailComposeDelegate = self;
                
                NSString *body = [NSString stringWithFormat:@"<br><br>%@ story frame was whared with you. ", APP_NAME];
                if ([Core sharedInstance].userEmail) {
                    body = [NSString stringWithFormat:@"<br><br>%@ has shared a %@ story frame with you. ", 
                     [Core sharedInstance].userEmail, APP_NAME];
                }
                
				body = [NSString stringWithFormat:@"%@To view the story, click the link below. If you want to see more news and information, download %@ on your iPad and see all our streams and articles.<br><br> <a href=\"%@\">%@</a>", body, APP_NAME,
                                  self.frame.URLString, [self.frame description]];
				
				[emailVC setMessageBody:body isHTML:YES];
                
				[streamCastViewController presentModalViewController:emailVC animated:YES];
                
			} else {
				[self displayALert:@"Email Problem" message:@"We can't send emails at the moment!"];
			}
			break;
		case 1:
			// twitter			
			self.twitterShare = [[[ShareViaTwitter alloc] init] autorelease];
			twitterShare.streamCastViewController = streamCastViewController;
			[twitterShare shareFrame:self.frame retweet:NO];
			break;
		case 2:
			if ([self.frame isMemberOfClass:[TwitterFrame class]]) {
				self.twitterShare = [[[ShareViaTwitter alloc] init] autorelease];
				twitterShare.streamCastViewController = streamCastViewController;
				[twitterShare shareFrame:self.frame retweet:YES];				
			} else {
				// send a link to FB	
				sc = [[ShareViewController alloc] 
					  initWithNibName:@"ShareViewController" 
					  bundle:nil];
				sc.modalPresentationStyle = UIModalPresentationFormSheet;
				[self presentModalViewController:sc animated:YES];
				[sc shareFrameWithFB:self.frame];
				[sc release];				
			}
			break;	
		case 3:
			// send a link to FB	
			sc = [[ShareViewController alloc] 
				  initWithNibName:@"ShareViewController" 
				  bundle:nil];
			sc.modalPresentationStyle = UIModalPresentationFormSheet;
			[self presentModalViewController:sc animated:YES];
			[sc shareFrameWithFB:self.frame];
			[sc release];				
			break;
	}
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissModalViewControllerAnimated:YES];
	NSString *t, *m;
	switch (result) {
		case MFMailComposeResultFailed:
			t = @"Email Error";
			m = [NSString stringWithFormat:@"Email message was not sent, error: \"%@\"", error];
			break;
		case MFMailComposeResultSaved:
			t = @"Message Saved";
			m = @"Your message was saved in the Drafts folder";
			break;
		case MFMailComposeResultSent:
			t = @"Message Sent";
			m = @"Your email was sent successfully!";
			break;	
        case MFMailComposeResultCancelled:
            // empty
            break;
	}
	if (result != MFMailComposeResultCancelled) {
		[self displayALert:t message:m];
	}
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint pt = [touch locationInView:panelView];
	
	if (!self.playing) {
		if (![panelView hitTest:pt withEvent:event]) {
			[self closeTappedHandler];
		} 
	}
}


#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	((PreviewView*)self.view).viewController = self;
    
	panelView.hidden = YES;
    
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.playing = YES;
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
    [self setShareButton:nil];
    [self setPanelView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.twitterShare = nil;
	self.frames = nil;
	self.shareButton = nil;
	self.panelView = nil;
	
    [super dealloc];
}


@end
