//
//  OAuthCore.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 03/08/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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

#import <Security/Security.h>
#import "OAuthCore.h"
#import "OAuth.h"
#import "OAuth2.h"
#import "AuthorizeViewController.h"
#import "AuthFlickr.h"
#import "StreamCastViewController.h"

@interface OAuthCore ()

@property BOOL requestingAuth;

@end

@implementation OAuthCore {
    NSDictionary *realms;
    BOOL requestingAuth;
    id<OAuthProtocol> requestingAuthForRealm;
    id<OAuthDelegate> delegate;    
}

@synthesize authorizeViewController, requestingAuth, viewController, streamCastViewController;

static OAuthCore *sharedInstance = nil; 

#pragma mark Singleton

+ (OAuthCore*)sharedInstance {
	if (sharedInstance == nil) {
		sharedInstance = [[OAuthCore alloc] init];
	}
	
	return sharedInstance;		
}

#pragma mark Utility Methods

- (NSString*)realmNameForObject:(id<OAuthProtocol>)oa {
    NSObject *obj = (NSObject*)oa;
    if ([obj isMemberOfClass:[OAuth class]]) {
        return @"Twitter";
    } else if ([obj isMemberOfClass:[OAuth2 class]]) {
        OAuth2 *oa2 = (OAuth2*)oa;
        if ([oa2.realm isEqualToString:FACEBOOK_REALM]) {
            return @"Facebook";
        } else {
            return @"YouTube";
        }
    } else {
        return @"Flickr";
    }
}

- (void)doRequestInBackground:(id<OAuthProtocol>)oa {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    [oa getRequestToken];
	
	while (self.requestingAuth) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool drain];
}

- (void)clearTokenForRealm:(NSString*)realm {
    if ([realm isEqualToString:TWITTER_REALM]) {
        [OAuthCore deleteKeychainValueForKey:@"twitter-token"];
        [OAuthCore deleteKeychainValueForKey:@"twitter-secret"];
        OAuth *twitter = (OAuth*)[self getOAuthForRealm:TWITTER_REALM];
        
        twitter.token = nil;
        twitter.tokenSecret = nil;        
    } else if ([realm isEqualToString:FACEBOOK_REALM]) {
        [OAuthCore deleteKeychainValueForKey:@"fb-access-token"];
        OAuth2 *fb = (OAuth2*)[self getOAuthForRealm:FACEBOOK_REALM];
        fb.accessToken = nil;        
    } else if ([realm isEqualToString:YOUTUBE_REALM]) {
        [OAuthCore deleteKeychainValueForKey:@"yt-access-token"];
        [OAuthCore deleteKeychainValueForKey:@"yt-refresh-token"];
        OAuth2 *yt = (OAuth2*)[self getOAuthForRealm:YOUTUBE_REALM];    
        yt.accessToken = nil;
        yt.refreshToken = nil;        
    } else if ([realm isEqualToString:FLICKR_REALM]) {
        [OAuthCore deleteKeychainValueForKey:@"flickr-auth-token"];
        AuthFlickr *flickr = (AuthFlickr*)[self getOAuthForRealm:FLICKR_REALM];
        flickr.authToken = nil;        
    } 
}

- (void)clearAllTokens {
    
    for (NSString *realm in realms.allKeys) {
        [self clearTokenForRealm:realm];
    }
    
    // Google Reader
	[OAuthCore deleteKeychainValueForKey:@"google-reader-login"];
	[OAuthCore deleteKeychainValueForKey:@"google-reader-password"];
}


#pragma mark Keychain

