//
//  OAuth.m
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

#include <CommonCrypto/CommonHMAC.h>

#import "OAuth.h"
#import "KeyValuePair.h"
#import "NSData+Base64.h"
#import "NSString+OAuth.h"
#import "AuthorizeViewController.h"
#import "OAuthCore.h"

@interface OAuth () 

@property (nonatomic, copy) NSString *verifier;
@property (nonatomic, copy) NSString *requestToken;
@property (nonatomic, copy) NSString *requestTokenSecret;

@property BOOL gettingAccessToken;
@property BOOL retainThread;

@end

@implementation OAuth {
    NSMutableString *receivedData;	
    
}

@synthesize realm, consumerKey, consumerSecret, callback, 
	version, token, tokenSecret, verifier, requestToken, requestTokenSecret,
	requestTokenUrl, accessTokenUrl, authorizeUrl, signatureMethod,
	gettingAccessToken, delegate, retainThread;

#pragma mark Getting Access Token 

- (void)accessTokenWasNotAcquired {
    self.requestToken = nil;
    self.requestTokenSecret = nil;	
	self.gettingAccessToken = NO;	
    self.verifier = nil;
    
	[delegate exchangeWasFinished:self];
}

- (void)accessTokenWasAcquired {
	self.gettingAccessToken = NO;
	[delegate exchangeWasFinished:self];
}

- (NSString*)createHMACSHA1SignatureFor:(NSString*)baseString key:(NSString*)key {	
	
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [baseString UTF8String], [baseString length], buf);
	
	NSData *hmac = [[NSData alloc] initWithBytes:buf
										  length:CC_SHA1_DIGEST_LENGTH];
	
	NSString *hash = [hmac base64EncodedString];	
	
	[hmac release];
	
	return hash;	
}

- (KeyValuePair*)createPairForKey:(NSString*)key value:(NSString*)value {
	KeyValuePair *kvp = [[KeyValuePair alloc] initWithKey:key value:[NSString URLEncodeString:value]];
	return [kvp autorelease];
}

- (NSString*)generateNonce {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	//get the string representation of the UUID
	NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];	
}

- (void)addAuthorizationHeaderTo:(NSMutableURLRequest*)request {
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	
	// consumer key
	[params addObject:[self createPairForKey:@"oauth_consumer_key" value:consumerKey]];
	
	// signature method
	[params addObject:[self createPairForKey:@"oauth_signature_method" value:signatureMethod]];
	
	// timestamp
	NSDate *now = [[NSDate alloc] init];
	int seconds = abs([now timeIntervalSince1970]);
	[now release];
	[params addObject:[self createPairForKey:@"oauth_timestamp" 
									   value:[NSString stringWithFormat:@"%d", seconds]]];
	
	// nonce
	NSString *nonce = [self generateNonce];
	[params addObject:[self createPairForKey:@"oauth_nonce" 
									   value:[NSString stringWithFormat:@"%@", nonce]]];
	
	// token
	if (token != nil) {
		[params addObject:[self createPairForKey:@"oauth_token" 
										   value:token]];		
	}
	
	if (token == nil) {
		// we only need callback for obtaining request token
		[params addObject:[self createPairForKey:@"oauth_callback" value:callback]];
	}
	
	// verifier 
	if (verifier) {
		[params addObject:[self createPairForKey:@"oauth_verifier" value:verifier]];		
	}
	
	// version
	[params addObject:[self createPairForKey:@"oauth_version" value:version]];
	
	// add params from the query part of URL
	NSString *query = [[request URL] query];
	NSArray *queryArray = [query componentsSeparatedByString:@"&"];
	for (NSString *pair in queryArray) {
		NSArray *pairArray = [pair componentsSeparatedByString:@"="];
		NSString *key = [pairArray objectAtIndex:0];
		NSString *value = [pairArray objectAtIndex:1];
		KeyValuePair *kvp = [[KeyValuePair alloc] initWithKey:key value:value];
		[params addObject:kvp];
		[kvp release];
	}
	
	// sort array with parameters
	NSSortDescriptor *sorterKey = [[NSSortDescriptor alloc] initWithKey:@"key" ascending: YES];
	NSSortDescriptor *sorterValue = [[NSSortDescriptor alloc] initWithKey:@"value" ascending: YES];
	
	NSArray *sorters = [NSArray arrayWithObjects:sorterKey, sorterValue, nil];
	[params sortUsingDescriptors:sorters];
	[sorterKey release];
	[sorterValue release];
	
	// prepare base string for signing
	NSString *paramsString = [params componentsJoinedByString:@"&"];
	
	DebugLog(@"params: %@", paramsString);
	
	NSURL *url = [request URL];
	
	NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", [url scheme], [url host], [url path]];
	
	NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@",
							request.HTTPMethod,
							[NSString URLEncodeString:urlString],
							[NSString URLEncodeString:paramsString]];
	
	DebugLog(@"base string: %@", baseString);
	
	NSString *key = [NSString stringWithFormat:@"%@&%@", [NSString URLEncodeString:consumerSecret], 
					 [NSString URLEncodeString:tokenSecret]];
	
	DebugLog(@"key: %@", key);
	
	// create signature
	NSString *hash = [self createHMACSHA1SignatureFor:baseString key:key];
	
	DebugLog(@"hash: %@", hash);
	
	// signature
	[params addObject:[self createPairForKey:@"oauth_signature" 
									   value:hash]];
	
	NSMutableString *headerValue = [NSMutableString stringWithString:@"OAuth "];
	
	BOOL first = YES;
	
	for (KeyValuePair* kvp in params) {
		NSString *separator = @", ";
		if (first) {
			first = NO;
			separator = @"";
		}
		[headerValue appendFormat:@"%@%@=\"%@\"", separator, 
		 [NSString URLEncodeString:kvp.key], kvp.value]; 
	}
	
	[params release];
	
	DebugLog(@"header value: %@", headerValue);
	
	[request setValue:headerValue forHTTPHeaderField:@"Authorization"];	
}

