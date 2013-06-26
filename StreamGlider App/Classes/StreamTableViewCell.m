//
//  StreamTableViewCell.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/21/10.
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

#import "StreamTableViewCell.h"
#import "Stream.h"
#import "SmallFrameFactory.h"
#import "SmallFrameViewController.h"
#import "StreamCastViewController.h"
#import "SlideShowViewController.h"
#import "StreamCastStateController.h"
#import "Core.h"
#import "DogEarView.h"
#import "Frame.h"
#import "SettingsController.h"
#import "SendStreamViewController.h"
#import "MagModeViewController.h"
#import "PageOfStreams.h"

@interface StreamTableViewCell ()

@property (nonatomic, retain) IBOutlet UILabel *streamTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *titleBGImage;
@property (nonatomic, retain) IBOutlet UIView *clipView;


@end

@implementation StreamTableViewCell

@synthesize scrollView, streamTitleLabel, frameControllers, streamCastViewController, stream, 
	zoomingFrameIndex, zoomingFrameOffset, animate, titleBGImage, clipView, sharePopover;

#define FRAMES_ON_SCREEN 5

#pragma mark Properties

- (void)setStream:(Stream *)newStream{
	
	if (stream != nil) {		
		[stream removeStreamDelegate:self];
	}	
	
	stream = newStream;
		
	if (stream == nil)
		return;
	
	[stream addStreamDelegate:self];
	
	// remove all subviews from scroll view's content view 
	for (UIViewController* c in frameControllers) {
		[c.view removeFromSuperview];
	}
	
	NSMutableArray *fc = [[NSMutableArray alloc] init];
	self.frameControllers = fc;
	[fc release];
	
	streamTitleLabel.text = stream.title;
	
	// create frame subviews	
	for (int i = [stream.frames count] - 1; i >= 0; i--) {
		Frame *f = [stream.frames objectAtIndex:i];
		SmallFrameViewController *c = [SmallFrameFactory createSmallFrameViewFor:f];
		c.showThumbnail = YES;
		c.target = streamCastViewController;
		c.tapAction = @selector(displayViewForFrame:);
		c.doubleTapTarget = self;
		c.doubleTapAction = @selector(openFrameInFullScreen:);
		[self.frameControllers insertObject:c atIndex:0];
				
		[scrollView insertSubview:c.view atIndex:0];
	}	
}

#pragma mark Frame Data

- (void)openFrameInFullScreen:(Frame*)f {
	if (streamCastViewController.previewViewController != nil || streamCastViewController.displayingPreview)
		return;
	
	// find small frame VC
	for (SmallFrameViewController *vc in frameControllers) {
		if (vc.frame == f) {
			[StreamCastStateController sharedInstance].animateView = vc.view;
			CGRect rect = [scrollView convertRect:vc.view.frame toView:self];
			rect = [self convertRect:rect toView:streamCastViewController.view];
			[StreamCastStateController sharedInstance].animateRect = rect;
			break;
		}
	}
	
	[[StreamCastStateController sharedInstance] switchToState:StreamLayoutSlideshow];
	streamCastViewController.slideShowViewController.frame = f;
    streamCastViewController.slideShowViewController.shouldResumeTable = NO;
}

- (int)frameIndexForPoint:(CGPoint)pt {
	int i = 0;
	for (SmallFrameViewController *c in frameControllers) {
		CGPoint p = [c.view convertPoint:pt fromView:self];
		if ([c.view pointInside:p withEvent:nil]) {
			return i;
		}
		i++;
	}
	return -1;
}

#pragma mark StreamDelegate

