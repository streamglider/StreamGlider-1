//
//  OAuth.h
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


@interface OAuth : NSObject <OAuthProtocol> {	
}

@property (nonatomic, copy) NSString *realm;
@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) NSString *callback;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *tokenSecret;
@property (nonatomic, copy) NSString *signatureMethod;

@property (nonatomic, copy) NSString *requestTokenUrl;
@property (nonatomic, copy) NSString *accessTokenUrl;
@property (nonatomic, copy) NSString *authorizeUrl;


@property (nonatomic, assign) id<OAuthDelegate> delegate;

@end
