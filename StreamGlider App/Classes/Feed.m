//
//  Feed.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/16/10.
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

#import "Feed.h"
#import "Stream.h"
#import "Frame.h"
#import "FeedSource.h"

@interface Feed () 

@property (nonatomic, retain) NSMutableSet *delegates;

@end

@implementation Feed 

@synthesize title, stream, queue, loading, 
	editing, delegates, source, currentFrameIndex, stopComplimenting, tempQueue;

#pragma mark Frames

- (void)markAllShown {
	NSArray *queueCopy = [NSArray arrayWithArray:queue];
	for (Frame *f in queueCopy) {
		f.frameWasShown = YES;
	}
}

- (BOOL)hasReadyFrames {
	NSArray *queueCopy = [NSArray arrayWithArray:queue];
	BOOL ret = NO;	
	for (Frame *f in queueCopy) {
		if (f.frameIsReady) {
			ret = YES;
			break;
		}
	}
	
	return ret;
}

- (BOOL)allFramesWereShown {
	NSArray *queueCopy = [NSArray arrayWithArray:queue];
	BOOL ret = YES;
	for (Frame *f in queueCopy) {
		if (!f.frameWasShown) {
			ret = NO;
			break;
		}
	}
	
	return ret;
}

- (void)moveToNextFrame {
    for (int i = 0; i < [queue count]; i++) {
        self.currentFrameIndex++;			
        if (currentFrameIndex >= [queue count]) {
            self.currentFrameIndex = 0;
        }		
        Frame *f = [queue objectAtIndex:currentFrameIndex];
        if (f.frameIsReady) {
            f.frameWasShown = YES;
            break;
        }
    }
			
	DebugLog(@"feed %@, index: %d", source.title, currentFrameIndex);
}

#pragma mark Properties

- (void)setSource:(FeedSource*)newSource {
	if (! [source isEqual:newSource]) {
		self.stopComplimenting = YES;		
		self.currentFrameIndex = 0;
		
		source = newSource;
		[source retain];
		
		[stream fireFeedWasChanged:self];
		
		// notify delegates
		for (id<FeedDelegate> delegate in delegates) {
			NSObject *obj = (NSObject*)delegate;
			if ([obj respondsToSelector:@selector(sourceWasChanged:)]) {
				[delegate sourceWasChanged:source];
			}
		}
		
        // clear the queue
        self.queue = [[[NSArray alloc] init] autorelease];        
	}
}

- (void)setTitle:(NSString*)newTitle {
	title = [newTitle copy];
	for (id<FeedDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([[obj class] instancesRespondToSelector:@selector(titleWasChanged:)]) {
			[delegate feedTitleWasChanged:title];
		}
	}
}

- (void)setEditing:(BOOL)newValue {
	if (editing != newValue) {
		editing = newValue;
		if (!editing) {
			// force load new frames 
			[self loadNewFrames];
		} 
	}
}

#pragma mark Delegates

- (void)addFeedDelegate:(id<FeedDelegate>)delegate {
	[delegates addObject:delegate];
}

- (void)removeFeedDelegate:(id<FeedDelegate>)delegate {
	[delegates removeObject:delegate];
}

#pragma mark Loading

- (void)loadNewFrames {
	if (editing || loading)
		return;
	
	self.tempQueue = [[[NSMutableArray alloc] init] autorelease];
	
	self.loading = YES;
	self.stopComplimenting = YES;
    
	[self performSelectorInBackground:@selector(performLoadInBackground) withObject:nil];
}

- (void)performLoadInBackground {
	
}

- (void)loadWasFinished {
	self.loading = NO;
	self.tempQueue = nil;
	for (id<FeedDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([[obj class] instancesRespondToSelector:@selector(loadWasFinished)]) {
			[obj performSelectorOnMainThread:@selector(loadWasFinished) withObject:nil waitUntilDone:NO];
		}
	}
	
	self.stopComplimenting = NO;
	[self performSelectorInBackground:@selector(makeFramesReady) withObject:nil];
}

#pragma mark Complimenting Frames

- (void)makeFrameReady:(Frame*)frame {
}

- (void)makeFramesReady {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *queueCopy = [NSArray arrayWithArray:queue];
	
	[stream retain];
	for (Frame *f in queueCopy) {			
		if (stopComplimenting)
			break;
		
		if (!f.frameIsReady) {
			[self makeFrameReady:f];
			f.frameIsReady = YES;
		}
	}
	[stream release];
	
	[pool drain];    
}

#pragma mark Parsing

- (NSString*)dateFormat {
	return nil;
}

- (NSDate*)parseDate:(NSString*)date {
	NSDateFormatter *f = [[NSDateFormatter alloc] init];
	[f setDateFormat:[self dateFormat]];
	NSDate *ret = [f dateFromString:date];
	[f release];
	return ret;
}


#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	self.title = [aDecoder decodeObjectForKey:@"title"];	
	self.source = [aDecoder decodeObjectForKey:@"source"];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:source forKey:@"source"];
}


#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {	
	// should be overriden in children
	return nil;	
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		NSMutableArray *d = [[NSMutableArray alloc] init];
		self.queue = d;
		[d release];
		
		NSMutableSet *s = [[NSMutableSet alloc] init];
		self.delegates = s;
		[s release];			
	}
	return self;
}

- (void)dealloc {
	self.delegates = nil;
	self.title = nil;
	self.queue = nil;	
	self.source = nil;
	self.tempQueue = nil;
	
	[super dealloc];
}

@end
