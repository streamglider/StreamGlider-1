//
//  EditTitleTableViewCell.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 06/09/2010.
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

#import "NamedFieldTableViewCell.h"


@implementation NamedFieldTableViewCell

@synthesize titleValueTextField;

#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		// create text field for title value 
		titleValueTextField = [[UITextField alloc] init];
		
		titleValueTextField.textColor = self.detailTextLabel.textColor;
		
		// there should be no border
		titleValueTextField.borderStyle = UITextBorderStyleNone;
		
		titleValueTextField.textAlignment = UITextAlignmentLeft;
		titleValueTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		titleValueTextField.returnKeyType = UIReturnKeyDone;	
		
		// add text field to the container and remove detailTextLabel
		self.detailTextLabel.hidden = YES;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self.contentView addSubview:titleValueTextField];		
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
	
	float gap = self.textLabel.frame.origin.x;
	float labelW = self.textLabel.frame.size.width;
	float aWidth = self.contentView.frame.size.width - labelW - 3 * gap;
	
	float xPos = 2 * gap + labelW;
	titleValueTextField.frame = CGRectMake(xPos, 0, 
										   aWidth, self.textLabel.frame.size.height);
	
	titleValueTextField.center = CGPointMake(titleValueTextField.center.x, self.textLabel.center.y);
}


#pragma mark Lifecycle

- (void)dealloc {
	self.titleValueTextField = nil;
    [super dealloc];
}


@end
