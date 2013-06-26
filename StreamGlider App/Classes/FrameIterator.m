//
//  FrameIterator.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 08/11/2011.
//  Copyright (c) 2011 StreamGlider, Inc. All rights reserved.
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

#import "FrameIterator.h"
#import "Stream.h"
#import "Feed.h"
#import "Frame.h"

@interface FrameIterator ()

@property (nonatomic, retain) NSMutableArray *feedPositions;
@property (nonatomic, retain) NSMutableArray *shownFrames;

@end

@implementation FrameIterator {
    int feedIndex;    
    int startedWithFeed;
}

@synthesize stream, feedPositions, shownFrames;

- (void)setStream:(Stream *)aStream {
    stream = aStream;
    // initialize positions 
    
    feedIndex = 0;
    
    self.feedPositions = [[[NSMutableArray alloc] initWithCapacity:[stream.feeds count]] autorelease];
    for (int i = 0; i < [stream.feeds count]; i++) {
        [feedPositions addObject:[NSNumber numberWithInt:0]];
    }    
}

- (NSArray*)framesList:(Frame*)frame {
    
    Feed *feed = frame.feed;
    int fi = [stream.feeds indexOfObject:feed];
    int index = ((NSNumber*)[feedPositions objectAtIndex:fi]).intValue;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:frame];
    
    int i = index;
    while (YES) {
        Frame *f = [feed.queue objectAtIndex:i];
        if (f.frameIsReady && ![shownFrames containsObject:f]) {
            [shownFrames addObject:f];
            [arr insertObject:f atIndex:0];
        }
        
        i++;
        if (i >= [feed.queue count]) {
            i = 0;
        }
        
        if ([arr count] >= (FEEDS_PER_PAGE / 2) || i == index)
            break;        
    }   
    
    [feedPositions replaceObjectAtIndex:fi withObject:[NSNumber numberWithInt:i]];    
    
    return [arr autorelease];
}

- (Frame*)nextFrame {
    
    if ([stream.feeds count] == 0)
        return nil;
    
    if (startedWithFeed == -1)
        startedWithFeed = feedIndex;
    else if (feedIndex == startedWithFeed) {
        return nil;
    }
    
    int frameIndex = ((NSNumber*)[feedPositions objectAtIndex:feedIndex]).intValue;
    Feed *feed = [stream.feeds objectAtIndex:feedIndex];
    
    int index = frameIndex;
    
    while (YES) {
        
        if ([feed.queue count] == 0) {            
            // no ready frames in this feed, adjust current feed
            feedIndex++;
            if (feedIndex >= [stream.feeds count])
                feedIndex = 0;            
            return [self nextFrame];            
        }
        
        Frame *frame = [feed.queue objectAtIndex:index];
        if (frame.frameIsReady && ![shownFrames containsObject:frame]) {
            // adjust frame position inside the feed
            
            index++;
            if (index >= [feed.queue count])
                index = 0;
            
            [feedPositions replaceObjectAtIndex:feedIndex withObject:[NSNumber numberWithInt:index]];
            
            // adjust current feed
            feedIndex++;
            if (feedIndex >= [stream.feeds count])
                feedIndex = 0;
            
            startedWithFeed = -1;
            
            [shownFrames addObject:frame];
            
            return frame;
        }
        
        index++;
        
        if (index >= [feed.queue count])
            index = 0;
                
        if (index == frameIndex) {
            // no ready frames in this feed, adjust current feed
            feedIndex++;
            if (feedIndex >= [stream.feeds count])
                feedIndex = 0;            
            return [self nextFrame];
        }        
    }
    
    return nil;
}

- (id)init {
    if (self = [super init]) {
        startedWithFeed = -1;
        self.shownFrames = [[[NSMutableArray alloc] init] autorelease];
    }
    
    return self;
}

- (void)dealloc {
    self.feedPositions = nil;
    self.shownFrames = nil;
    
    [super dealloc];
}

@end
