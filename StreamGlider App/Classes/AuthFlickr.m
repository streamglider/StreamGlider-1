//
//  AuthFlickr.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 04/10/2010.
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

#import "AuthFlickr.h"
#import "NSString+OAuth.h"
#import "AuthorizeViewController.h"
#import "OAuthCore.h"
#import "Core.h"

@interface AuthFlickr () 

@property BOOL gettingAccessToken;

@end

@implementation AuthFlickr {
	NSMutableString *receivedData;    
}

@synthesize apiKey, loginURL, authToken, gettingAccessToken, apiSecret, delegate;

#pragma mark OAuthProtocol

- (void)getRequestToken {
	self.gettingAccessToken = YES;
	// open authorize view controller
	// load view controller
	AuthorizeViewController *c = [OAuthCore sharedInstance].authorizeViewController;
	c.oauth = self;
	c.tokenName = @"frob";
	
	NSString *baseString = [NSString stringWithFormat:@"%@api_key%@permsread", apiSecret, apiKey];
	
	// prepare request
	NSString *urlString = [NSString stringWithFormat:@"%@%@&perms=read&api_sig=%@",
						   loginURL, apiKey, [NSString md5:baseString]];
	
	NSURL *url = [NSURL URLWithString:urlString];
	
    // clear cookies in order to display auth dialog again
    [Core clearCookies:url];
    
	// display modal view
	[[OAuthCore sharedInstance].viewController presentModalViewController:c animated:YES];	
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];	
	c.request = request;		
}

- (BOOL)authenticated {
	return (authToken != nil);
}

- (void)authorizationCancelled {
	self.gettingAccessToken = NO;	
	[delegate exchangeWasFinished:self];
}

- (void)authorizationGranted:(NSString*)token {
	// convert frob to an access token
	// exchange code to access token
	receivedData = [[NSMutableString alloc] init];
	
	NSString *baseString = [NSString stringWithFormat:@"%@api_key%@frob%@methodflickr.auth.getToken", 
							apiSecret, apiKey, token]; 
	
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.auth.getToken&api_key=%@&frob=%@&api_sig=%@",
						   apiKey, token, [NSString md5:baseString]];
	
	DebugLog(@"url string: %@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[con release];	
}

- (void)signRequest:(NSMutableURLRequest*)request {
	if (authToken != nil) {
		// parse query params
		NSString *query = [[request URL] query];
		NSArray *queryArray = [query componentsSeparatedByString:@"&"];
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		for (NSString *pair in queryArray) {
			NSArray *pairArray = [pair componentsSeparatedByString:@"="];
			NSString *key = [pairArray objectAtIndex:0];
			NSString *value = [pairArray objectAtIndex:1];
			DebugLog(@"key: %@, value: %@", key, value);
			[dict setObject:value forKey:key];
		}
		
		// add auth_token and api key
		[dict setObject:authToken forKey:@"auth_token"];
		[dict setObject:apiKey forKey:@"api_key"];
		
		// sort dictionary keys
		NSMutableArray *keys = [NSMutableArray arrayWithArray:[dict allKeys]];
		
		NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"description" ascending: YES];
		
		NSArray *sorters = [NSArray arrayWithObject:sorter];
		[keys sortUsingDescriptors:sorters];
		
		[sorter release];		
		
		NSMutableString *baseString = [NSMutableString stringWithFormat:@"%@", apiSecret];
		
		for (NSString *key in keys) {
			NSString *val = [dict objectForKey:key];
			val = [NSString URLDecodeString:val];
			[baseString appendFormat:@"%@%@", key, val];
		}		
		
		DebugLog(@"base string: %@", baseString);
		
		[dict setObject:[NSString md5:baseString] forKey:@"api_sig"];
		
		// generate new query string
		NSURL *url = [request URL];
		NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://%@%@?", [url host], [url path]];
		
		// add query params
		for (NSString *key in [dict allKeys]) {
			[urlString appendFormat:@"%@=%@&", key, [dict objectForKey:key]];
		}
		
		DebugLog(@"url string: %@", urlString);
		
		url = [NSURL URLWithString:urlString];
		[request setURL:url];		
		
		[dict release];
 	} else {
		// we can put api_key into the request
		NSString *query = [[request URL] query];
		query = [query stringByAppendingFormat:@"&api_key=%@", apiKey];
		NSURL *url = [request URL];
		NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", [url host], [url path], query];
		url = [NSURL URLWithString:urlString];
		[request setURL:url];
	}

}

#pragma mark -
#pragma mark NSURLConnection protocol methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"error: %@", error);
	self.gettingAccessToken = NO;
	[delegate exchangeWasFinished:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[receivedData appendString:str];
	[str release];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DebugLog(@"%@", receivedData);
	NSRange start = [receivedData rangeOfString:@"<token>"];
	NSRange end = [receivedData rangeOfString:@"</token"];
	
	if (start.location != NSNotFound && end.location != NSNotFound) {
		NSRange rng;
		rng.location = start.location + start.length;
		rng.length = end.location - rng.location;
		self.authToken = [receivedData substringWithRange:rng];
		[OAuthCore storeKeychainValue:authToken forKey:@"flickr-auth-token"];		
	} 
	
	self.gettingAccessToken = NO;
		
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
	self.apiKey = nil;
	self.apiSecret = nil;
	self.loginURL = nil;
	self.authToken = nil;
    
	[super dealloc];
}


@end
