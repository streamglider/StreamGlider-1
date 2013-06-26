//
//  FeedsReader.m
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

#import "APIReader.h"
#import "JSON.h"
#import "Core.h"
#import "LoginViewController.h"
#import "StreamCastAppDelegate.h"

@implementation APIReader {
	BOOL loading;	
	NSMutableString *receivedData;    
}

@synthesize delegate, postData, handleAuthError, viewController, addAuthToken, method, pathAndQuery, reader;

#pragma mark FeedsReader API

- (void)internalLoadAPIData {	
    NSString *urlString;
	if (addAuthToken && [Core sharedInstance].apiToken != nil) {
		if ([pathAndQuery rangeOfString:@"?"].location == NSNotFound) {
			urlString = [NSString stringWithFormat:@"%@/%@?auth_token=%@", API_V2_URL, pathAndQuery, 
                         [Core sharedInstance].apiToken];
		} else {
			urlString = [NSString stringWithFormat:@"%@/%@&auth_token=%@", API_V2_URL, pathAndQuery, 
						 [Core sharedInstance].apiToken];			
		}
	} else {
		urlString = [NSString stringWithFormat:@"%@/%@", API_V2_URL, pathAndQuery];		
	}
	
    DebugLog(@"url string in API Reader: %@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	[request setHTTPMethod:method];
	
	if (postData != nil) {
		[request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	} else {
		[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	}
    
	receivedData = [[NSMutableString alloc] init];
	
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [request release];
	
	[con autorelease];    
}

- (void)loadAPIDataFor:(NSString*)aPathAndQuery withMethod:(NSString*)aMethod addAuthToken:(BOOL)anAddAuthToken handleAuthError:(BOOL)aHandleAuthError {
    self.handleAuthError = aHandleAuthError;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	loading = YES;
	
    self.pathAndQuery = aPathAndQuery;
    self.method = aMethod;
    self.addAuthToken = anAddAuthToken;
    	
    [self internalLoadAPIData];
	
	while (loading) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];		
    
}


- (void)loadAPIDataFor:(NSString*)aPathAndQuery withMethod:(NSString*)aMethod addAuthToken:(BOOL)anAddAuthToken {
    [self loadAPIDataFor:aPathAndQuery withMethod:aMethod addAuthToken:anAddAuthToken handleAuthError:NO];
}


- (void)loadAPIDataFor:(NSString*)aPathAndQuery withMethod:(NSString*)aMethod {
    [self loadAPIDataFor:aPathAndQuery withMethod:aMethod addAuthToken:YES];
}

- (void)loadAPIDataFor:(NSString*)aPathAndQuery {
    [self loadAPIDataFor:aPathAndQuery withMethod:@"GET" addAuthToken:YES];
}

#pragma mark LoginVCDelegate

- (void)loginOK {
    self.reader = [[[APIReader alloc] init] autorelease];
    
    reader.postData = self.postData;
    reader.delegate = self;
    
    [reader loadAPIDataFor:pathAndQuery withMethod:method addAuthToken:addAuthToken handleAuthError:NO];    
}

- (void)loginFailed {
    [delegate apiLoadFailed:self];		
    loading = NO;    
}

#pragma mark UIAlertViewDelegate

- (void)showLoginPanel:(LoginViewController*)lvc {    
    [viewController presentModalViewController:lvc animated:YES];
    [lvc autorelease];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
       // present user with a login panel 
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        lvc.panelType = LoginPanelTypeSwitchIdentity;
        lvc.modalPresentationStyle = UIModalPresentationFormSheet;
        lvc.delegate = self;
        
        [self performSelectorOnMainThread:@selector(showLoginPanel:) withObject:lvc
                            waitUntilDone:NO];        
    } else {
		[delegate apiLoadFailed:self];		
        loading = NO;
    }
}

#pragma mark APIReaderDelegate

- (void)apiLoadCompleted:(NSObject*)data reader:(APIReader*)reader {
    [delegate apiLoadCompleted:data reader:self];
}

- (void)apiLoadFailed:(APIReader*)reader {
    [delegate apiLoadFailed:self];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if (s != nil)
		[receivedData appendString:s];
	
	[s release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	[receivedData release];
	[delegate apiLoadFailed:self];
	loading = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	DebugLog(@"%@", receivedData);
	
	NSObject *obj = [receivedData JSONValue];  
    [receivedData release];
	if (obj == nil) {
		[delegate apiLoadFailed:self];	
        loading = NO;
        return;
	} else {		
        if (handleAuthError) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary*)obj;
                NSString *errCode = [dic objectForKey:@"error"];
                if (errCode != nil && [errCode isEqualToString:@"Invalid authentication token."]) {
                    // ask user to authenticate with API
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:@"You need to login to your account in order to proceed." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    [alert show];
                    [alert autorelease];                    
                    return;                    
                }                     
            }                  
        } 
	}
    
    [delegate apiLoadCompleted:obj reader:self];
	loading = NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		loading = NO;
	}
	
	return self;
}

- (void)dealloc {
	self.postData = nil;
    self.pathAndQuery = nil;
    self.method = nil;
	self.reader = nil;
    
	[super dealloc];
}

@end
