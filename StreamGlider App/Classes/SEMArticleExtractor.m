//
//  SEMArticleExtractor.m
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

#import "SEMArticleExtractor.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@implementation SEMArticleExtractor

@synthesize htmlParser = htmlParser_;
@synthesize htmlData = htmlData_;

#pragma mark Utility Methods

- (BOOL)isEmpty:(NSObject*)obj {
    return obj == nil
	|| ([obj respondsToSelector:@selector(length)]
        && [obj performSelector:@selector(length)] == 0)
	|| ([obj respondsToSelector:@selector(count)]
        && [obj performSelector:@selector(count)] == 0);    
}

+ (NSString *)extractArticleAsString:(NSString*)description htmlString:(NSString*)htmlString
{
    NSString *extractedArticle = nil;

    NSString *itemSummary = description ? description : @"[No Summary]";
    
    NSError *error = nil;
    
    SEMArticleExtractor *extractor = [[SEMArticleExtractor alloc] initWithHTMLString:htmlString error:&error];
    
    NSArray *searchTerms = [extractor extractSearchTermsFromString:itemSummary minimumTermLength:5 limitTerms:5];
    
    NSArray *scoredNodes = [extractor findNodesContainingStrings:searchTerms];
    
    if (scoredNodes) {
        HTMLNode *node = [scoredNodes lastObject];
        HTMLNode *parent = nil;
        
        if ([node nodetype] == HTMLSpanNode) {
            parent = [node parentWithTagNameInSet:[NSArray arrayWithObjects:@"article", @"ARTICLE", @"p", @"P", nil]];
        } else {
            parent = [node parentWithTagNameInSet:[NSArray arrayWithObjects:@"article", @"ARTICLE", @"div", @"DIV", nil]];
        }
        
        if (parent) {
            extractedArticle = [parent rawContents];
        } else {
            extractedArticle = [node rawContents];
        }
    }
    
    [extractor release];
    
    return extractedArticle;
}

#pragma mark - Initializers

- (id)initWithHTMLData:(NSData *)htmlContent error:(NSError **)error
{
    self = [super init];
    if (self) {
        htmlData_ = htmlContent;
        htmlParser_ = [[HTMLParser alloc] initWithData:htmlData_ error:error];
    }
    return self;
}

- (id)initWithHTMLString:(NSString *)htmlString error:(NSError **)error
{
    self = [super init];
    if (self) {
        htmlParser_ = [[HTMLParser alloc] initWithString:htmlString error:error];
    }
    return self;
}

- (id)initWithContentsOfURL:(NSURL*)url error:(NSError**)error
{
    self = [super init];
    if (self) {
        htmlParser_ = [[HTMLParser alloc] initWithContentsOfURL:url error:error];
    }
    return self;   
}

#pragma mark - HTML Node Operations

- (BOOL)sameNode:(HTMLNode *)node asOtherNode:(HTMLNode *)otherNode 
{
    if (!node || !otherNode) 
        return NO;
    
    if ([node nodetype] != [otherNode nodetype]) 
        return NO;
    
    NSString *nodeContent = [node contents];
    NSString *otherContent = [otherNode contents];

    if ([self isEmpty:nodeContent] || [self isEmpty:otherContent])
        return NO;
    
    if ([nodeContent isEqualToString:otherContent])
        return YES;
    
    return NO;
}

- (HTMLNode *)nodeContainingString:(NSString *)searchString withinTag:(NSString *)tagName
{
    HTMLNode *resultNode = nil;
    NSArray *nodes = [self.htmlParser.doc findChildTags:tagName];
    if (!nodes)
        return nil;
    
    for (HTMLNode *node in nodes) {
        NSString *content = [node allContents];
        NSRange range = [content rangeOfString:searchString];
        if (range.location != NSNotFound) {
            resultNode = node;
            break;
        }
    }
    
    return resultNode;
}

- (HTMLNode *)findTextNodeContainingString:(NSString *)searchString
{    
    HTMLNode *resultNode = nil;
    HTMLNode *pNode = [self nodeContainingString:searchString withinTag:@"p"];
    HTMLNode *divNode = [self nodeContainingString:searchString withinTag:@"div"];

    if (![self isEmpty:[pNode contents]] && [[pNode contents] length] > [[divNode contents] length]) {
        resultNode = pNode;
    } else if (![self isEmpty:[divNode contents]] && [[divNode contents] length] > [[pNode contents] length]) {
        resultNode = divNode;
    }

    if (!resultNode) {
        HTMLNode *spanNode = [self nodeContainingString:searchString withinTag:@"span"];
        if (![self isEmpty:[spanNode contents]]) {
            resultNode = spanNode;
        }
    }
    
    return resultNode;
}

- (NSArray *)findNodesContainingStrings:(NSArray *)searchStrings
{
    NSArray *result = nil;
    NSMutableArray *scoreBoard = [[NSMutableArray alloc] initWithCapacity:[searchStrings count]];

    for (NSString *searchString in searchStrings) {
        HTMLNode *foundTextNode = [self findTextNodeContainingString:searchString];
        if (!foundTextNode || [self isEmpty:[foundTextNode contents]])
            continue;
        
        HTMLNode *scoredNode = nil;
                
        for (HTMLNode *tempNode in scoreBoard) {
            if ([self sameNode:tempNode asOtherNode:foundTextNode]) {
                scoredNode = tempNode;
                break;
            }
        }
        
        if (scoredNode) {
            scoredNode.score += 1;
        } else {
            scoredNode = foundTextNode;
            scoredNode.score = 1;
            [scoreBoard addObject:scoredNode];
        }
    }
    
    if ([scoreBoard count]) {
        result = [NSArray arrayWithArray:scoreBoard];
    }
    [scoreBoard release];
    
    if (result) {
        result = [result sortedArrayUsingSelector:@selector(scoreComparison:)];
    }
    
    return result;
}

- (NSArray *)extractSearchTermsFromString:(NSString *)content minimumTermLength:(NSUInteger)length limitTerms:(NSUInteger)limit;
{
    NSArray *resultArray = nil;
    NSMutableArray *termsArray = [[NSMutableArray alloc] initWithCapacity:limit];
    NSCharacterSet *stopComponents = [NSCharacterSet characterSetWithCharactersInString:@" ,.&+-"];
    NSArray *components = [content componentsSeparatedByCharactersInSet:stopComponents];
    
    for (NSString *component in components) {
        if (![self isEmpty:component] && [component length] >= length) {
            [termsArray addObject:component];
        }
    }
    
    if ([termsArray count]) {
        resultArray = [NSArray arrayWithArray:termsArray];
    }
    [termsArray release];
    
    return resultArray;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [htmlParser_ release], htmlParser_ = nil;
    [htmlData_ release], htmlData_ = nil;
    [super dealloc];
}

@end
