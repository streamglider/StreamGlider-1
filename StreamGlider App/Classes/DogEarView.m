//
//  DogEarView.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 29/12/2010.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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

#import "DogEarView.h"
#import "SettingsController.h"
#import "SmallFrameViewController.h"

@implementation DogEarView

@synthesize viewed, isNew, viewController;

#pragma mark SettingsDelegate

- (void)attachSettingsDelegate {
	[[SettingsController sharedInstance] addDelegate:self forProperty:SettingsPropertyTypeNewIndicatorColor];
	[[SettingsController sharedInstance] addDelegate:self forProperty:SettingsPropertyTypeGrayOutViewedFrames];
}

- (void)detachSettingsDelegate {
	[[SettingsController sharedInstance] removeDelegate:self property:SettingsPropertyTypeNewIndicatorColor];
	[[SettingsController sharedInstance] removeDelegate:self property:SettingsPropertyTypeGrayOutViewedFrames];
}

- (void)propertyChanged:(SettingsPropertyType)propertyName oldValue:(NSObject *)oldValue newValue:(NSObject *)newValue {
	if (propertyName == SettingsPropertyTypeGrayOutViewedFrames) {
		if ([SettingsController sharedInstance].grayOutViewedFrames || !viewed) {
			self.backgroundColor = [UIColor clearColor];
		} else {
			UIImage *img = [UIImage imageNamed:@"Background_Pattern_100x100.png"];
			self.backgroundColor = [UIColor colorWithPatternImage:img];			
		}

		if (viewed && [SettingsController sharedInstance].grayOutViewedFrames) {
			[viewController grayOut];
		} else {
			[viewController cancelGrayOut];
		}

	}
	[self setNeedsDisplay];
}

#pragma mark Properties

- (void)setViewed:(BOOL)v {
	if (viewed != v) {
		viewed = v;
		if (viewed && ![SettingsController sharedInstance].grayOutViewedFrames) {
			UIImage *img = [UIImage imageNamed:@"Background_Pattern_100x100.png"];
			self.backgroundColor = [UIColor colorWithPatternImage:img];
		} else if ([SettingsController sharedInstance].grayOutViewedFrames) {
			[viewController grayOut];
		}				
		
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
    // Drawing code.
	CGMutablePathRef path = CGPathCreateMutable();
	
	float h = self.frame.size.height;
	float w = self.frame.size.width;
		
	UIColor *color = [UIColor colorWithRed:0.502 green:0.588 blue:0.698 alpha:1];

	BOOL drawingIsNeeded = YES;
	if (!viewed) {	
		if (isNew) {
			color = [[SettingsController sharedInstance].niColors objectAtIndex:
					 [SettingsController sharedInstance].niCurrentColor];
			
			CGPathMoveToPoint(path, NULL, 0, h);
			CGPathAddLineToPoint(path, NULL, w, 0);
			CGPathAddLineToPoint(path, NULL, w, h);
			CGPathAddLineToPoint(path, NULL, 0, h);
		} else {
			drawingIsNeeded = NO;
		}
	} else {
		if ([SettingsController sharedInstance].grayOutViewedFrames) {
			drawingIsNeeded = NO;
		} else {			
			CGPathMoveToPoint(path, NULL, 0, 0);
			CGPathAddLineToPoint(path, NULL, w, 0);
			CGPathAddLineToPoint(path, NULL, 0, h);
			CGPathAddLineToPoint(path, NULL, 0, 0);					
		}
	}
	
	if (drawingIsNeeded) {
		CGPathCloseSubpath(path);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		CGContextSetFillColorWithColor(ctx, color.CGColor);
		CGContextAddPath(ctx, path);
		CGContextFillPath(ctx);	
	}
	
	CGPathRelease(path);
}

@end
