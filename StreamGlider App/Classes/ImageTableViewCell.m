//
//  ImageTableViewCell.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 07/03/2011.
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

#import "ImageTableViewCell.h"

@interface ImageTableViewCell ()

@property (nonatomic, retain) UIImageView *imageView;

@end

@implementation ImageTableViewCell

@synthesize imageName, imageView;

#pragma mark Properties

- (void)setImageName:(NSString*)name {
	[imageName release];
	imageName = [name copy];
	
	if (imageName != nil) {
		imageView.image = [UIImage imageNamed:imageName];
	}
}

#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		self.imageView = [[[UIImageView alloc] init] autorelease];
		[self.contentView addSubview:imageView];
		imageView.contentMode = UIViewContentModeCenter;
		imageView.clipsToBounds = YES;
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor colorWithRed:0.992 green:0.992 blue:0.992 alpha:1];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

#pragma mark UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect rect = self.contentView.frame;
	rect.origin = CGPointMake(0, 0);
	imageView.frame = rect;
}


#pragma mark Lifecycle

- (void)dealloc {
	self.imageName = nil;
	self.imageView = nil;
    [super dealloc];
}


@end
