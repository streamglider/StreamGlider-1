//
//  Stream.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/15/10.
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

#import "Stream.h"
#import "Feed.h"
#import "Core.h"
#import "SettingsController.h"
#import "Frame.h"

@interface Stream ()

@property (nonatomic, retain) NSMutableSet *delegates;

@end

@implementation Stream {
    int nextFeed;	
}

@synthesize feeds, title, delegates, isPaused, frames, initializing, skipNextFrameAddition, remoteID;

#pragma mark Properties

- (void)setTitle:(NSString*)newTitle {
	if (title != newTitle) {
		title = [newTitle copy];
		for (id<StreamDelegate> delegate in delegates) {
			NSObject *obj = (NSObject*)delegate;
			if ([[obj class] instancesRespondToSelector:@selector(titleWasChanged:)]){
				[delegate titleWasChanged:self];
			}
		}
	}
}

#pragma mark Image Paths

- (NSArray*)getImagePaths {
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	for (Frame *f in frames) {
		[arr addObjectsFromArray:[f getImagePaths]];
	}
	
	// add image paths from feeds as well
	for (Feed *feed in feeds) {
		NSArray *tempQueue = [NSArray arrayWithArray:feed.queue];
		for (Frame *f in tempQueue) {
			[arr addObjectsFromArray:[f getImagePaths]];
		}
	}
	
	NSArray *ret = [NSArray arrayWithArray:arr];
	[arr release];
	return ret;
}

- (NSArray*)getResourcePaths {
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	for (Frame *f in frames) {
		[arr addObjectsFromArray:[f getResourcePaths]];
	}
	
	// add image paths from feeds as well
	for (Feed *feed in feeds) {
		NSArray *tempQueue = [NSArray arrayWithArray:feed.queue];
		for (Frame *f in tempQueue) {
			[arr addObjectsFromArray:[f getResourcePaths]];
		}
	}
	
	NSArray *ret = [NSArray arrayWithArray:arr];
	[arr release];
	return ret;    
}


#pragma mark Delegates

- (void)addStreamDelegate:(id<StreamDelegate>)delegate {
	[delegates addObject:delegate];
}

- (void)removeStreamDelegate:(id<StreamDelegate>)delegate {
	[delegates removeObject:delegate];
}


#pragma mark Frames

- (void)loadNewFrames {
	for (Feed* f in self.feeds) {
		if (!f.loading && [f allFramesWereShown]) {
			// get new frames
			[f loadNewFrames];
		}
	}
}

- (void)removeFrame:(Frame*)frame {
	[frame retain];
	[frames removeObject:frame];
	// notify all delegates
	for (id<StreamDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([[obj class] instancesRespondToSelector:@selector(frameWasRemoved:)]){
			[delegate frameWasRemoved:frame];
		}
	}		
	[frame release];
}

- (void)addNextFrame {
	// get last frame in the queue from the "next" feed
	
	@try {
		if ([feeds count] == 0)
			return;
		
		Feed *feed;
		BOOL feedFound = NO;
		for (int i = 0; i < [feeds count]; i++) {
			feed = [feeds objectAtIndex:nextFeed];
			
			// change "next feed" index
			nextFeed++;
			if (nextFeed >= [feeds count])
				nextFeed = 0;
						
			if ([feed.queue count] == 0)
				continue;
			
			feedFound = YES;		
			break;
		}
		
		if (!feedFound)
			return;
		
		if (![feed hasReadyFrames])
			return;
	
		Frame *frame = [feed.queue objectAtIndex:feed.currentFrameIndex];
		[feed moveToNextFrame];		
		
		if ([SettingsController sharedInstance].removeViewedFrames && 
			[[Core sharedInstance] isFrameDeleted:frame.URLString]) {
			return;
		}
		
		if ([frames containsObject:frame] && ![feed allFramesWereShown])
			return;
		
		[frames insertObject:frame atIndex:0];
		
		// notify all delegates
		for (id<StreamDelegate> delegate in delegates) {
			NSObject *obj = (NSObject*)delegate;
			if ([[obj class] instancesRespondToSelector:@selector(frameWasAdded:)]){
				[delegate frameWasAdded:frame];
			}
		}
		
		if ([frames count] > FRAMES_PER_STREAM) {
			frame = [frames lastObject];
			[frames removeLastObject];
			// notify all delegates
			for (id<StreamDelegate> delegate in delegates) {
				NSObject *obj = (NSObject*)delegate;
				if ([[obj class] instancesRespondToSelector:@selector(frameWasRemoved:)]){
					[delegate frameWasRemoved:frame];
				}
			}		
		}						
	}
	@catch (NSException *e) {
		NSLog(@"exc in add next frame: %@", e);
	}	
}

#pragma mark Feeds

- (BOOL)addFeed:(Feed*)feed {
	
	[feeds insertObject:feed atIndex:0];
	if (!self.initializing) {
		// force read from this feed
		[feed loadNewFrames];
	}
	
	// notify delegates
	for (id<StreamDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([[obj class] instancesRespondToSelector:@selector(feedWasAdded:)]){
			[delegate feedWasAdded:feed];
		}
	}
	
	return YES;
}

- (void)removeFeed:(Feed*)feed {
	[feeds removeObject:feed];
	// notify delegates
	for (id<StreamDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([[obj class] instancesRespondToSelector:@selector(feedWasRemoved:)]){
			[delegate feedWasRemoved:feed];
		}
	}
}

- (void)moveFeed:(Feed*)feed fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	[feeds removeObjectAtIndex:fromIndex];
	[feeds insertObject:feed atIndex:toIndex];
	for (id<StreamDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([obj respondsToSelector:@selector(feedWasMoved:fromIndex:toIndex:)])
			[delegate feedWasMoved:feed fromIndex:fromIndex toIndex:toIndex];
	}
}

- (void)insertFeed:(Feed*)feed atIndex:(NSInteger)atIndex {
		
	[feeds insertObject:feed atIndex:atIndex];
	// force read from this feed
	[feed loadNewFrames];
	
	for (id<StreamDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([obj respondsToSelector:@selector(feedWasInserted:atIndex:)])
			[delegate feedWasInserted:feed atIndex:atIndex];
	}
}

- (void)fireFeedWasChanged:(Feed*)feed {
	for (id<StreamDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([obj respondsToSelector:@selector(feedWasChanged:)])
			[delegate feedWasChanged:feed];
	}
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	self.title = [aDecoder decodeObjectForKey:@"title"];
    self.remoteID = [aDecoder decodeObjectForKey:@"remoteID"];
	NSArray *fs = [aDecoder decodeObjectForKey:@"feeds"];
	
	self.isPaused = NO;
	
	// add all feeds 
	for (int i = [fs count] - 1; i >= 0; i--) {
		Feed *f = [fs objectAtIndex:i];
		f.stream = self;
		[self addFeed:f];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:feeds forKey:@"feeds"];
    [aCoder encodeObject:remoteID forKey:@"remoteID"];
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {	
		self.initializing = YES;
		self.skipNextFrameAddition = NO;
		
		NSMutableArray *f = [[NSMutableArray alloc] init];
		self.feeds = f;
		[f release];
		
		NSMutableSet *s = [[NSMutableSet alloc] init];
		self.delegates = s;
		[s release];	
		
		f = [[NSMutableArray alloc] init];
		self.frames = f;
		[f release];	
		
		nextFeed = 0;
	}
	
	return self;		
}

- (void)dealloc {
	self.delegates = nil;
	self.title = nil;
	self.feeds = nil;
	self.frames = nil;
	self.remoteID = nil;
    
	[super dealloc];
}

@end
