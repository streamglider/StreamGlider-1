//
//  AutoLoader.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 20/09/2011.
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

#import "AutoLoader.h"
#import "OAuthProtocol.h"
#import "OAuthCore.h"
#import "Stream.h"
#import "TwitterFeed.h"
#import "FeedSourceCategory.h"
#import "FlickrFeed.h"
#import "FBFeed.h"
#import "RSSFeed.h"
#import "OAuth2.h"
#import "JSON.h"
#import "FeedSource.h"
#import "YTFeed.h"
#import "Core.h"

@implementation AutoLoader

#pragma mark Utility Methods

+ (FeedSourceCategory*)findGoogleReaderCategory {
    for (FeedSourceCategory *cat in [Core sharedInstance].rootCategory.children) {
        if ([cat.title isEqualToString:@"My Feeds"]) {
            for (FeedSourceCategory *cat1 in cat.children) {
                if ([cat1.title isEqualToString:@"Google Reader"]) {
                    return cat1;
                }
            }
        }
    }
    return nil;
}

#pragma mark Preloading

static NSString *UserURL = @"https://graph.facebook.com/";
static NSString *AlbumURL = @"https://graph.facebook.com/me/albums?fields=id,name,count&limit=100";

+ (NSArray*)loadUserAlbums {
	
	OAuth2 *oauth = (OAuth2*)[[OAuthCore sharedInstance] getOAuthForRealm:FACEBOOK_REALM];
	
	NSString *normalizedAccessToken = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, 
																						  (CFStringRef)oauth.accessToken, 
																						  NULL, 
																						  (CFStringRef)@"￼|", 
																						  kCFStringEncodingUTF8);
	NSMutableString *urlString = [[NSMutableString alloc] initWithString:AlbumURL];
	
	if (normalizedAccessToken != nil) {
		[urlString appendFormat:@"&access_token=%@", normalizedAccessToken];
        [normalizedAccessToken release];
    }
	
	DebugLog(@"loading FB albums, full url: %@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	[urlString release];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];	
	
	NSURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
	
	NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	// read JSON data		
	NSDictionary *dic = [receivedString JSONValue];
	
    NSArray *arr = nil;
    if (dic != nil) {
        arr = [dic objectForKey:@"data"];
    }   
    
    [receivedString release];
    
	return arr;
}

+ (Stream*)addStreamWithTitle:(NSString*)t {
	Stream *s = [[Stream alloc] init];
	s.title = t;
	[[Core sharedInstance] addStream:s skipStoring:NO];	
	[s release];	
	
	int from = [[Core sharedInstance].streams indexOfObject:s];
	[[Core sharedInstance] moveStream:s fromIndex:from toIndex:0];	
	
	return s;
}

+ (void)addFBFeedWithSource:(FeedSource*)src stream:(Stream*)stream {
	FBFeed *f = [[FBFeed alloc] init];	
	f.source = src;
	f.stream = stream;
	
	[stream addFeed:f];		
	[f release];
}


