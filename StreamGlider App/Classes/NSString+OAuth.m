//
//  NSString+OAuth.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 05/08/2010.
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

#import <CommonCrypto/CommonDigest.h>
#import "NSString+OAuth.h"


@implementation NSString (OAuth)

-(NSDictionary*)paramsDictionary {
	NSArray *params = [self componentsSeparatedByString:@"&"];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString* pair in params) {
		NSArray *pairArray = [pair componentsSeparatedByString:@"="];
		NSString *key = [pairArray objectAtIndex:0];
		NSString *value = @"";
		
		if ([pairArray count] > 1) 
			value = [pairArray objectAtIndex:1];
		
		[dict setObject:value forKey:key];
	}
		
	return [NSDictionary dictionaryWithDictionary:dict];
}

+ (NSString*)md5:(NSString*)str {
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			]; 
}

+ (NSString*)URLEncodeString:(NSString*)str {
	if (str != nil) {
		NSString *ret = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, 
																			(CFStringRef)str, 
																			NULL, 
																			(CFStringRef)@"￼=,!$&'()*+;@?\n\"<>#\t :/", 
																			kCFStringEncodingUTF8);	
		return [ret autorelease];
	} else {
		return @"";
	}

}

+ (NSString*)URLDecodeString:(NSString*)str {
	if (str != nil) {
		NSString *ret = (NSString*) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, 
																							(CFStringRef)str, 
																							CFSTR(""), 
																							kCFStringEncodingUTF8);
		return [ret autorelease];
	} else {
		return @"";
	}	
}

@end
