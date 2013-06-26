//
//  Core.m
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

#import "Core.h"
#import "Frame.h"
#import "Stream.h"
#import "FeedSource.h"
#import "BrowserViewController.h"
#import "Loader.h"
#import "SmallFrameViewController.h"
#import "DogEarView.h"
#import "FeedSourceCategory.h"
#import "Feed.h"
#import "SettingsController.h"
#import "OAuthCore.h"
#import "FeaturedFeedSource.h"
#import "PageOfStreams.h"


@interface Core () 

@property (nonatomic, retain) NSMutableSet *delegates;
@property (nonatomic, retain) NSTimer *loadTimer;
@property (nonatomic, retain) NSTimer *addTimer;

@end

@implementation Core {
	NSTimer *resumeStreamTimer;
    
	NSMutableDictionary *viewedCache;
	NSMutableSet *oldFramesCache;
	NSMutableSet *deletedFramesCache;	    
}

@synthesize streams, delegates, isPaused, addTimer, loadTimer, browserViewController, 
	rootCategory, cardImage, featuredFeeds, apiToken, userEmail, pages;

#pragma mark Utility Methods

+ (void)clearCookies:(NSURL*)url {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookiesForURL:url]) {
        [storage deleteCookie:cookie];
    }
}

#pragma mark Singleton

static Core* instance = nil;

+ (Core*)sharedInstance {
	if (instance == nil) {
		instance = [[Core alloc] init];
	}
	return instance;
}

#pragma mark Properties

- (void)setApiToken:(NSString*)token {
	if (token != nil) {
		[OAuthCore storeKeychainValue:token forKey:@"api-token"];
	} else 
		[OAuthCore deleteKeychainValueForKey:@"api-token"];
}

- (NSString*)getApiToken {
    return [OAuthCore getValueFromKeyChainFor:@"api-token"];
}

- (void)setUserEmail:(NSString *)email {
	if (email != nil) {
		[OAuthCore storeKeychainValue:email forKey:@"user-email"];
	} else 
		[OAuthCore deleteKeychainValueForKey:@"user-email"];
}

- (NSString*)getUserEmail {
    return [OAuthCore getValueFromKeyChainFor:@"user-email"];
}


#pragma mark Viewed Frames

- (BOOL)frameWasViewed:(SmallFrameViewController*)viewController {
	NSString *frameURL = viewController.frame.URLString;
	NSMutableSet *controllers = [viewedCache objectForKey:frameURL];
	BOOL ret = YES;
	if (controllers == nil) {
		ret = NO;
		controllers = [[NSMutableSet alloc] init];
		[viewedCache setObject:controllers forKey:frameURL];
		[controllers release];
	}
	
	// check if this URL was viewed
	if (ret) {
		SmallFrameViewController *vc = [controllers anyObject];
		ret = vc.dogEarView.viewed;
	}
	
	[controllers addObject:viewController];		
	return ret;
}

- (void)releaseFrameFromViewed:(SmallFrameViewController*)viewController {
	NSMutableSet *controllers = [viewedCache objectForKey:viewController.frame.URLString];
	[controllers removeObject:viewController];	
}

- (void)viewFrame:(NSString*)frameURL {
	NSMutableSet *controllers = [viewedCache objectForKey:frameURL];
	// mark all controllers as viewed
	for (SmallFrameViewController *vc in controllers) {
		vc.dogEarView.viewed = YES;
	}
}

- (BOOL)isFrameNew:(NSString*)frameURL {
	BOOL ret = ![oldFramesCache containsObject:frameURL];
	
	if (ret)
		[oldFramesCache addObject:frameURL];
	
	return ret;	
}

- (void)removeAllFramesWithURL:(NSString*)frameURL {
	NSMutableSet *controllers = [viewedCache objectForKey:frameURL];
	
	NSSet *copy = [NSSet setWithSet:controllers];
	// mark all controllers as viewed
	for (SmallFrameViewController *vc in copy) {
		[vc.frame.feed.stream removeFrame:vc.frame];
	}	
	
	[deletedFramesCache addObject:frameURL];
}