- (void)getAuthorizationToken {
	// load view controller
	
	AuthorizeViewController *c = [OAuthCore sharedInstance].authorizeViewController;
	c.oauth = self;
	c.tokenName = @"oauth_verifier";
		
	// prepare request
	NSString *urlString = [NSString stringWithFormat:@"%@?oauth_token=%@", authorizeUrl, requestToken];
    
	NSURL *url = [NSURL URLWithString:urlString];
		
	// display modal view
	[[OAuthCore sharedInstance].viewController presentModalViewController:c animated:YES];    
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];	
    [request setHTTPShouldHandleCookies:NO];
    
	c.request = request;	
}

- (void)getAccessToken {
	self.token = requestToken;
	self.tokenSecret = requestTokenSecret;
	
	receivedData = [[NSMutableString alloc] init];
	
	NSURL *url = [[NSURL alloc] initWithString:accessTokenUrl];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	
	// add oauth authorization header
	[self addAuthorizationHeaderTo:request]; 
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[url release];
	[request release];
	[connection release];
}


#pragma mark NSURLConnection

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"error: %@", error);
	[self accessTokenWasNotAcquired];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[receivedData appendString:str];
	[str release];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (requestToken == nil) {
		// we've got request token, now we need to redirect user to authorize us
		NSDictionary *params = [receivedData paramsDictionary];
		self.requestToken = [params objectForKey:@"oauth_token"];
		self.requestTokenSecret = [params objectForKey:@"oauth_token_secret"];	
		if (self.requestToken == nil) {
			// we can't get request token
			[self accessTokenWasNotAcquired];
		} else {
			[self getAuthorizationToken];
		}
	} else {
		// we've got access token, we need to store it securely and sign all pending requests
		self.requestToken = nil;
		self.requestTokenSecret = nil;
		self.verifier = nil;
		
		NSDictionary *params = [receivedData paramsDictionary];
		self.token = [params objectForKey:@"oauth_token"];
		self.tokenSecret = [params objectForKey:@"oauth_token_secret"];	
		
		if (token == nil) {
			[self accessTokenWasNotAcquired];
		} else {			
			[OAuthCore storeKeychainValue:self.token forKey:@"twitter-token"];
			[OAuthCore storeKeychainValue:self.tokenSecret forKey:@"twitter-secret"];
			
			[self accessTokenWasAcquired];
		}
	}
	
	[receivedData release];
	receivedData = nil;							
}

#pragma mark OAuthProtocol

- (BOOL)authenticated {
	return (token != nil && tokenSecret != nil); 
}

- (void)signRequest:(NSMutableURLRequest*)request {
	
	if (self.gettingAccessToken) {
		return;
	} else {
		// sign request and call delegate straight away
		// add oauth authorization header
		[self addAuthorizationHeaderTo:request]; 
	}	
}

- (void)authorizationGranted:(NSString *)t {
	DebugLog(@"verifier granted: %@", t);
	self.verifier = t;	
	
	// send request for access token
	[self getAccessToken];	
}

- (void)authorizationCancelled {
	DebugLog(@"authorization cancelled");
	[self accessTokenWasNotAcquired];
}

- (void)getRequestToken {
	receivedData = [[NSMutableString alloc] init];
	
	NSURL *url = [[NSURL alloc] initWithString:requestTokenUrl];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
	[request setHTTPMethod:@"POST"];
	
	// add oauth authorization header
	[self addAuthorizationHeaderTo:request]; 
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[url release];
	[request release];
	[connection release];
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		self.gettingAccessToken = NO;
	}
	return self;			
}

- (void)dealloc {
    self.realm = nil;
    self.consumerKey = nil;
    self.consumerSecret = nil;
    self.callback = nil;
    self.version = nil;
    self.token = nil;
    self.tokenSecret = nil;
    self.signatureMethod = nil;
    self.requestTokenUrl = nil;
    self.accessTokenUrl = nil;
    self.authorizeUrl = nil;
    
    self.verifier = nil;
    self.requestToken = nil;
    self.requestTokenSecret = nil;
    
    [super dealloc];
}

@end
