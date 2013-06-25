//
//  FlickrFrame.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 04/10/2010.
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

#import "FlickrFrame.h"
#import "CacheController.h"


@implementation FlickrFrame

@synthesize title, userName, dateUpload, secondaryImageURL;

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
			
	self.title = [aDecoder decodeObjectForKey:@"title"];
	self.userName = [aDecoder decodeObjectForKey:@"userName"];
	self.dateUpload = [aDecoder decodeObjectForKey:@"dateUpload"];	
	self.secondaryImageURL = [aDecoder decodeObjectForKey:@"secondaryImageURL"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[super encodeWithCoder:aCoder];		
	[aCoder encodeObject:title forKey:@"title"];	
	[aCoder encodeObject:userName forKey:@"userName"];
	[aCoder encodeObject:dateUpload forKey:@"dateUpload"];	
	[aCoder encodeObject:secondaryImageURL forKey:@"secondaryImageURL"];
}

#pragma mark Lifecycle

- (NSString*)description {
	return title;
}

- (void)dealloc {	
	self.title = nil;
	self.userName = nil;
	self.dateUpload = nil;
	self.secondaryImageURL = nil;
		
	[super dealloc];
}

@end
