//
//  IncomingStreamsController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 08/02/2012.
//  Copyright (c) 2012 StreamGlider, Inc. All rights reserved.
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

#import "IncomingStreamsController.h"
#import "ButtonWithBadge.h"
#import "APIReader.h"
#import "StreamCastStateController.h"
#import "Core.h"

@interface IncomingStreamsController ()

@property (nonatomic, retain) NSMutableArray *badgeButtons;
@property (nonatomic, retain) NSMutableArray *viewedStreams;
@property (nonatomic, retain) APIReader *reader;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation IncomingStreamsController

@synthesize badgeButtons, addedStreams, viewedStreams, reader, timer;

#pragma mark Singleton

static IncomingStreamsController *sharedInstance = nil; 

+ (IncomingStreamsController*)sharedInstance {
	if (sharedInstance == nil) {
		sharedInstance = [[IncomingStreamsController alloc] init];
	}
	
	return sharedInstance;		
}

#pragma mark Utility Methods

- (void)storeViewedStreams {
    [[NSUserDefaults standardUserDefaults] setObject:viewedStreams forKey:@"viewedStreams"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readViewedStreams {
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"viewedStreams"];
    if (arr != nil)
        [self.viewedStreams addObjectsFromArray:arr]; 
}

- (void)updateBadges {
    for (ButtonWithBadge *b in badgeButtons) {
        b.badgeNumber = [addedStreams count];
    }    
}

#pragma mark Badge Buttons

- (void)addBadgeButton:(ButtonWithBadge*)bb {
    [badgeButtons addObject:bb];
    bb.badgeNumber = [addedStreams count];
}

- (void)removeBadgeButton:(ButtonWithBadge*)bb {
    [badgeButtons removeObject:bb];
}


#pragma mark Incoming Streams

- (void)pauseUpdating {
    [timer invalidate];
    self.timer = nil;
}

- (void)resumeUpdating {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self 
                                                selector:@selector(handleTimerFired) userInfo:nil repeats:YES];    
}

- (void)markAllViewed {
    [viewedStreams addObjectsFromArray:addedStreams];
    [self storeViewedStreams];
    
    [addedStreams removeAllObjects];
    [self performSelectorOnMainThread:@selector(updateBadges) withObject:nil waitUntilDone:NO];
}

- (void)updateIncomingDB {
    if ([Core sharedInstance].userEmail) {
        [reader loadAPIDataFor:@"share_tos.json" withMethod:@"GET" addAuthToken:YES handleAuthError:NO];        
    }
}

#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
    if ([data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
	NSArray *arr = (NSArray*)data;
    for (NSDictionary *d in arr) {
        NSNumber *sid = [d objectForKey:@"stream_id"];
        if (![viewedStreams containsObject:sid] && ![addedStreams containsObject:sid]) {
            [addedStreams addObject:sid];
        }
    }
    
    [self performSelectorOnMainThread:@selector(updateBadges) withObject:nil waitUntilDone:NO];
}

- (void)apiLoadFailed:(APIReader*)reader {
    NSLog(@"incoming streams update failed - server error");
}


#pragma mark Handlers

- (void)handleTimerFired {
    [self performSelectorInBackground:@selector(updateIncomingDB) withObject:nil];
}

#pragma mark Lifecycle

- (id)init {
    if (self = [super init]) {
        self.badgeButtons = [[[NSMutableArray alloc] init] autorelease];
        self.addedStreams = [[[NSMutableArray alloc] init] autorelease];
        self.viewedStreams = [[[NSMutableArray alloc] init] autorelease];
        
        [self readViewedStreams];
        
        self.reader = [[[APIReader alloc] init] autorelease];
        reader.delegate = self;
        reader.viewController = (UIViewController*)[StreamCastStateController sharedInstance].streamCastViewController;
        
        // register a timer
        [self resumeUpdating];
        
        [self handleTimerFired];
    }
    return self;
}

- (void)dealloc {
    self.badgeButtons = nil;
    self.addedStreams = nil;
    self.viewedStreams = nil;
    self.reader = nil;
    self.timer = nil;
    
    [super dealloc];
}

@end
