//
//  SEMArticleExtractor.h
//  Article Retriever
//
//  Created by Gavin McKenzie on 11-12-03.
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