+ (void)addStreamsForRealm:(NSString*)realm {
	
	int removeCount = 0;
    
	id<OAuthProtocol> oa;
    if ([realm isEqualToString:TWITTER_REALM]) {
        oa = [[OAuthCore sharedInstance] getOAuthForRealm:TWITTER_REALM];
        if ([oa authenticated]) {
            
            removeCount++;
            
            // create a stream with "my twitter" frame
            Stream *s = [self addStreamWithTitle:@"Twitter"];
            
            TwitterFeed *f = [[TwitterFeed alloc] init];
            
            // construct feed source
            f.source = [[[FeedSource alloc] init] autorelease];
            f.source.URLString = @"http://api.twitter.com/1/statuses/home_timeline.atom";
            f.source.title = @"Home Timeline";
            f.source.type = FeedSourceTypeTwitter;
            
            f.stream = s;
            
            [s addFeed:f];		
            
            [f release];
            
            [s loadNewFrames];
        }
    } else if ([realm isEqualToString:FACEBOOK_REALM]) {	
        oa = [[OAuthCore sharedInstance] getOAuthForRealm:FACEBOOK_REALM];
        if ([oa authenticated]) {
            
            removeCount++;
            
            Stream *s = [self addStreamWithTitle:@"Facebook"];
            
            FeedSource *src = [[FeedSource alloc] init];
            src.URLString = @"https://graph.facebook.com/me/home?";
            src.title = @"My News Feed";
            src.type = FeedSourceTypeFacebook;
            
            [self addFBFeedWithSource:src stream:s];
            [src release];
                        
            src = [[FeedSource alloc] init];
            src.URLString = @"https://graph.facebook.com/me/feed?";
            src.title = @"My Profile Feed";
            src.type = FeedSourceTypeFacebook;
            [self addFBFeedWithSource:src stream:s];
            [src release];
            
            // add user albums
            NSArray *albums = [self loadUserAlbums];
            if (albums != nil) {
                int max = MIN(10, [albums count]);
                for (int i = 0; i < max; i++) {
                    NSDictionary *entry = [albums objectAtIndex:i];
                    FeedSource *fs = [[FeedSource alloc] init];
                    fs.URLString = [NSString stringWithFormat:@"%@%@?fields=photos&", 
                                    UserURL, [entry objectForKey:@"id"]];
                    fs.title = [entry objectForKey:@"name"];
                    fs.type = FeedSourceTypeFacebook;
                    
                    [self addFBFeedWithSource:fs stream:s];
                    
                    [fs release];
                }	
            }
            
            [s loadNewFrames];        
        }
    } else if ([realm isEqualToString:FLICKR_REALM]) {	
        oa = [[OAuthCore sharedInstance] getOAuthForRealm:FLICKR_REALM];
        if ([oa authenticated]) {	
            
            removeCount++;
            
            // create a stream with "my FB" frame
            Stream *s = [self addStreamWithTitle:@"Flickr"];
            
            FlickrFeed *f = [[FlickrFeed alloc] init];
            
            f.source = [[[FeedSource alloc] init] autorelease];
            f.source.URLString = @"http://api.flickr.com/services/rest/?method=flickr.people.getPhotos&extras=date_upload,owner_name&user_id=me";
            f.source.title = @"My Photos";
            f.source.type = FeedSourceTypeFlickr;
            
            f.stream = s;
            
            [s addFeed:f];				
            [f release];
            
            [s loadNewFrames];
        }	
    } else if ([realm isEqualToString:YOUTUBE_REALM]) {	
        oa = [[OAuthCore sharedInstance] getOAuthForRealm:YOUTUBE_REALM];
        if ([oa authenticated]) {
            
            removeCount++;
            
            Stream *s = [self addStreamWithTitle:@"YouTube"];
            
            YTFeed *f = [[YTFeed alloc] init];
            
            f.source = [[[FeedSource alloc] init] autorelease];
            f.source.URLString = @"http://gdata.youtube.com/feeds/api/users/default/favorites?v=2";
            f.source.title = @"My Favorites";
            f.source.type = FeedSourceTypeYouTube;
            
            f.stream = s;
            
            [s addFeed:f];		
            
            [f release];
            
            [s loadNewFrames];
        }
    } else {
        // find Google Reader category
        
        FeedSourceCategory *gr = [self findGoogleReaderCategory];
        if (gr == nil)
            return;
        
        int i = 0;
        for (FeedSourceCategory *cat in gr.children) {
            if (i > 10)
                break;
            
            Stream *s = [self addStreamWithTitle:cat.title];
            
            removeCount++;
            
            int j = 0;
            for (FeedSource *fs in cat.children) {
                if (j > 10)
                    return;
                
                RSSFeed *f = [[RSSFeed alloc] init];
                
                f.source = fs;
                f.stream = s;
                
                [s addFeed:f];							
                [f release];
                
                j++;
            }
            
            i++;
            
            [s loadNewFrames];        
        }
    }
	    
    NSString *msg;
    if (removeCount != 0) {
        msg = [NSString stringWithFormat:@"Number of streams added: %d", removeCount]; 
    } else {
        msg = @"No streams were added";
    }
    
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Auto Loading" 
												 message:msg
												delegate:nil 
									   cancelButtonTitle:@"Close" 
									   otherButtonTitles:nil];
    [av show];
	[av release];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
