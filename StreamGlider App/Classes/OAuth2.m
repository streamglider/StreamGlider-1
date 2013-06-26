//
//  OAuth2.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 25/09/2010.
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

#import "OAuth2.h"
#import "AuthorizeViewController.h"
#import "OAuthCore.h"
#import "NSString+OAuth.h"
#import "JSON.h"

@interface OAuth2 () 

@property BOOL gettingAccessToken;
- (void)clearYTCredentials;

@end

@implementation OAuth2 {
    NSMutableString *receivedData;	    
}

@synthesize clientID, clientSecret, redirectURI, accessToken, gettingAccessToken, accessTokenUri, authorizationTokenUri, delegate, realm, refreshToken;

#pragma mark Utility Methods

- (void)clearYTCredentials {
	[OAuthCore deleteKeychainValueForKey:@"yt-refresh-token"];
	[OAuthCore deleteKeychainValueForKey:@"yt-access-token"];
	self.accessToken = nil;
	self.refreshToken = nil;	
}

- (void)clearYTCookies:(NSURL*)url {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookiesForURL:url]) {
        [storage deleteCookie:cookie];
    }
}

#pragma mark OAuthProtocol

- (BOOL)authenticated {
    if ([realm isEqualToString:FACEBOOK_REALM]) 
         return accessToken != nil;
    else 
         return (accessToken != nil && refreshToken != nil);
}

- (void)authorizationGranted:(NSString*)t refresh:(BOOL)refresh {
	DebugLog(@"%@ auth granted by user", realm);
	// exchange code to access token
	receivedData = [[NSMutableString alloc] init];
	
	NSURLRequest *request;
	if ([realm isEqualToString:FACEBOOK_REALM]) {	
		NSString *urlString = [NSString stringWithFormat:@"%@%@", authorizationTokenUri, t];
		NSURL *url = [NSURL URLWithString:urlString];
		request = [NSURLRequest requestWithURL:url];
	} else {
		NSURL *url = [NSURL URLWithString:authorizationTokenUri];
		NSMutableURLRequest *mr = [[NSMutableURLRequest alloc] initWithURL:url];
		[mr setHTTPMethod:@"POST"];
        
        NSString *bodyString;
        if (refresh) {
            bodyString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=refresh_token&refresh_token=%@", clientID, clientSecret, refreshToken];            
            DebugLog(@"body string: %@", bodyString);
        } else {
            bodyString = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@", 
                                    t, clientID, clientSecret, redirectURI];  
            DebugLog(@"body string: %@", bodyString);
        }
        		
		[mr setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
		request = [[mr copy] autorelease];
		[mr release];
	}
    
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[con release];
}

- (void)getRequestToken {
	
	if (refreshToken != nil) {
		[self authorizationGranted:refreshToken refresh:YES];
		return;
	}
	
	self.gettingAccessToken = YES;
	// open authorize view controller
	// load view controller
	AuthorizeViewController *c = [OAuthCore sharedInstance].authorizeViewController;
	c.oauth = self;
	c.tokenName = @"code";
	
	// prepare request
	NSURL *url = [NSURL URLWithString:accessTokenUri];
	
	// display modal view
	[[OAuthCore sharedInstance].viewController presentModalViewController:c animated:YES];    
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	    
    if ([realm isEqualToString:FACEBOOK_REALM])
        [request setHTTPShouldHandleCookies:NO]; 
    else 
        [self clearYTCookies:url];
    
	c.request = request;	
}

- (void)authorizationCancelled {
	DebugLog(@"%@ auth cancelled by user", realm);
	self.gettingAccessToken = NO;	
	
	if ([realm isEqualToString:YOUTUBE_REALM]) {
		[self clearYTCredentials];
	}
	
	[delegate exchangeWasFinished:self];
}

- (void)authorizationGranted:(NSString *)t {
	[self authorizationGranted:t refresh:NO];
}

#pragma mark -
#pragma mark NSURLConnection protocol methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.gettingAccessToken = NO;
	[delegate exchangeWasFinished:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[receivedData appendString:str];
	[str release];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([realm isEqualToString:FACEBOOK_REALM]) {
		NSDictionary *params = [receivedData paramsDictionary];
		self.accessToken = [params objectForKey:@"access_token"];
		if (accessToken == nil) {
			self.gettingAccessToken = NO;
		} else {			
			[OAuthCore storeKeychainValue:accessToken forKey:@"fb-access-token"];
			self.gettingAccessToken = NO;
		}
	} else {
        DebugLog(@"token data: %@", receivedData);
        
		NSDictionary *d = [receivedData JSONValue];
		self.accessToken = [d objectForKey:@"access_token"];
		if (accessToken == nil) {
			self.gettingAccessToken = NO;			
			[self clearYTCredentials];
		} else {			
            NSString *rt = [d objectForKey:@"refresh_token"];
            
            DebugLog(@"refresh token: %@", rt);
            
            if (rt != nil) {
                self.refreshToken = [d objectForKey:@"refresh_token"];            
                [OAuthCore storeKeychainValue:refreshToken forKey:@"yt-refresh-token"];
            }
            
			[OAuthCore storeKeychainValue:accessToken forKey:@"yt-access-token"];
			self.gettingAccessToken = NO;
		}
	}
	
	[receivedData release];
	receivedData = nil;							
	[delegate exchangeWasFinished:self];	
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		self.gettingAccessToken = NO;
	}
	return self;
}

- (void)dealloc {
	self.clientID = nil;
	self.clientSecret = nil;
	self.redirectURI = nil;
	self.accessToken = nil;
	self.accessTokenUri = nil;
	self.authorizationTokenUri = nil;
	self.realm = nil;
	self.refreshToken = nil;
	
	[super dealloc];
}

@end
