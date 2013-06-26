//
//  Loader.m
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

#import "Loader.h"
#import "Core.h"
#import "Stream.h"
#import "FeedFactory.h"
#import "FeedSource.h"
#import "OAuthCore.h"
#import "FlickrFeed.h"
#import "CacheController.h"
#import "JSON.h"
#import "FeedSourceCategory.h"
#import "APIReader.h"
#import "FeedsParser.h"
#import "FeaturedFeedsLoader.h"
#import "PageOfStreams.h"
#import "StreamsLoader.h"

@implementation Loader {
	Core *core;
	BOOL loaded;
	FeedSourceType currentType;
	
	int catCounter;
	int sourcesCounter;	    
    StreamsLoader *streamsLoader;
}

@synthesize delegate, ffLoader;

#define SOURCES_DATA_FILE @"streamcast_sources.data"
#define STREAMS_DATA_FILE @"streamcast_streams.data"

#define STREAMS_RESOURCE @"streams"
#define SOURCES_RESOURCE @"feeds"

#pragma mark Stroring Data

- (void)storeSources {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:SOURCES_DATA_FILE];
        
        // find my feeds
        for (FeedSourceCategory *fsc in core.rootCategory.children) {
            if ([fsc.title isEqualToString:@"My Feeds"]) {
                [NSKeyedArchiver archiveRootObject:[fsc.children objectAtIndex:0] toFile:path];		                
                break;
            }
        }
	}
}

- (void)storeStreams {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:STREAMS_DATA_FILE];
		[NSKeyedArchiver archiveRootObject:core.pages toFile:path];		
	}
}


#pragma mark Reading Defaults

- (void)readSource:(NSDictionary*)src withParent:(FeedSourceCategory*)parent {
	FeedSource *fs = [[FeedSource alloc] init];
	fs.title = [src objectForKey:@"title"];
	fs.title = [fs.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	fs.URLString = [src objectForKey:@"url"];
	fs.URLString = [fs.URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	fs.type = currentType;
	
	[parent addChild:fs];
	[fs release];
}

- (void)readCategory:(NSDictionary*)cat withParent:(FeedSourceCategory*)parent {
	FeedSourceCategory *c = [[FeedSourceCategory alloc] init];
	c.title = [cat objectForKey:@"title"];
	c.title = [c.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *arr = [cat objectForKey:@"children"];
	for (NSDictionary *child in arr) {
		if ([child objectForKey:@"url"] != nil) {
			// feed source
			sourcesCounter++;
			[self readSource:child withParent:c];
		} else {
			// subcategory
			catCounter++;
			[self readCategory:child withParent:c];
		}
	}
	[parent addChild:c];
	c.parentCategory = parent;
	[c release];
}

- (void)loadDefaultSources {
	// read default sources from FS
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *p = [mainBundle pathForResource:SOURCES_RESOURCE ofType:@"json"];
	
	NSString *str = [NSString stringWithContentsOfFile:p encoding:NSUTF8StringEncoding 
												 error:NULL];
	
	NSArray *arr = [str JSONValue];	
	
	FeedSourceCategory *root = [[FeedSourceCategory alloc] init];
	root.title = @"Categories";
	core.rootCategory = root;
	[root release];
	
	int totalSources = 0;
	for (NSDictionary* cat in arr) {
		NSString *t = [cat objectForKey:@"title"];
		currentType = [FeedFactory typeForStringName:t];		
		catCounter = 0;
		sourcesCounter = 0;
		[self readCategory:cat withParent:root];
		totalSources += sourcesCounter;
		NSLog(@"category: %@ | subcat count: %d | sources count: %d", t, catCounter, sourcesCounter);
	}
	
	NSLog(@"total sources count: %d", totalSources);
}

- (void)loadDefaultStreamsFromFS {
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *p = [mainBundle pathForResource:STREAMS_RESOURCE ofType:@"json"];
	
	NSString *str = [NSString stringWithContentsOfFile:p encoding:NSUTF8StringEncoding 
												 error:NULL];	
	NSDictionary *dic = [str JSONValue];
	NSArray *streams = [dic objectForKey:@"streams"];
	
    // create default page
    PageOfStreams *page = [[PageOfStreams alloc] init];
    page.title = @"Home";
    [core addPage:page makeActive:YES];
    [page release];
    
	for (NSDictionary *stream in streams) {
		Stream *s = [[Stream alloc] init];
		s.title = [stream objectForKey:@"title"];
		NSArray *feeds = [stream objectForKey:@"feeds"];
		for (NSDictionary *feed in feeds) {
			Feed *f;
			FeedSource *fs = [[FeedSource alloc] init];
			NSString *type = [feed objectForKey:@"type"];
			fs.type = [FeedFactory typeForStringName:type];
			f = [FeedFactory createFeedForSource:fs];
			fs.title = [feed objectForKey:@"title"];
			fs.URLString = [feed objectForKey:@"url"];
			
			f.source = fs;
			[fs release];
			
			f.stream = s;
			[s addFeed:f];
		}
		
		[[Core sharedInstance] addStream:s skipStoring:NO];
		s.initializing = NO;
		[s release];
	} 
    
    if (delegate != nil)            
        [delegate dataWasLoaded];		    
}

- (void)loadDefaultStreams {    
    // try loading default streams from server first
    streamsLoader = [[StreamsLoader alloc] init];
    streamsLoader.delegate = self;
    [streamsLoader loadDefaultStreams];
}

#pragma mark StreamsLoaderDelegate

- (void)defaultStreamsLoaded:(NSArray *)streams {
    [streamsLoader release];
    
    // create default page
    PageOfStreams *page = [[PageOfStreams alloc] init];
    page.title = @"Home";
    [core addPage:page makeActive:YES];
    [page release];
    
    for (Stream *s in streams) {
		[core addStream:s skipStoring:NO];
		s.initializing = NO;
    }
    
    if (delegate != nil)            
        [delegate dataWasLoaded];		        
}

- (void)defaultStreamsLoadFailed {
    [streamsLoader release];
    
    [self loadDefaultStreamsFromFS];        
}

#pragma mark Reading Data

- (FeedSourceCategory*)loadSourcesFromFS {	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {				
		NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:SOURCES_DATA_FILE];
		if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
			return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		}		
	}
	return nil;
}

- (void)loadStreamsFromFS {	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:STREAMS_DATA_FILE];
		if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
			NSArray *pages = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                        
            core.pages = [[pages mutableCopy] autorelease];
            
            // find and set active page
            for (PageOfStreams *p in pages) {
                if (p.activePage) {
                    [core setActivePage:p];
                }
            }            
		}		
	}	
	
	
}

