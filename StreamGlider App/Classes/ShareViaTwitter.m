//
//  ShareViaTwitter.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 12/11/2010.
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

#import "ShareViaTwitter.h"
#import "TwitterFrame.h"
#import "MessageViewController.h"
#import "NSString+OAuth.h"
#import "JSON.h"
#import "OAuthProtocol.h"
#import "OAuthCore.h"
#import "Core.h"

@interface ShareViaTwitter () 

@property (nonatomic, retain) MessageViewController *messageViewController;

@end


@implementation ShareViaTwitter

@synthesize message, frame, streamCastViewController, messageViewController;

#define BITLY_URL @"http://api.bit.ly/v3/shorten?login=streamcasttest&apiKey=R_9cf4839a3149b55a9ac2d743de51d2e6&"

#pragma mark Callbacks

- (void)messageCallback:(NSString*)text {
	if (text != nil)
		self.message = text;
	
	// tweet 
	NSString *urlString = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/update.json?status=%@",
						   [NSString URLEncodeString:message]];
	NSURL *url = [NSURL URLWithString:urlString];
	
    [Core clearCookies:url];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	id<OAuthProtocol> oauth = [[OAuthCore sharedInstance] getOAuthForRealm:TWITTER_REALM];
	[oauth signRequest:request];	
	
	NSURLResponse *response;
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request 
										 returningResponse:&response error:NULL];	
	
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSDictionary *dict = [s JSONValue];	
	[s release];
	
	NSString *errorString = [dict objectForKey:@"error"];
	if (errorString != nil && [errorString rangeOfString:@"OAuth"].location != NSNotFound) {		
		[[OAuthCore sharedInstance] requestAuthForRealm:TWITTER_REALM withDelegate:self viewController:nil askUser:YES reason:@"Sharing via Twitter requires authentication."];		
	} else if (errorString != nil) {
		NSString *m = [NSString stringWithFormat:@"The message was not sent, error: %@", errorString];
		[self displayALert:@"Status Update Failed" message:m];	
	} else {
		[self displayALert:@"Status Update" message:@"The message was sent successfully!"];			
	}
}

#pragma mark Sharing

- (void)displayALert:(NSString*)t message:(NSString*)m {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:t message:m 
												   delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (NSString*)shortenUrl:(NSString*)urlString {
	// check if this url has already been shortened
	if ([urlString length] <= 20 || [urlString rangeOfString:@"bit.ly"].location != NSNotFound)
		return urlString;
	
	NSString *bitlyUrl = [NSString stringWithFormat:@"%@longUrl=%@", 
						  BITLY_URL,
						  urlString];
						  //[NSString URLEncodeString:urlString]];
	
	NSURL *url = [NSURL URLWithString:bitlyUrl];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	NSURLResponse *response;
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request 
												 returningResponse:&response error:NULL];
	
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSDictionary *dict = [jsonString JSONValue];
	
	[jsonString release];
	
	NSNumber *status = [dict objectForKey:@"status_code"];
	
	NSString *ret = urlString;
	
	if ([status intValue] == 200) {
		NSDictionary *dataDict = [dict objectForKey:@"data"];
		ret = [dataDict objectForKey:@"url"];
		DebugLog(@"shortened URL: %@", ret);
	} else {
		NSString *statusTxt = [dict objectForKey:@"status_txt"];
		NSString *m = [NSString stringWithFormat:@"Failed to shorten URL, error: %@", statusTxt];
		[self displayALert:@"URL Shortening" message:m];
	}
	
	return ret;
}

- (void)retweetFrameWithStatusID:(NSString*)statusID {
	NSString *urlString = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/retweet/%@.json", statusID];
	NSURL *url = [NSURL URLWithString:urlString];
	
    [Core clearCookies:url];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	id<OAuthProtocol> oauth = [[OAuthCore sharedInstance] getOAuthForRealm:TWITTER_REALM];
	[oauth signRequest:request];	
	
	NSURLResponse *response;
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request 
						  returningResponse:&response error:NULL];	
	
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSDictionary *dict = [s JSONValue];	
	[s release];
	
	NSString *errorString = [dict objectForKey:@"error"];
	if (errorString != nil && [errorString rangeOfString:@"OAuth"].location != NSNotFound) {		
		[[OAuthCore sharedInstance] requestAuthForRealm:TWITTER_REALM withDelegate:self viewController:nil askUser:YES reason:@"Retweeting requires Twitter authentication."];		
	} else if (errorString != nil) {
		NSString *m = [NSString stringWithFormat:@"The message was not retweeted, error: %@", errorString];
		[self displayALert:@"Retweet Failed" message:m];	
	} else {
		[self displayALert:@"Retweeted Successfully " message:@"Retweeted this message successfully."];			
	}
}

#pragma mark OAuthDelegate

- (void)exchangeWasFinished:(id <OAuthProtocol>)oauth {
	if ([oauth authenticated]) {
		if ([frame isMemberOfClass:[TwitterFrame class]]) {
			TwitterFrame *tFrame = (TwitterFrame*)frame;
			[self retweetFrameWithStatusID:tFrame.statusId];
		} else {
			[self messageCallback:nil];
		}
	} else {
        NSString *msg = [NSString stringWithFormat:@"You need to authenticate %@ with Twitter in order to share.", APP_NAME];
		[self displayALert:@"Share Frame Content" 
				   message:msg];					
	}
}

#pragma mark ShareController

- (void)shareFrame:(Frame*)f retweet:(BOOL)retweet {	
	frame = f;
	NSString *text;
	if ([frame isMemberOfClass:[TwitterFrame class]] && retweet) {
		// construct RT message
		TwitterFrame *tFrame = (TwitterFrame*)f;
		[self retweetFrameWithStatusID:tFrame.statusId];
	} else {
		// construct message with shortened URL		
		NSString *shortenedUrl = [self shortenUrl:frame.URLString];
		
		int rem = 140 - [shortenedUrl length] - 1;
		NSString *t = [f description];
		if ([t length] > rem) {
			// shorten the string
			t = [t substringToIndex:(rem - 3)];
			t = [NSString stringWithFormat:@"%@...", t];
		}
		
		
		text = [NSString stringWithFormat:@"%@ %@", t, shortenedUrl];
		
        self.messageViewController = nil;
		messageViewController = [[MessageViewController alloc] 
									  initWithNibName:@"MessageViewController" 
									  bundle:nil];
		
		messageViewController.target = self;
		messageViewController.callback = @selector(messageCallback:);	
		
		messageViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		
		messageViewController.maxCharCount = 140;
		[streamCastViewController presentModalViewController:messageViewController animated:YES];		
		messageViewController.textView.text = text;
		
		[messageViewController updateStatusForText:text];		
	}
}

#pragma mark Lifecycle

- (void)dealloc {
	self.message = nil;
	self.messageViewController = nil;
	[super dealloc];
}

@end
