//
//  StreamCastAppDelegate.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/15/10.
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

#import "StreamCastAppDelegate.h"
#import "StreamCastViewController.h"
#import "Core.h"
#import "Loader.h"
#import "CacheController.h"

@implementation StreamCastAppDelegate {
    BOOL wasInBackground;
}

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	wasInBackground = NO;
	
    // Override point for customization after app launch. 
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
 	
    window.rootViewController = navigationController;
	
	return YES;
}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	if (wasInBackground) {
		[[Core sharedInstance] installTimers];
		wasInBackground = NO;
	}
}


- (void)applicationDidEnterBackground:(UIApplication *)application {	
	
	wasInBackground = YES;
	
	[[Core sharedInstance] killTimers];
	
	[[Loader sharedInstance] storeStreams];
	
	[[CacheController sharedInstance] storeCacheData];	
	
	// sync images in background thread
	[[CacheController sharedInstance] performSelectorInBackground:@selector(syncResourcesAndImagesCache) withObject:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	// dump cache
	[[CacheController sharedInstance] dumpCache];
}


- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end
