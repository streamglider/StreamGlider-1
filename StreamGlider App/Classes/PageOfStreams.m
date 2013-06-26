//
//  PageOfStreams.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 25/10/2011.
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
