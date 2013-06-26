//
//  FeedsReader.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 17/08/2011.
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

#import <Foundation/Foundation.h>
#import "APIDelegate.h"
#import "LoginVCDelegate.h"

@interface APIReader : NSObject <LoginVCDelegate, APIDelegate> 

@property (nonatomic, assign) id<APIDelegate> delegate;
@property (nonatomic, retain) NSString *postData;
@property (nonatomic, assign) BOOL handleAuthError;
@property (nonatomic, assign) UIViewController *viewController;

@property (nonatomic, assign) BOOL addAuthToken;
@property (nonatomic, copy) NSString *pathAndQuery;
@property (nonatomic, copy) NSString *method;

@property (nonatomic, retain) APIReader *reader;

- (void)loadAPIDataFor:(NSString*)pathAndQuery;
- (void)loadAPIDataFor:(NSString*)pathAndQuery withMethod:(NSString*)method;
- (void)loadAPIDataFor:(NSString*)pathAndQuery withMethod:(NSString*)method addAuthToken:(BOOL)addAuthToken;
- (void)loadAPIDataFor:(NSString*)pathAndQuery withMethod:(NSString*)method addAuthToken:(BOOL)addAuthToken handleAuthError:(BOOL)handleAuthError;

@end
