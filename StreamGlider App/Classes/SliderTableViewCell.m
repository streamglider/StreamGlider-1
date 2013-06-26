//
//  SliderTableViewCell.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 16/05/2011.
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

#import "SliderTableViewCell.h"


@implementation SliderTableViewCell

@synthesize slider;

#pragma mark UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	slider.frame = CGRectMake(self.contentView.frame.size.width - slider.frame.size.width - self.textLabel.frame.origin.x, 
							  (self.frame.size.height - slider.frame.size.height) / 2, 
							  slider.frame.size.width, 
							  slider.frame.size.height);
	
}

#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		slider = [[UISlider alloc] init];
		slider.minimumValue = 2;
		slider.maximumValue = 20;
		slider.continuous = NO;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[self.contentView addSubview:slider];
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	self.slider = nil;
    [super dealloc];
}


@end
