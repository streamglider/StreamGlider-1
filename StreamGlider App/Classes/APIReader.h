//
//  FeedsReader.h
//  StreamGlider
//
//  Created by Dmitry Shingarev on 17/08/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
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
