//
//  SegmentedControlTableViewCell.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 09/09/2010.
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

#import "SegmentedControlTableViewCell.h"


@implementation SegmentedControlTableViewCell

@synthesize segmentedControl;

#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		segmentedControl = [[UISegmentedControl alloc] init];
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[self.contentView addSubview:segmentedControl];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	//int aWidth = self.frame.size.width - 65;
	segmentedControl.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 
										self.frame.size.height);
}

#pragma mark Lifecycle

- (void)dealloc {
	self.segmentedControl = nil;
    [super dealloc];
}


@end
