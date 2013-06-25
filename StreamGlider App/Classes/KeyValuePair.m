//
//  KeyValuePair.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 04/08/2010.
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

#import "KeyValuePair.h"


@implementation KeyValuePair

@synthesize key, value;

- (id)initWithKey:(NSString*)newKey value:(NSString*)newValue {
	if (self = [super init]) {
		self.key = newKey;
		self.value = newValue;
	}
	return self;			
}

- (NSString*)description {
	NSString *ret = [NSString stringWithFormat:@"%@=%@", key, value];
	return ret;
}

- (void)dealloc {
	self.key = nil;
	self.value = nil;
	[super dealloc];
}

@end
