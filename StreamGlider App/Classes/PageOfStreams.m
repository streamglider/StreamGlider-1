//
//  PageOfStreams.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 25/10/2011.
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

#import "PageOfStreams.h"
#import "Loader.h"

@implementation PageOfStreams

@synthesize streams, title, activePage, delegates, magModeIndex;

#pragma mark Properties

- (void)setTitle:(NSString *)t {
    if (![title isEqualToString:t]) {
        title = [t copy];
        for (id<PageOfStreamsDelegate> d in delegates) {
            [d pageTitleWasChanged:self];
        }
        
        [[Loader sharedInstance] storeStreams];
    }
}

#pragma mark Delegates

- (void)addDelegate:(id<PageOfStreamsDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<PageOfStreamsDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
    
	self.title = [aDecoder decodeObjectForKey:@"title"];
	NSArray *fs = [aDecoder decodeObjectForKey:@"streams"];
    self.activePage = [aDecoder decodeBoolForKey:@"activePage"];
    
    self.streams = [[fs mutableCopy] autorelease];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:streams forKey:@"streams"];
    [aCoder encodeBool:activePage forKey:@"activePage"];
}

#pragma mark Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.streams = [[[NSMutableArray alloc] init] autorelease];
        self.delegates = [[[NSMutableSet alloc] init] autorelease];
        self.magModeIndex = 0;
    }
    
    return self;
}

- (void)dealloc {
    self.streams = nil;
    self.delegates = nil;
    
    [super dealloc];
}

@end
