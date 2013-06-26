//
//  SEMArticleExtractor.h
//  Article Retriever
//
//  Created by Gavin McKenzie on 11-12-03.
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

#import <Foundation/Foundation.h>

@class HTMLParser;
@class HTMLNode;

@interface SEMArticleExtractor : NSObject

@property (nonatomic, retain) HTMLParser *htmlParser;
@property (nonatomic, retain) NSData *htmlData;

- (id)initWithHTMLData:(NSData *)htmlContent error:(NSError **)error;
- (id)initWithHTMLString:(NSString *)htmlString error:(NSError **)error;
- (id)initWithContentsOfURL:(NSURL*)url error:(NSError**)error;

- (HTMLNode *)findTextNodeContainingString:(NSString *)searchString;
- (NSArray *)findNodesContainingStrings:(NSArray *)searchStrings;
- (HTMLNode *)nodeContainingString:(NSString *)searchString withinTag:(NSString *)tagName;
- (NSArray *)extractSearchTermsFromString:(NSString *)content minimumTermLength:(NSUInteger)length limitTerms:(NSUInteger)limit;

+ (NSString *)extractArticleAsString:(NSString*)description htmlString:(NSString*)htmlString;

@end
