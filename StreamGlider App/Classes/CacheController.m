//
//  CacheController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 13/10/2010.
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

#import "CacheController.h"


@interface CacheController () 
- (NSData*)loadImageDataViaProxy:(NSString*)url;
@end


@implementation CacheController


#pragma mark Caching


- (NSData*)loadImageData:(NSString*)url {
    if (PROXY_ENABLED) {
        return [self loadImageDataViaProxy:url];
    } else {
        return [super loadImageData:url];
    }
}


- (NSData*)loadImageDataViaProxy:(NSString*)url {

	CFURLRef urlRef = CFURLCreateWithString(NULL, (CFStringRef)url, NULL);	
	CFHTTPMessageRef message = CFHTTPMessageCreateRequest(NULL, CFSTR("GET"), urlRef, kCFHTTPVersion1_1);	
	CFRelease(urlRef);
	
	CFHTTPMessageAddAuthentication(message, NULL, (CFStringRef)PROXY_USER, (CFStringRef)PROXY_PASSWORD, 
								   kCFHTTPAuthenticationSchemeBasic, NO);
	
	CFReadStreamRef stream = CFReadStreamCreateForHTTPRequest(NULL, message);
	CFRelease(message);
		
	CFTypeRef keys[2], values[2];
	keys[0] = kCFStreamPropertyHTTPProxyHost;
	values[0] = (CFStringRef)PROXY_HOST;
	keys[1] = kCFStreamPropertyHTTPProxyPort;
	SInt32 port = PROXY_PORT;
	values[1] = CFNumberCreate(NULL, kCFNumberSInt32Type, 
							   &port);
	CFDictionaryRef proxyDict = CFDictionaryCreate(NULL, keys, values, 2, 
								   &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPProxy, 
							proxyDict);
	
	CFRelease(values[1]);
	CFRelease(proxyDict);
	
	CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
	
	if (CFReadStreamOpen(stream)) {
		CFIndex numBytesRead;
		NSMutableData *d = [[NSMutableData alloc] init];
		do {
			UInt8 buf[1024];
			numBytesRead = CFReadStreamRead(stream, buf, sizeof(buf));
			if (numBytesRead > 0) {
				[d appendBytes:buf length:numBytesRead];
			}			
		} while (numBytesRead > 0);
		
		CFReadStreamClose(stream);
		CFRelease(stream);
			
		return [d autorelease];
	}
	CFRelease(stream);
	
	return nil;
}



#pragma mark Singleton

static CacheController* instance = nil;

+ (CacheController*)sharedInstance {
	if (instance == nil) {
		instance = [[CacheController alloc] init];
	}
	
	return instance;
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
        // Do nothing.
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}


@end
