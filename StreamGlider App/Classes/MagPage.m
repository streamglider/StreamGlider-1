//
//  MagPage.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 31/10/2011.
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

#import "MagPage.h"
#import "MagPageLayout.h"
#import "MagArticle.h"
#import "Feed.h"
#import "Stream.h"
#import "FeedSource.h"
#import "Frame.h"
#import "FrameIterator.h"
#import "FBFeed.h"

@implementation MagPage

@synthesize articles, layout, stream, iterator, emptyPage;

#pragma mark Articles

- (void)layoutArticlesForOrientation:(UIInterfaceOrientation)orientation {
    int index = 0;
    for (MagArticle *art in articles) {
        art.frame = [layout positionForArticle:index orientation:orientation];
        index++;
    }
}

- (void)prepareArticlesForOrientation:(UIInterfaceOrientation)orientation {
    int count = layout.spacesCount;
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:count];

    for (int i = 0; i < count; i++) {
        MagArticle *art = [[MagArticle alloc] init];
        [arr addObject:art];
        [art release];
        
        art.contentFrame = [iterator nextFrame];
        
        if (art.contentFrame == nil) {
            continue;
        }
        
        self.emptyPage = NO;
        
        if (art.contentFrame.feed.source.type == FeedSourceTypeTwitter) 
            art.framesList = [iterator framesList:art.contentFrame];
        else if (art.contentFrame.feed.source.type == FeedSourceTypeFacebook) {
            FBFeed *fbf = (FBFeed*)art.contentFrame.feed;
            if (!fbf.photosFeed)
                art.framesList = [iterator framesList:art.contentFrame];
        }
    }
        
    self.articles = [[arr copy] autorelease];
    [arr release];    
    
    if (!emptyPage)
        [self layoutArticlesForOrientation:orientation];    
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.emptyPage = YES;
    }
    
    return self;
}

- (void)dealloc {
    self.articles = nil;
    self.layout = nil;
    
    [super dealloc];
}

@end