- (void)loadSources {
	// load feeds DB from API
	APIReader *reader = [[APIReader alloc] init];
	reader.delegate = self;
	
	[reader performSelectorInBackground:@selector(loadAPIDataFor:) withObject:@"feeds.json"];
	
	self.ffLoader = [[[FeaturedFeedsLoader alloc] init] autorelease];
	[ffLoader loadFeaturedFeeds];		
}

#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
	// parse loaded sources
	FeedsParser *parser = [[FeedsParser alloc] init];	
	core.rootCategory = [parser parseFeeds:(NSArray*)data];
	[parser release];
	
	// try loading my sources
	FeedSourceCategory *myCategory = [self loadSourcesFromFS];
	
	if (myCategory != nil) {
		// attach my sources to the overall hierarchy
        for (FeedSourceCategory *fsc in core.rootCategory.children) {
            if ([fsc.title isEqualToString:@"My Feeds"]) {
                FeedSourceCategory *mf = [fsc.children objectAtIndex:0];
                myCategory.imageURL = mf.imageURL;
                [fsc.children replaceObjectAtIndex:0 withObject:myCategory];
                break;
            }
        }
	} 	
	
	[reader release];
}

- (void)apiLoadFailed:(APIReader*)reader {
	// API load failed, load local sources
	[self loadDefaultSources];
	
	// try loading my sources
	FeedSourceCategory *myCategory = [self loadSourcesFromFS];
	
	if (myCategory != nil) {
		// attach my sources to the overall hierarchy
		[core.rootCategory.children replaceObjectAtIndex:0 withObject:myCategory];
	} 
	
	[reader release];
}

#pragma mark Loading

- (void)coreWasConnected {
	
	[self loadStreamsFromFS];
	
	[[CacheController sharedInstance] loadCacheData];
	
	// in case there is no streams, load default streams
	if ([core.pages count] == 0) {	
		[self loadDefaultStreams];
	} else {
		// add cached frames to streams
        for (PageOfStreams *p in core.pages) {
            for (Stream *s in p.streams) {
                NSArray *frames = [[CacheController sharedInstance] getFramesForStream:s];
                for (Frame *f in frames) {
                    [s.frames insertObject:f atIndex:0];
                }			
            }
        }
        
        if (delegate != nil)            
            [delegate dataWasLoaded];		
	}
	
}

- (void)loadWithCore:(Core*) c {
	if (loaded)
		return;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	loaded = YES;
	
	DebugLog(@"loading...");
	
	core = c;
	
	// load sources
	[self loadSources];	
	
	[self coreWasConnected];
	
	[pool drain];
}

#pragma mark Singleton

static Loader* instance = nil;

+ (Loader*)sharedInstance {
	if (instance == nil) {
		instance = [[Loader alloc] init];
	}
	return instance;
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		loaded = NO;
	}
	return self;
}

- (void)dealloc {
	self.ffLoader = nil;
    
    [streamsLoader release];
	
	[super dealloc];
}

@end