+ (NSString*)getValueFromKeyChainFor:(NSString*)key {
	NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
	
	// security class
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	// item id
	NSData *itemID = [key dataUsingEncoding:NSUTF8StringEncoding];
	[query setObject:itemID forKey:(id)kSecAttrAccount];
	
	// return first match only
	[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	
	// return value, we only need data
	[query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	NSData *outData = nil;
	
	OSStatus keychainErr = SecItemCopyMatching((CFDictionaryRef)query, 
											   (CFTypeRef*)&outData);
	
	[query release];
	
	[outData autorelease];
	
	if (keychainErr == noErr) {
		// get result
		NSString *ret = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
		return [ret autorelease];
	}
		
	return nil;
}

+ (void)storeKeychainValue:(NSString*)value forKey:(NSString*)key {
    
    // delete keychain value in case it's there already
    [OAuthCore deleteKeychainValueForKey:key];
    
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	// set security class
	[dict setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	// set key
	NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
	[dict setObject:data forKey:(id)kSecAttrAccount];
	
	// set value
	data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[dict setObject:data forKey:(id)kSecValueData];
	
	OSStatus result = SecItemAdd((CFDictionaryRef)dict, NULL);
	
	if (result == noErr)
		DebugLog(@"write successfull");
	[dict release];
}

+ (void)deleteKeychainValueForKey:(NSString*)key {
	NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
	
	// security class
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	// item id
	NSData *itemID = [key dataUsingEncoding:NSUTF8StringEncoding];
	[query setObject:itemID forKey:(id)kSecAttrAccount];
	
	OSStatus err = SecItemDelete((CFDictionaryRef)query);
	
	if (err == noErr)
		DebugLog(@"delete successful");
	
	[query release];
}

#pragma mark OAuthDelegate

- (void)exchangeWasFinished:(id<OAuthProtocol>)oauth {
	self.requestingAuth = NO;
    [delegate exchangeWasFinished:oauth];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [requestingAuthForRealm getRequestToken];
    } else {
        self.requestingAuth = NO;
        [delegate exchangeWasFinished:requestingAuthForRealm];        
    }
}

#pragma mark OAuthCore Interface

// this method should ALWAYS be called on the main thread!
- (id<OAuthProtocol>)getOAuthForRealm:(NSString*)realm {
	return [realms objectForKey:realm];
}

// this method should ALWAYS be called on the main thread!
- (void)requestAuthForRealm:(NSString*)realm withDelegate:(id<OAuthDelegate>)aDelegate viewController:(UIViewController*)vc askUser:(BOOL)askUser reason:(NSString*)reason {
    
	self.viewController = vc;
	
	// use streamcast view controller by default
	if (viewController == nil)
		self.viewController = streamCastViewController;
    
    if (self.viewController.presentedViewController)
        return;
	
	id<OAuthProtocol> oa = [realms objectForKey:realm];
	NSObject *authObject = (NSObject*)oa;
	
	if (self.requestingAuth) {
        if (!askUser) {
            NSString *s = [NSString stringWithFormat:@"The app is currently authorizing %@, please try later.", [self realmNameForObject:requestingAuthForRealm]];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Authorize Account" 
                                                         message:s
                                                        delegate:nil 
                                               cancelButtonTitle:@"Close" 
                                               otherButtonTitles:nil];
            [av show];
            [av release];  
        }
        
		return;
	}
	
	@synchronized(oa) {
        
		self.requestingAuth = YES;
        
        requestingAuthForRealm = oa;
        
        // clear token for the realm
        if ([realm isEqualToString:YOUTUBE_REALM]) {
            OAuth2 *yt = (OAuth2*)oa;
            if (yt.refreshToken != nil) {
                [yt getRequestToken];
                return;
            }
        } else {
            [self clearTokenForRealm:realm];
        }
        
		[authObject performSelector:@selector(setDelegate:) withObject:self];
        delegate = aDelegate;
        
        if (!askUser) {
            [oa getRequestToken];
        } else {
            NSString *msg = nil;
            
            if ([realm isEqualToString:TWITTER_REALM]) {
                msg = [NSString stringWithFormat:@"%@ Do you want to authorize Twitter?", reason];
            } else if ([realm isEqualToString:FACEBOOK_REALM]) {
                msg = [NSString stringWithFormat:@"%@ Do you want to authorize Facebook?", reason];
            } else if ([realm isEqualToString:YOUTUBE_REALM]) {
                msg = [NSString stringWithFormat:@"%@ Do you want to authorize YouTube?", reason];
            } else if ([realm isEqualToString:FLICKR_REALM]) {
                msg = [NSString stringWithFormat:@"%@ Do you want to authorize Flickr?", reason];
            }
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Authorize Account" 
                                                         message:msg
                                                        delegate:self 
                                               cancelButtonTitle:@"No" 
                                               otherButtonTitles:@"Yes", nil];
            [av show];
            [av release];            
        }
        		
		return;
	}
}

// this method should ALWAYS be called on the main thread!
- (void)requestAuthForRealm:(NSString*)realm withDelegate:(id<OAuthDelegate>)aDelegate viewController:(UIViewController*)vc {
    [self requestAuthForRealm:realm withDelegate:aDelegate viewController:vc askUser:NO reason:nil];
}									

