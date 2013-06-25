//
//  StreamSender.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 30/08/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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

#import "StreamSender.h"
#import "APIReader.h"
#import "JSON.h"
#import "Feed.h"
#import "FeedSource.h"
#import "Stream.h"
#import "FeedFactory.h"


@implementation StreamSender {
	BOOL loading;    
}

#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
	
	NSDictionary *result = (NSDictionary*)data;
	NSString *title, *message;
	if ([[result allKeys] containsObject:@"error"]) {
		title = @"Sharing Error";
		message = [result objectForKey:@"error"];
	} else {
		title = @"Sharing Success";
		message = @"Stream was shared successfully!";		
	}

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message 
												   delegate:nil 
										  cancelButtonTitle:@"Close" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	loading = NO;
}

- (void)apiLoadFailed:(APIReader*)reader {
	loading = NO;
}

#pragma mark Loading

- (NSString*)convertStreamToJson:(Stream*)stream email:(NSString*)email password:(NSString*)pwd {
	
	NSMutableDictionary *s = [[NSMutableDictionary alloc] init];
	NSDictionary *dict;
    
    if (pwd != nil) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email", s, @"stream", pwd, @"password", nil];
    } else {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email", s, @"stream", nil];
    }
	
	[s setObject:stream.title forKey:@"title"];
	
	NSMutableArray *feeds = [[NSMutableArray alloc] init];
		
	for (Feed *feed in stream.feeds) {
		NSDictionary *fd = [NSDictionary dictionaryWithObjectsAndKeys:feed.source.title, @"title", 
							feed.source.URLString, @"url",
							[FeedFactory stringNameForType:feed.source.type], @"feed_type",
							nil];
		
		[feeds addObject:fd];
	}
	
	[s setObject:feeds forKey:@"stream_feeds"];	
	
	[feeds release];
	[s release];
	
	return [dict JSONRepresentation];
}

- (void)sendDefaultStream:(Stream*)stream email:(NSString*)email password:(NSString*)password {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
	APIReader *reader = [[APIReader alloc] init];
	reader.delegate = self;
	
	// prepare stream json data
	reader.postData = [self convertStreamToJson:stream email:email password:password];
	
	DebugLog(@"%@", reader.postData);
	
	[reader loadAPIDataFor:@"default_streams/upload.json" withMethod:@"POST" addAuthToken:NO handleAuthError:NO];
	
	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[reader release];
	
	[pool drain];    
}

- (void)sendStream:(Stream*)stream email:(NSString*)email {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
	APIReader *reader = [[APIReader alloc] init];
	reader.delegate = self;
	
	// prepare stream json data
	reader.postData = [self convertStreamToJson:stream email:email password:nil];
	
	DebugLog(@"%@", reader.postData);
	
	[reader loadAPIDataFor:@"streams/share_stream.json" withMethod:@"POST" addAuthToken:YES handleAuthError:YES];
	
	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[reader release];
	
	[pool drain];
}

@end
