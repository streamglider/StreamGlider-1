//
//  LoginController.m
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

#import "LoginController.h"
#import "APIReader.h"
#import "JSON.h"
#import "Core.h"

@implementation LoginController {
	BOOL loading;
    BOOL getAPIToken;    
}

@synthesize delegate, reader;

#pragma mark APIDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
	NSDictionary *dic = (NSDictionary*)data;
    NSString *msg = [dic objectForKey:@"error"];
	if (msg != nil) {
		[delegate loginActionFailed:msg];
	} else {
        if (getAPIToken)
            [Core sharedInstance].apiToken = [dic objectForKey:@"token"];        
        
		[delegate loginActionOK];
	}
	
	loading = NO;
}

- (void)apiLoadFailed:(APIReader*)reader {
	[delegate loginActionFailed:@"Server error"];
	loading = NO;
}

#pragma mark Loading

- (void)loginWithEmail:(NSString*)email password:(NSString*)password {
    getAPIToken = YES;
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
	self.reader = [[[APIReader alloc] init] autorelease];
	reader.delegate = self;
	NSDictionary *d = [NSDictionary dictionaryWithObject:
					   [NSDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil] 
                                                  forKey:@"user"];
    
	reader.postData = [d JSONRepresentation];
	[reader loadAPIDataFor:@"users/sign_in.json" withMethod:@"POST" addAuthToken:NO];
    
	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];    
}

- (void)registerWithEmail:(NSString*)email password:(NSString*)password newsletter:(BOOL)newsletter {
    getAPIToken = YES;
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
	self.reader = [[[APIReader alloc] init] autorelease];
	reader.delegate = self;
	NSDictionary *d = [NSDictionary dictionaryWithObject:
					   [NSDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", 
						[NSString stringWithFormat:@"%d", newsletter], 
						@"newsletter", nil] 
												  forKey:@"user"];
	reader.postData = [d JSONRepresentation];
	[reader loadAPIDataFor:@"users.json" withMethod:@"POST" addAuthToken:NO];

	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];
}

- (void)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword {
    getAPIToken = NO;
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
	self.reader = [[[APIReader alloc] init] autorelease];
	reader.delegate = self;
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:oldPassword, @"old_password", newPassword, @"new_password", nil];
    
	reader.postData = [d JSONRepresentation];
	[reader loadAPIDataFor:@"change_password.json" withMethod:@"POST" addAuthToken:YES];
    
	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];    
}

#pragma mark Lifecycle

- (void)dealloc {
	self.reader = nil;
	
	[super dealloc];
}

@end