- (BOOL)isFrameDeleted:(NSString*)frameURL {
	return [deletedFramesCache containsObject:frameURL];
}

#pragma mark Image Paths

- (NSArray*)getResourcePaths {
	NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (PageOfStreams *p in pages) {
        for (Stream *s in p.streams) {
            [arr addObjectsFromArray:[s getResourcePaths]];
        }
    } 
    
	NSArray *ret = [NSArray arrayWithArray:arr];
	[arr release];
	return ret;    
}

- (NSArray*)getImagePaths {
	NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (PageOfStreams *p in pages) {
        for (Stream *s in p.streams) {
            [arr addObjectsFromArray:[s getImagePaths]];
        }
    }
    
    for (FeaturedFeedSource *ffs in featuredFeeds) {
        [arr addObject:ffs.imageURL];
    }
    
    for (FeedSourceCategory *fsc in rootCategory.children) {
        for (FeedSourceCategory *cat in fsc.children) {
            if (cat.imageURL != nil)
                [arr addObject:cat.imageURL];
        }
    }
    
	NSArray *ret = [NSArray arrayWithArray:arr];
	[arr release];
	return ret;
}

#pragma mark Play Pause

- (void)pauseAllStreamsExcept:(Stream*)stream {
	for (Stream *s in streams) {
		if (s == stream) {
			s.isPaused = NO;
		}
		if (s != stream) {
			s.isPaused = YES;
		}
	}
}

- (void)resumeAllStreams {
	isPaused = NO;
	for (Stream *s in streams) {
		s.isPaused = NO;
	}
}

- (void)pauseAllStreams {
	isPaused = YES;
	for (Stream *s in streams) {
		s.isPaused = YES;
	}
}

- (void)togglePause {
	isPaused = !isPaused;
	for (Stream *stream in streams) {
		stream.isPaused = isPaused;
	}
}

#pragma mark Pages

- (void)addPage:(PageOfStreams*)page makeActive:(BOOL)makeActive {
    
    if (makeActive) {
        for (PageOfStreams *p in pages) {
            p.activePage = NO;
        }
        
        page.activePage = YES;
        self.streams = page.streams;
    }
    
    // add page
    [pages addObject:page];
    
	NSSet *tempDel = [NSSet setWithSet:delegates];
	
	for (id<CoreDelegate> delegate in tempDel) {
		NSObject *obj = (NSObject*)delegate;
		if ([obj respondsToSelector:@selector(pageWasAdded:)])
            [delegate pageWasAdded:page];
        
		if (makeActive && [obj respondsToSelector:@selector(activePageWasChangedToPage:)])
            [delegate activePageWasChangedToPage:page];
	}
    
    [[Loader sharedInstance] storeStreams];
}

- (void)removePage:(PageOfStreams*)page {
    
    page.delegates = nil;
    
    if (page.activePage) {
        // reassing the active page
        int index = [pages indexOfObject:page];
        if (index != 0) {
            index--;
        }
        
        [pages removeObject:page];
        
        PageOfStreams *p = [pages objectAtIndex:index];
        p.activePage = YES;
        self.streams = p.streams;
        
        NSSet *tempDel = [NSSet setWithSet:delegates];
        
        for (id<CoreDelegate> delegate in tempDel) {
            NSObject *obj = (NSObject*)delegate;
            if ([obj respondsToSelector:@selector(activePageWasChangedToPage:)])
                [delegate activePageWasChangedToPage:p];
        }
        
    } else {
        [pages removeObject:page];        
    }
    
    NSSet *tempDel = [NSSet setWithSet:delegates];
    
    for (id<CoreDelegate> delegate in tempDel) {
        NSObject *obj = (NSObject*)delegate;
        if ([obj respondsToSelector:@selector(pageWasRemoved:)])
            [delegate pageWasRemoved:page];
    } 
    
    [[Loader sharedInstance] storeStreams];    
}