- (void)frameWasAdded:(Frame*)f {
	// create frame subview and add to the beginning of the stream
	SmallFrameViewController *c = [SmallFrameFactory createSmallFrameViewFor:f];
	c.showThumbnail = YES;
	c.target = streamCastViewController;
	c.tapAction = @selector(displayViewForFrame:);
	c.doubleTapTarget = self;
	c.doubleTapAction = @selector(openFrameInFullScreen:);
	[self.frameControllers insertObject:c atIndex:0];
	
	float k;
	if ([SettingsController sharedInstance].plusMode)
		k = self.frame.size.height / PLUS_MODE_CELL_HEIGHT;
	else 
		k = self.frame.size.height / CELL_HEIGHT;
	float w = FRAME_WIDTH * k;
	float h = FRAME_HEIGHT * k;
	c.view.frame = CGRectMake(-w, 0, w, h);
	
	[scrollView insertSubview:c.view atIndex:0];	
	
	if ([StreamCastStateController sharedInstance].currentState == StreamLayoutTable) {
		c.dogEarView.isNew = [[Core sharedInstance] isFrameNew:f.URLString];
	} else {
		c.dogEarView.isNew = NO;
	}

	self.animate = YES;
	
	[self layoutSubviews];
}

- (void)frameWasRemoved:(Frame*)frame {
	// find and remove frame from the cell
	int count = [frameControllers count];
	for (int i = count - 1; i >= 0; i--) {
		SmallFrameViewController *c = [frameControllers objectAtIndex:i];
		if (c.frame == frame) {	
			
			[[Core sharedInstance] releaseFrameFromViewed:c];
                        
            [c.view removeFromSuperview];						
            [frameControllers removeObject:c];	
            
            self.animate = YES;
            [self layoutSubviews];
			
			break;
		}
	}	
}

-(void)titleWasChanged:(Stream*)changedStream {
	streamTitleLabel.text = changedStream.title;
}

#pragma mark Touches