#pragma mark Lifecycle

-(id)init {
	DebugLog(@"initializing OAuth...");
	
	if (self = [super init]) {
		// create and initialize OAuth object for realms
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
		
		self.requestingAuth = NO;
		
		// create twitter OAuth
		OAuth *twitter = [[OAuth alloc] init];
		
		twitter.realm = TWITTER_REALM;
		twitter.callback = @"http://streamcast.com/request_token_ready";
		twitter.version = @"1.0";
		
		twitter.consumerKey = TWITTER_CONSUMER_KEY;
		twitter.consumerSecret = TWITTER_CONSUMER_SECRET;
		twitter.signatureMethod = @"HMAC-SHA1";
		
		twitter.requestTokenUrl = @"https://api.twitter.com/oauth/request_token";
		twitter.accessTokenUrl = @"https://api.twitter.com/oauth/access_token";
		twitter.authorizeUrl = @"https://api.twitter.com/oauth/authorize";
		
		twitter.token = [OAuthCore getValueFromKeyChainFor:@"twitter-token"];
		twitter.tokenSecret = [OAuthCore getValueFromKeyChainFor:@"twitter-secret"];
		
		[dic setObject:twitter forKey:TWITTER_REALM];
		
		[twitter release];
		//
		
		// create FB OAuth2
		OAuth2 *fb = [[OAuth2 alloc] init];
		fb.realm = FACEBOOK_REALM;
		fb.clientID = FACEBOOK_CLIENT_ID;
		fb.clientSecret = FACEBOOK_CLIENT_SECRET;
        
		fb.redirectURI = [NSString stringWithFormat:@"%@/oauth_redirect", SITE_URL];
		fb.accessToken = [OAuthCore getValueFromKeyChainFor:@"fb-access-token"];
		
		fb.accessTokenUri = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=offline_access,publish_stream,user_photos,user_photo_video_tags,read_stream&display=popup",
							 fb.clientID, fb.redirectURI];		
		fb.authorizationTokenUri = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/access_token?client_id=%@&redirect_uri=%@&client_secret=%@&code=",
									fb.clientID, fb.redirectURI, fb.clientSecret];
		
		[dic setObject:fb forKey:FACEBOOK_REALM];
		[fb release];
		
		// create YT OAuth2
		OAuth2 *yt = [[OAuth2 alloc] init];
		yt.realm = YOUTUBE_REALM;
		yt.clientID = YOUTUBE_CLIENT_ID;
		yt.clientSecret = YOUTUBE_CLIENT_SECRET;
		yt.redirectURI = [NSString stringWithFormat:@"%@/oauth2callback", SITE_URL];
		
		yt.accessToken = [OAuthCore getValueFromKeyChainFor:@"yt-access-token"];
		yt.refreshToken = [OAuthCore getValueFromKeyChainFor:@"yt-refresh-token"];
		
		yt.accessTokenUri = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?client_id=%@&redirect_uri=%@&scope=https://gdata.youtube.com&response_type=code&access_type=offline&approval_prompt=force", yt.clientID, yt.redirectURI];	
        
		yt.authorizationTokenUri = @"https://accounts.google.com/o/oauth2/token";
		
		[dic setObject:yt forKey:YOUTUBE_REALM];
		[yt release];
		
		//flickr auth
		AuthFlickr *flickr = [[AuthFlickr alloc] init];
		flickr.apiKey = FLICKR_API_KEY;
		flickr.apiSecret = FLICKR_API_SECRET;
		
		//		flickr.apiKey = @"61208e16292ff3bc2783b17f3032cc7f";
		//		flickr.apiSecret = @"6b07365f33fa3cba";
		flickr.loginURL = @"http://flickr.com/services/auth/?api_key=";
		flickr.authToken = [OAuthCore getValueFromKeyChainFor:@"flickr-auth-token"];
		[dic setObject:flickr forKey:FLICKR_REALM];
		
		[flickr release];
		
		realms = [NSDictionary dictionaryWithDictionary:dic];
		[realms retain];
		
		[dic release];
		
		// create auth view controller
		self.authorizeViewController = [[[AuthorizeViewController alloc] 
										initWithNibName:@"AuthorizeViewController" bundle:nil] autorelease];
		authorizeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	
	return self;		
}

- (void)dealloc {
	self.authorizeViewController = nil;
	[super dealloc];
}

@end