- (void)setActivePage:(PageOfStreams*)page {
    for (PageOfStreams *p in pages) {
        p.activePage = p == page;
    }
    
    self.streams = page.streams;
    
    NSSet *tempDel = [NSSet setWithSet:delegates];
    
    for (id<CoreDelegate> delegate in tempDel) {
        NSObject *obj = (NSObject*)delegate;
        if ([obj respondsToSelector:@selector(activePageWasChangedToPage:)])
            [delegate activePageWasChangedToPage:page];
    }  
    
    [[Loader sharedInstance] storeStreams];    
    [self killTimers];
    [self installTimers];
}

- (PageOfStreams*)getActivePage {
    for (PageOfStreams *p in pages) {
        if (p.activePage)
            return p;
    }    
    return nil;
}

#pragma mark Streams

- (void)addStream:(Stream*)stream skipStoring:(BOOL)skipStoring {

	[streams insertObject:stream atIndex:0];	
	
	NSSet *tempDel = [NSSet setWithSet:delegates];
	
	for (id<CoreDelegate> delegate in tempDel) {
		NSObject *obj = (NSObject*)delegate;
		if ([obj respondsToSelector:@selector(streamWasAdded:)])
			 [delegate streamWasAdded:stream];
	}
	
	[stream addStreamDelegate:self];
	
	if (!skipStoring)
		[[Loader sharedInstance] storeStreams];
}

- (void)removeStream:(Stream *)stream {
	[stream removeStreamDelegate:self];
	NSUInteger index = [streams indexOfObject:stream];
	
	[stream retain];
	
	// stop complimenting stream feeds
	for (Feed *f in stream.feeds) {
		f.stopComplimenting = YES;
	}
	
	if (index != NSNotFound) {		
		NSSet *tempDel = [NSSet setWithSet:delegates];		
		[streams removeObjectAtIndex:index];
		for (id<CoreDelegate> delegate in tempDel) {
			NSObject *obj = (NSObject*)delegate;
			if ([obj respondsToSelector:@selector(streamWasRemoved:index:)])
				[delegate streamWasRemoved:stream index:index];
		}		
	}
	
	[stream release];
	
	[[Loader sharedInstance] storeStreams];
}

- (void)moveStream:(Stream*)stream fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	[stream retain];
	[streams removeObjectAtIndex:fromIndex];
	[streams insertObject:stream atIndex:toIndex];
	[stream release];
	
	for (id<CoreDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([obj respondsToSelector:@selector(streamWasMoved:fromIndex:toIndex:)])
			[delegate streamWasMoved:stream fromIndex:fromIndex toIndex:toIndex];
	}
	[[Loader sharedInstance] storeStreams];
}

#pragma mark Sources

- (void)addSource:(FeedSource*)source {
	
	// find category to which this sources has to be added
    for (FeedSourceCategory *fsc in rootCategory.children) {
        if ([fsc.title isEqualToString:@"My Feeds"]) {
            FeedSourceCategory *cat = [fsc.children objectAtIndex:0];	
            cat = [cat.children objectAtIndex:0];
            source.category = cat;
            [cat addChild:source];
            for (id<CoreDelegate> delegate in delegates) {
                NSObject *obj = (NSObject*)delegate;
                if ([obj respondsToSelector:@selector(sourceWasAdded:)])
                    [delegate sourceWasAdded:source];
            }
            
            [[Loader sharedInstance] storeSources];
            
            break;
        }
    }	
}

- (void)removeSource:(FeedSource*)source {
	FeedSourceCategory *cat = source.category;
	[cat removeChild:source];
	
	for (id<CoreDelegate> delegate in delegates) {
		NSObject *obj = (NSObject*)delegate;
		if ([obj respondsToSelector:@selector(sourceWasRemoved:)])
			[delegate sourceWasRemoved:source];
	}
	[[Loader sharedInstance] storeSources];
}

#pragma mark Delegates

- (void)addCoreDelegate:(id<CoreDelegate>)delegate {
	[delegates addObject:delegate];
}

- (void)removeCoreDelegate:(id<CoreDelegate>)delegate {
	[delegates removeObject:delegate];
}

