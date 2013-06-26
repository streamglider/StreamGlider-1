//
//  HighlightedTextView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 14/01/2011.
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

#import <CoreText/CoreText.h>
#import "HighlightedTextView.h"


@implementation HighlightedTextView

@synthesize text, highlightColor, color, fontSize, fontName, insets, logoImage, oneLiner;

#pragma mark Properties

- (void)setHighlightColor:(UIColor*)c {
	if (highlightColor != c) {
		[highlightColor release];
		highlightColor = c;
		[c retain];
		
		[self setNeedsDisplay];
	}
}

- (void)setFontSize:(int)newSize {
	fontSize = newSize;
	[self setNeedsDisplay];
}

- (void)setText:(NSString*)newText {
	if (![text isEqualToString:newText]) {
		[text release];
		text = [newText copy];
		[self setNeedsDisplay];
	}
}

#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (CGFloat)getLineHeightForFont:(CTFontRef)font {
	CGFloat ascent = CTFontGetAscent(font);
	CGFloat descent = CTFontGetDescent(font);
	CGFloat leading = CTFontGetLeading(font);
	
	return ascent + descent + leading;
}

- (CGFloat)drawLine:(NSMutableString*)txt atShift:(CGFloat)yShift withLogo:(BOOL)drawLogo lastLine:(BOOL)lastLine inContext:(CGContextRef)context firstLine:(BOOL)firstLine {	
	
	// Initialize an attributed string.
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)txt);
	
	// Create a color and add it as an attribute to the string.
	CFRange rng = CFRangeMake(0, [txt length]);	
	CFAttributedStringSetAttribute(attrString, rng,
								   kCTForegroundColorAttributeName, color.CGColor);
	// Create font ref and add it
	CTFontRef font = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
	
	CFAttributedStringSetAttribute(attrString, rng,
								   kCTFontAttributeName, font);
	
	// set line breaking to word boundaries
	if (lastLine || oneLiner) {
		CTLineBreakMode mode = kCTLineBreakByWordWrapping;		
		CTParagraphStyleSetting theSettings[1] = {
			{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &mode }
		};	
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, 1);	
		CFAttributedStringSetAttribute(attrString, rng, kCTParagraphStyleAttributeName, paragraphStyle);
		CFRelease(paragraphStyle);
	} 
	
	// Create the typesetter with the attributed string.
	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString(attrString);	
	
	CGFloat aWidth = self.frame.size.width - insets.left - insets.right;
	CGFloat xPos = insets.left;
	
	CGFloat lineHeight = [self getLineHeightForFont:font];
	
	if (drawLogo) {		
		// position and scale logo image
		CGSize sz = CGSizeMake(0, lineHeight + insets.top);
		if (lastLine || oneLiner)
			sz.height += insets.bottom;
		
		sz.width = sz.height * (4.0 / 3.0);
		CGRect logoRect = logoImage.frame;
		logoRect.size = sz;
		logoRect.origin.x = self.frame.origin.x;
		logoRect.origin.y = self.frame.origin.y;
		
		logoImage.frame = logoRect;
		
		// decrease width of the text rect by the width of the logo image
		xPos = floor(sz.width + insets.left / 4);
				
		aWidth -= logoRect.size.width;				
	} 
	
	CFIndex count;
	CTLineRef line;
	if (oneLiner || lastLine) {
		CTLineRef origLine = CTTypesetterCreateLine(typesetter, CFRangeMake(0, 0));

		CFAttributedStringRef truncationString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), 
																		  CFAttributedStringGetAttributes(attrString, 
																										  0, NULL));
		CTLineRef truncationToken = CTLineCreateWithAttributedString(truncationString);
		CFRelease(truncationString); 
						
		line = CTLineCreateTruncatedLine(origLine, aWidth, kCTLineTruncationEnd, truncationToken);		
		CFRelease(truncationToken);
		
		if (line == NULL) {
			line = origLine;
		} else {
			CFRelease(origLine);
		}
		
	} else {
		count = CTTypesetterSuggestLineBreak(typesetter, 0, aWidth);
		line = CTTypesetterCreateLine(typesetter, CFRangeMake(0, count));
	}
	
	// get line width
	CGFloat lineWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL) + insets.left + insets.right;
	
	CGFloat shapeHeight, shapeYPos;
	
	shapeHeight = lineHeight;
	shapeYPos = yShift - lineHeight;
	if (firstLine) {
		shapeHeight += insets.top;
	}
	
	if (lastLine || oneLiner) {
		shapeHeight += insets.bottom;
		shapeYPos -= insets.bottom;			
	}
	
	// draw background if needed
	if (highlightColor != nil) {
		
		CGMutablePathRef shapePath = CGPathCreateMutable();
					
		CGPathAddRect(shapePath, NULL, CGRectMake(xPos - insets.left, shapeYPos, lineWidth, shapeHeight));
		
		CGContextSetFillColorWithColor(context, highlightColor.CGColor);
		CGContextAddPath(context, shapePath);
		CGContextFillPath(context);	
		
		CGPathRelease(shapePath);		
	}
	
	// draw line
	CGContextSetTextPosition(context, xPos, shapeYPos + shapeHeight / 2 - lineHeight / 4);	
	CTLineDraw(line, context);
	
	if (!lastLine && !oneLiner) {
		// remove drawed text
		[txt deleteCharactersInRange:NSMakeRange(0, count)];
	}
	
	// release created objects
	CFRelease(attrString);
	CFRelease(font);
	CFRelease(typesetter);
	CFRelease(line);
	
	return lineHeight;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	if (text == nil || [text length] == 0)
		return;
	
	CGFloat yPos = self.frame.size.height - insets.top;
	
	CGFloat lineHeight;
	NSMutableString *txt = [text mutableCopy];
	BOOL lastLine = oneLiner;
	BOOL drawLogo = logoImage != nil;
	BOOL firstLine = YES;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	CGContextTranslateCTM(context, 0.0f, self.frame.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
		
	while (YES) {
		lineHeight = [self drawLine:txt atShift:yPos withLogo:drawLogo lastLine:lastLine inContext:context firstLine:firstLine];
		yPos -= lineHeight;
		firstLine = NO;
		drawLogo = NO;
		
		if (lastLine)
			break;
		
		if ([txt length] == 0)
			break;
				
		if (yPos < lineHeight)
			break;
		
		if (yPos < lineHeight * 2)
			lastLine = YES;
	}
    
    [txt release];
}

#pragma mark Lifecycle

- (void)dealloc {
	self.text = nil;
	self.highlightColor = nil;
	self.fontName = nil;
	self.color = nil;
    [super dealloc];
}


@end
