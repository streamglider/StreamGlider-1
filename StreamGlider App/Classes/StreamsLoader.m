//
//  StreamsLoader.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 25/08/2011.
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

#import "StreamsLoader.h"
#import "APIReader.h"
#import "Stream.h"
#import "Feed.h"
#import "FeedSource.h"
#import "FeedFactory.h"
#import "Core.h"

@implementation StreamsLoader {
	BOOL loading;    
}

@synthesize delegate;

#pragma mark Utility Methods

- (Stream*)parseStream:(NSDictionary*)s {
	Stream *stream = [[Stream alloc] init];
	stream.title = [s objectForKey:@"title"];
	stream.remoteID = [[s objectForKey:@"id"] description];
	
	for (NSDictionary *f in [s objectForKey:@"stream_feeds"]) {
		FeedSource *fs = [[FeedSource alloc] init];
		NSString *type = [f objectForKey:@"feed_type"];
		fs.type = [FeedFactory typeForStringName:type];
		Feed *feed = [FeedFactory createFeedForSource:fs];
		fs.title = [f objectForKey:@"title"];
		fs.URLString = [f objectForKey:@"url"];
		
		feed.source = fs;
		
		[fs release];
		
		feed.stream = stream;
        [stream insertFeed:feed atIndex:[stream.feeds count]];
	}
    
    return [stream autorelease];
}

#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
    if ([reader.pathAndQuery isEqualToString:@"default_streams"]) {        
        NSArray *sa = (NSArray*)data;
        NSMutableArray *streams = [[NSMutableArray alloc] initWithCapacity:[sa count]];
        
        for (NSDictionary *s in sa) {
            Stream *stream = [self parseStream:s];
            [streams insertObject:stream atIndex:0];
        }
        
        if (delegate != nil) 
            [delegate defaultStreamsLoaded:streams];
        
        [streams autorelease];
        
    } else {
        NSDictionary *s = (NSDictionary*)data;
        
        Stream *stream = [self parseStream:s];
        
        [[Core sharedInstance] addStream:stream skipStoring:NO];
        
        stream.initializing = NO;
        
        [stream loadNewFrames];
    	
        if (delegate != nil)
            [delegate streamWasLoaded:stream.remoteID];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Shared Streams" 
                                                        message:@"Shared stream was loaded successfully!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Close" 
                                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        [alert release];        
    }    	
	
	[reader release];		
	loading = NO;
}

- (void)apiLoadFailed:(APIReader*)reader {
    
    if ([reader.pathAndQuery isEqualToString:@"default_streams"]) {
        if (delegate != nil)
            [delegate defaultStreamsLoadFailed];        
    } else {    
        if (delegate != nil)
            [delegate streamLoadFailed];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Shared Streams" 
                                                        message:@"Shared stream was not loaded!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Close" 
                                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        [alert release];
    }
	
	[reader release];	
	loading = NO;
}

#pragma mark Loading

- (void)loadDefaultStreams {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
	APIReader *reader = [[APIReader alloc] init];
	reader.delegate = self;
	[reader loadAPIDataFor:@"default_streams" withMethod:@"GET" addAuthToken:NO handleAuthError:NO];
	
	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];    
}

- (void)loadStreamWithID:(NSString*)streamID {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
	APIReader *reader = [[APIReader alloc] init];
	reader.delegate = self;
	[reader loadAPIDataFor:[NSString stringWithFormat:@"streams/%@.json", streamID] withMethod:@"GET" addAuthToken:YES handleAuthError:YES];
	
	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];
}

@end
