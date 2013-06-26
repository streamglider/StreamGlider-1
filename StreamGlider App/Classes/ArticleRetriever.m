//
//  ArticleRetriever.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 26/12/2011.
//  Copyright (c) 2011 StreamGlider, Inc. All rights reserved.
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

#import "ArticleRetriever.h"
#import "Feed.h"
#import "RSSFrame.h"
#import "RSSFeed.h"
#import "HTMLParser.h"
#import "SEMArticleExtractor.h"
#import "FeedSource.h"
#import "CacheController.h"
#import "Stream.h"

@implementation ArticleRetriever

@synthesize target, action, stopRetrieval;

- (NSString *)removeScriptTags:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while (![theScanner isAtEnd]) {
		
        // find start of tag
        [theScanner scanUpToString:@"<script" intoString:NULL]; 
		
        // find end of tag
        [theScanner scanUpToString:@"</script>" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@</script>", text]
											   withString:@""];
		
    } // while //
	
    return html;
}

- (void)getArticleBody:(RSSFrame*)f {    
    
    RSSFeed *rf = (RSSFeed*)f.feed;
    NSData *data = [[CacheController sharedInstance] getResourceData:f.articleBodyURL];
    
    [[CacheController sharedInstance] releaseResourceData:f.articleBodyURL];
    
    NSString *s = [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding];
    
    BOOL retrievedOk = NO;
    
    if ([rf.source.URLString rangeOfString:@"feeds.wired.com"].location != NSNotFound) {
                
        NSError *error;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:s error:&error];
        
        HTMLNode *node = [parser.doc findChildOfClass:@"entry"];
        
        NSString *content = nil;
        
        if (!node) {
            node = [parser.doc findChildOfClass:@"body"];
        }
        if (!node) {
            node = [parser.doc findChildOfClass:@"post"];
        }
        if (node) {
            content = [node rawContents];
        }
        
        if (content != nil && content.length > 0) {
            content = [self removeScriptTags:content];
            f.articleBodyURL = [[CacheController sharedInstance] storeResourceData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            retrievedOk = YES;
        }
        
        [parser release]; 
    } else if ([rf.source.URLString rangeOfString:@"dailydot.com"].location != NSNotFound) {
                
        NSError *error;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:s error:&error];
        
        HTMLNode *node = [parser.doc findChildOfClass:@"article"];
        
        NSString *content = nil;
        
        if (!node) {
            node = [parser.doc findChildOfClass:@"main"];
        }
        if (!node) {
            node = [parser.doc findChildOfClass:@"content"];
        }
        
        if (node) {
            content = [node rawContents];
            DebugLog(@"Content: %@", content);
        }
        
        if (content != nil && content.length > 0) {
            content = [self removeScriptTags:content];
            f.articleBodyURL = [[CacheController sharedInstance] storeResourceData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            retrievedOk = YES;
        }
        
        [parser release]; 
        
    } else if ([rf.source.URLString rangeOfString:@"cnn.com"].location != NSNotFound) {
        NSError *error;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:s error:&error];
        
        HTMLNode *node = [parser.doc findChildOfClass:@"cnn_strycntntlft"];
        
        NSString *content = nil;
        
        if (!node) {
            node = [parser.doc findChildOfClass:@"cnnBlogContentPost"];
        }
                
        if (node) {
            content = [node rawContents];
        }
        
        if (content != nil && content.length > 0) {
            content = [self removeScriptTags:content];
            f.articleBodyURL = [[CacheController sharedInstance] storeResourceData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            retrievedOk = YES;
        }
        
        [parser release]; 
        
    } 
    
    if (!retrievedOk) {    
        NSString *content = nil;
        content = [SEMArticleExtractor extractArticleAsString:[rf flattenHTML:f.frameDescription] htmlString:s];
        
        if (content != nil && content.length > 0) {
            content = [self removeScriptTags:content];
            f.articleBodyURL = [[CacheController sharedInstance] storeResourceData:[content dataUsingEncoding:NSUTF8StringEncoding]];            
            retrievedOk = YES;
        }
    }
    
    if (!retrievedOk) {
        f.articleBodyURL = NO;
    }
        
    [s release];
}

- (void)retrieveArticlesForStream:(Stream*)stream {
	
    [target retain];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];                        
    
    BOOL goOn = YES;
    int index = 0;
    while (goOn) {
        
        if (stopRetrieval)
            break;
        
        goOn = NO;
        
        for (Feed *feed in stream.feeds) {
            if (stopRetrieval)
                break;
            
            if ([feed isMemberOfClass:[RSSFeed class]]) {
                if ([feed.queue count] > index) {
                    goOn = YES;
                    RSSFrame *f = [feed.queue objectAtIndex:index];
                    
                    if (f.frameIsReady && !f.articleRetrieved) {
                        
                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];                        
                        [self getArticleBody:f];
                        [pool drain];
                        
                        f.articleRetrieved = YES;
                                                
                        [target performSelectorOnMainThread:action withObject:f waitUntilDone:NO];
                    }
                }
            }
        }
        
        index++;
    }
    
    [pool drain];
    
    [target release];    
}

- (id)init {
    if (self = [super init]) {
        self.stopRetrieval = NO;
    }
    
    return self;
}

@end