- (void)showShareStreamPopover {
    if (![Core sharedInstance].userEmail) {        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shared Streams" message:@"In order to use shared streams functionality please register with the system." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    SendStreamViewController *sender;
    if (sharePopover == nil) {
        // display share stream popover
        sender = [[[SendStreamViewController alloc] initWithNibName:@"SendStreamViewController" 
                                                            bundle:nil] autorelease];
        self.sharePopover = [[[UIPopoverController alloc] initWithContentViewController:sender] autorelease];
        sender.popover = sharePopover;
    } else {
        sender = (SendStreamViewController*)sharePopover.contentViewController;
    }
    
    sender.stream = stream;	
    
    CGRect rect;
    UIView *v;
    if ([SettingsController sharedInstance].plusMode) {
        rect = streamTitleLabel.frame;
        v = streamTitleLabel;
    } else {
        rect = titleBGImage.frame;
        v = titleBGImage;
    }
    
    rect.origin = CGPointZero;
    [sharePopover presentPopoverFromRect:rect inView:v permittedArrowDirections:UIPopoverArrowDirectionAny 
                                animated:YES];		    
}

- (void)pushMagazineModeVC {    
    PageOfStreams *p = [[Core sharedInstance] getActivePage];
    p.magModeIndex = [[Core sharedInstance].streams indexOfObject:stream];
    
    MagModeViewController *mvc = [[MagModeViewController alloc] initWithNibName:@"MagModeViewController" bundle:nil];
    mvc.stream = stream;
    mvc.openStreamsPanel = NO;
    
    [streamCastViewController.navigationController pushViewController:mvc animated:YES];
    [mvc autorelease];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	UITouch *touch = [touches anyObject]; 
	if(touch.tapCount == 2) {
		[StreamTableViewCell cancelPreviousPerformRequestsWithTarget:self
                                                            selector:@selector(showShareStreamPopover) 
                                                              object:nil];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	UIView *v = [self hitTest:pt withEvent:event];
	if (v == streamTitleLabel) {
        if (touch.tapCount == 1) {
            [self performSelector:@selector(showShareStreamPopover) withObject:nil afterDelay:0.3f];
        } else {
            [self pushMagazineModeVC];
        }            
	}
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	stream.skipNextFrameAddition = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (zoomingFrameIndex != -1)
        return;
    
    int framesPerScreen = clipView.frame.size.width / (FRAME_WIDTH + FRAMES_GAP);
    int maxIndex = [stream.frames count] - framesPerScreen;
    maxIndex = MAX(maxIndex, 0);
    
    CGFloat offset = maxIndex * (FRAME_WIDTH + FRAMES_GAP);
    if (offset < self.scrollView.contentOffset.x) {
        [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }    
}

#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code	
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark UIView

- (void)layoutSubviews {	
	[super layoutSubviews];
	
	float k;
	if ([SettingsController sharedInstance].plusMode) {
		int delta = PLUS_MODE_CELL_HEIGHT - CELL_HEIGHT;
		k = (self.frame.size.height - delta) / CELL_HEIGHT;
	} else 
		k = self.frame.size.height / CELL_HEIGHT;
	
	int w = FRAME_WIDTH * k;
	int h = FRAME_HEIGHT * k;
    
	if (animate) {	
		[UIView beginAnimations:@"LayoutFrames" context:nil];
		[UIView setAnimationDuration:0.5];	
	}
			
	int i = 0;
	for (SmallFrameViewController *c in frameControllers) {
		
		int xPos = i * (w + FRAMES_GAP);
		
		c.view.frame = CGRectMake(xPos, 0, w, h);
		
		int sf = k;
		float rem = k - sf;
		if (rem > 0.5)
			sf++;
		
		i++;		
	}
	
	// plus mode adjustments
	if ([SettingsController sharedInstance].plusMode) {
		// unrotate label
		streamTitleLabel.transform = CGAffineTransformIdentity;
		
		streamTitleLabel.frame = CGRectMake(-6, 10, 121, 29);
		titleBGImage.center = streamTitleLabel.center;
		
		// rotate label background
		titleBGImage.transform = CGAffineTransformMakeRotation(-(M_PI / 2));
		
		
		clipView.frame = CGRectMake(0, 39, self.frame.size.width, h);	
		
		CGRect r = CGRectMake(0, 0, w + FRAMES_GAP, h);	
		
		scrollView.frame = r;
	} else {
		// rotate text 
		streamTitleLabel.transform = CGAffineTransformMakeRotation(-(M_PI / 2));
		streamTitleLabel.frame = CGRectMake(17, (h - 121) / 2, 29, 121);
		titleBGImage.center = streamTitleLabel.center;
		
		titleBGImage.transform = CGAffineTransformIdentity;
		
		clipView.frame = CGRectMake(63, 2, self.frame.size.width - 63, h);
		scrollView.frame = CGRectMake(0, 0, w + FRAMES_GAP, h);	
	}
	
	CGSize s = CGSizeMake(FRAMES_GAP + ([stream.frames count] * (FRAMES_GAP + w)), scrollView.frame.size.height);
	
	scrollView.contentSize = s;	
	
	if (animate) 
		[UIView commitAnimations];
	
	if (zoomingFrameIndex != -1) {
		// adjust content offset
		SmallFrameViewController *c = [frameControllers objectAtIndex:zoomingFrameIndex];
		CGPoint pt = [scrollView convertPoint:c.view.center toView:self];
		int xOffset = pt.x - zoomingFrameOffset;
		if (xOffset != 0) 
			scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + xOffset, 0);	
	}
	
	self.animate = NO;
}


#pragma mark Lifecycle

- (void)releaseFrames {
    
    stream.skipNextFrameAddition = YES;
	
	int count = [stream.frames count];
	if (count > FRAMES_ON_SCREEN) {
        NSArray *framesToRemove = [stream.frames subarrayWithRange:NSMakeRange(FRAMES_ON_SCREEN, count - FRAMES_ON_SCREEN)];
        
        for (Frame *fr in framesToRemove) { 
            [stream removeFrame:fr];
        }
	}
	
	scrollView.contentOffset = CGPointMake(0, 0);
	[self setNeedsLayout];
}

- (void)dealloc {
	stream = nil;
	
	// release all frame controllers from viewed cache
	for (SmallFrameViewController *vc in frameControllers) {
		[[Core sharedInstance] releaseFrameFromViewed:vc];
	}
	
	self.scrollView = nil;
	self.streamTitleLabel = nil;
	self.titleBGImage = nil;	
	
	self.frameControllers = nil;
	self.clipView = nil;
	
	self.sharePopover = nil;
	
    [super dealloc];
}


@end
