//
//  SmallFrameFactory.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 7/22/10.
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

#import "SmallFrameFactory.h"
#import "TwitterFrame.h"
#import "TwitterSmallFrameViewController.h"
#import "RSSFrame.h"
#import "RSSSmallFrameViewController.h"
#import "YTFrame.h"
#import "YTSmallFrameViewController.h"
#import "FBFrame.h"
#import "FBSmallFrameViewController.h"
#import "FlickrFrame.h"
#import "FlickrSmallFrameViewController.h"


@implementation SmallFrameFactory

+ (SmallFrameViewController*)createSmallFrameViewFor:(Frame *)frame {
    SmallFrameViewController *c = nil;
    
	if ([frame isMemberOfClass:[TwitterFrame class]]) {
		c = [[TwitterSmallFrameViewController alloc] 
											  initWithNibName:@"TwitterSmallFrameViewController" bundle:nil];
		c.frame = frame;
	} else if ([frame isMemberOfClass:[RSSFrame class]]) {
		c = [[RSSSmallFrameViewController alloc] 
										  initWithNibName:@"RSSSmallFrameViewController" bundle:nil];
		c.frame = frame;
	} else if ([frame isMemberOfClass:[YTFrame class]]) {
		c = [[YTSmallFrameViewController alloc] 
										  initWithNibName:@"YTSmallFrameViewController" bundle:nil];
		c.frame = frame;
	} else if ([frame isMemberOfClass:[FBFrame class]]) {
		c = [[FBSmallFrameViewController alloc] 
										 initWithNibName:@"FBSmallFrameViewController" bundle:nil];
		c.frame = frame;
	} else if ([frame isMemberOfClass:[FlickrFrame class]]) {
		c = [[FlickrSmallFrameViewController alloc] 
										 initWithNibName:@"FlickrSmallFrameViewController" bundle:nil];
		c.frame = frame;
	}
		
	return [c autorelease];		
}

@end
