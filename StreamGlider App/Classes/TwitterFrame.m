//
//  TwitterFrame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/21/10.
//  Copyright 2010 StreamGlider, Inc. All rights reserved.
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

#import "TwitterFrame.h"

@implementation TwitterFrame

@synthesize text, createdAt, userName, statusId;

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	self.text = [aDecoder decodeObjectForKey:@"text"];
	self.createdAt = [aDecoder decodeObjectForKey:@"createdAt"];
	self.userName = [aDecoder decodeObjectForKey:@"userName"];
	self.statusId = [aDecoder decodeObjectForKey:@"statusId"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:text forKey:@"text"];
	[aCoder encodeObject:createdAt forKey:@"createdAt"];
	[aCoder encodeObject:userName forKey:@"userName"];
	[aCoder encodeObject:statusId forKey:@"statusId"];
}

#pragma mark Lifecycle

- (NSString*)description {
	return [NSString stringWithFormat:@"%@: %@", userName, text];
}

- (void)dealloc {	
	self.text = nil;
	self.createdAt = nil;
	self.userName = nil;
	self.statusId = nil;
	
	[super dealloc];	
}

@end