#pragma mark Timers

- (void)handleLoadTimerFired:(NSTimer*)timer {
    DebugLog(@"loading new data, timer is fired");
	NSArray *tempStreams = [NSArray arrayWithArray:streams];
	for (Stream* stream in tempStreams) {
		if (!stream.isPaused)
			[stream loadNewFrames];
	}
}

- (void)handleAddTimerFired:(NSTimer*)timer {
	NSArray *tempStreams = [NSArray arrayWithArray:streams];
	for (Stream *stream in tempStreams) {
		if (stream.skipNextFrameAddition) {
			stream.skipNextFrameAddition = NO;
			continue;
		}
		if (!stream.isPaused) {
			[stream addNextFrame];
		}
	}
}

- (void)internalInstallTimers {
	self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:90 target:self 
													selector:@selector(handleLoadTimerFired:) userInfo:nil repeats:YES];
	
	self.addTimer = [NSTimer scheduledTimerWithTimeInterval:[SettingsController sharedInstance].cardsInterval target:self 
												   selector:@selector(handleAddTimerFired:) userInfo:nil repeats:YES];	
	
	[self handleLoadTimerFired:loadTimer];    
}

- (void)installTimers {
	if (loadTimer != nil && addTimer != nil)
		return;
    
	[self performSelectorOnMainThread:@selector(internalInstallTimers) withObject:nil waitUntilDone:NO];
}

- (void)killTimers {
	if (loadTimer == nil && addTimer == nil)
		return;
    
	[addTimer invalidate];
	self.addTimer = nil;
	
	[loadTimer invalidate];
	self.loadTimer = nil;	    
}

#pragma mark Stream Delegate

- (void)titleWasChanged:(Stream*)stream {
	[[Loader sharedInstance] storeStreams];
}

- (void)feedWasAdded:(Feed*)feed {
	[[Loader sharedInstance] storeStreams];
}

- (void)feedWasRemoved:(Feed*)feed {
	[[Loader sharedInstance] storeStreams];
}

- (void)feedWasMoved:(Feed*)feed fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	[[Loader sharedInstance] storeStreams];
}

- (void)feedWasInserted:(Feed*)feed atIndex:(NSInteger)atIndex {
	[[Loader sharedInstance] storeStreams];
}

- (void)feedWasChanged:(Feed*)feed {
	[[Loader sharedInstance] storeStreams];
}

#pragma mark SettingsDelegate

- (void)propertyChanged:(SettingsPropertyType)propertyName oldValue:(NSObject *)oldValue newValue:(NSObject *)newValue {
	[self killTimers];
	[self installTimers];
}

#pragma mark Lifecycle

-(id)init {
	DebugLog(@"creating new core...");
		
	if (self = [super init]) {
        isPaused = NO;
        
		NSMutableArray *s = [[NSMutableArray alloc] init];
		self.streams = s;
		[s release];
        
        self.pages = [[[NSMutableArray alloc] init] autorelease];
		
		self.delegates = [[[NSMutableSet alloc] init] autorelease];
		
		//[self installTimers];
		
		// load browser view controller
		self.browserViewController = [[[BrowserViewController alloc] 
									  initWithNibName:@"BrowserViewController" bundle:nil] autorelease];
		
		viewedCache = [[NSMutableDictionary alloc] init];
		
		oldFramesCache = [[NSMutableSet alloc] init];
		deletedFramesCache = [[NSMutableSet alloc] init];
		
		[[SettingsController sharedInstance] addDelegate:self 
											 forProperty:SettingsPropertyTypeCardsInterval];		
	}
				
	return self;
}

- (void)dealloc {
	self.delegates = nil;
	self.rootCategory = nil;
	self.cardImage = nil;
	self.featuredFeeds = nil;
    self.pages = nil;
    
	[viewedCache release];
	[oldFramesCache release];
	[deletedFramesCache release];
	
	[self killTimers];
	
	self.browserViewController = nil;
	
	[super dealloc];
}

@end
