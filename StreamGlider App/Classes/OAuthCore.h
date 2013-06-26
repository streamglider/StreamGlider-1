//
//  OAuthCore.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 03/08/2010.
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

#import <Foundation/Foundation.h>
#import "OAuthProtocol.h"
#import "OAuthDelegate.h"

@class AuthorizeViewController;
@class StreamCastViewController;

@interface OAuthCore : NSObject <OAuthDelegate, UIAlertViewDelegate> 
	
@property (nonatomic, assign) UIViewController *viewController;
@property (nonatomic, retain) AuthorizeViewController *authorizeViewController;
@property (nonatomic, assign) StreamCastViewController *streamCastViewController;

- (id<OAuthProtocol>)getOAuthForRealm:(NSString*)realm;

+ (OAuthCore*)sharedInstance;

+ (NSString*)getValueFromKeyChainFor:(NSString*)key;
+ (void)storeKeychainValue:(NSString*)value forKey:(NSString*)key;  
+ (void)deleteKeychainValueForKey:(NSString*)key;

- (void)requestAuthForRealm:(NSString*)realm withDelegate:(id<OAuthDelegate>)aDelegate viewController:(UIViewController*)vc;
- (void)requestAuthForRealm:(NSString*)realm withDelegate:(id<OAuthDelegate>)aDelegate viewController:(UIViewController*)vc askUser:(BOOL)askUser reason:(NSString*)reason;

- (void)clearAllTokens;
- (void)clearTokenForRealm:(NSString*)realm;

@end
