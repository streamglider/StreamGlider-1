//
//  BaseCacheController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 13/10/2010.
//  Refactoring by Gavin McKenzie on 11-07-12.
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

#import "BaseCacheController.h"
#import "Core.h"
#import "Feed.h"
#import "Stream.h"
#import "Frame.h"
#import "PageOfStreams.h"

@interface BaseCacheController ()

@property (nonatomic, retain) NSMutableDictionary *data;

@end

@implementation BaseCacheController

@synthesize data, syncingImages;

#define CACHE_DATA_FILE_NAME @"cache.data"
#define CACHE_LIMIT 6
#define IMAGES_FOLDER @"images"
#define RES_FOLDER @"resources"
#define THUMB_SUFFIX @"thumb"

#pragma mark Caching

- (void)syncResourcesAndImagesCache {
	if (!self.syncingImages) { 
		self.syncingImages = YES;
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		DebugLog(@"starting images sync...");
		NSArray *images = [[Core sharedInstance] getImagePaths];
		// 
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		
		if ([paths count] > 0) {
			NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGES_FOLDER];
			
			NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
			if (files != nil && [files count] > 0) {
				for (NSString *file in files) {
					if ([file rangeOfString:@"."].location == 0)
						continue;
					
					NSString *filePath = [path stringByAppendingPathComponent:file];
					if (![images containsObject:filePath]) {
						DebugLog(@"removing file: %@", filePath);
						[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
					} 
				}
			}
		}
        
        // sync resources as well
		NSArray *resources = [[Core sharedInstance] getResourcePaths];
		// 
		
		if ([paths count] > 0) {
			NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:RES_FOLDER];
			
			NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
			if (files != nil && [files count] > 0) {
				for (NSString *file in files) {
					if ([file rangeOfString:@"."].location == 0)
						continue;
					
					NSString *filePath = [path stringByAppendingPathComponent:file];
					if (![resources containsObject:filePath]) {
						DebugLog(@"removing file: %@", filePath);
						[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
					} 
				}
			}
		}
        
		[pool drain];
		
		DebugLog(@"images sync complete");
		self.syncingImages = NO;
	}
}

- (NSString*)generateID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	
	//get the string representation of the UUID
	NSString *objectID = (NSString*)CFUUIDCreateString(nil, uuidObj);
	
	CFRelease(uuidObj);
	
	return [objectID autorelease]; 
}

- (NSData*)createThumbnail:(NSData*)imageData {
	UIImage *img = [UIImage imageWithData:imageData];
	
	// 225 141
	float widthRatio = img.size.width / 225;
	float heightRatio = img.size.height / 141;
	
	float ratio = MIN(widthRatio, heightRatio);
	
	if (ratio < 1)
		return imageData;
	
	CGSize size = CGSizeMake(img.size.width / ratio, img.size.height / ratio);
	
	@try {
		@synchronized(self) {
			UIGraphicsBeginImageContext(size);
			
			CGRect rect = CGRectMake(0, 0, size.width, size.height);
			
			[img drawInRect:rect];
			UIImage *thumbImg = UIGraphicsGetImageFromCurrentImageContext();
			
			UIGraphicsEndImageContext();
			
			return UIImagePNGRepresentation(thumbImg);
		}			
	}
	@catch (NSException *e) {
		NSLog(@"draw in rect problem, %@", e);
	}
	@finally {
	}
	return nil;
}

- (NSData*)loadImageData:(NSString*)url {
    NSData *imageData = nil;
    
    NSURL *urlObject = [NSURL URLWithString:url];
    imageData = [NSData dataWithContentsOfURL:urlObject];
    
	return imageData;
}

- (NSString*)storeImageData:(NSString*)imageUrl withThumb:(BOOL)withThumb {
	// load image data
	if (imageUrl != nil) {
		
		NSData *imageData;
        imageData = [self loadImageData:imageUrl];
        
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		
		if ([paths count] > 0 && imageData != nil) {
			
			NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGES_FOLDER];
			
			// if directory doesn't exist, create one
			if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
				[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES 
														   attributes:nil error:NULL];
			}
			
			NSString *imgID = [self generateID];
            
			path = [path stringByAppendingPathComponent:imgID];
						
			[imageData writeToFile:path atomically:YES];
			
			if (withThumb) {
				// create a thumbnail
				NSData *thumbData = [self createThumbnail:imageData];
				NSString *thumbPath = [path stringByAppendingString:THUMB_SUFFIX];
				[thumbData writeToFile:thumbPath atomically:YES];
			}
			
			return path;
		}
	}	
	
	return nil;
}

- (UIImage*)getImage:(NSString*)path {
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	UIImage *img = [UIImage imageWithData:imageData];
	return img;
}

- (void)releaseImage:(NSString*)path {
	if (path == nil)
		return;
	
	DebugLog(@"releasing image at path: %@", path);
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (NSString*)storeResourceData:(NSData*)resData {
    if (resData != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        if ([paths count] > 0) {
            
            NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:RES_FOLDER];
            
            // if directory doesn't exist, create one
            if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            
            NSString *resID = [self generateID];
            
            path = [path stringByAppendingPathComponent:resID];
                        
            [resData writeToFile:path atomically:YES];
            
            return path;
        }
    }	

    return nil;
}

- (NSData*)getResourceData:(NSString*)path {
	NSData *resData = [NSData dataWithContentsOfFile:path];
    return resData;
}

- (void)releaseResourceData:(NSString*)path {
	if (path == nil)
		return;
	
	DebugLog(@"releasing resource at path: %@", path);
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];    
}

- (void)dumpCache {
	DebugLog(@"dumping cache, memory warning handling");
	[self storeCacheData];
	self.data = [[[NSMutableDictionary alloc] init] autorelease];
}

- (void)storeCacheData {
	if ([data count] != 0) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		if ([paths count] > 0) {
			NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:CACHE_DATA_FILE_NAME];		
			[NSKeyedArchiver archiveRootObject:data toFile:path];				
		}	
	}
}

- (void)loadCacheData {
	// read cache dictionary from file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:CACHE_DATA_FILE_NAME];
		
		//check if the directory exists
		if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
			self.data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		}				
	}
    
    for (PageOfStreams *p in [Core sharedInstance].pages) {
        for (Stream *s in p.streams) {
            [self streamWasAdded:s];
        }
    }
}

- (Feed*)findFeed:(NSString*)feedID {	
    for (PageOfStreams *p in [Core sharedInstance].pages) {
        for (Stream *stream in p.streams) {
            for (Feed *feed in stream.feeds) {
                if ([feed.objectID isEqualToString:feedID]) {
                    return feed;
                }
            }
        }
    }
	
	return nil;
}

- (NSArray*)getFramesForStream:(Stream*)stream {
	return [data objectForKey:stream.objectID];
}


#pragma mark CoreDelegate

- (void)streamWasAdded:(Stream *)stream {
	[stream addStreamDelegate:self];
	
	//if this is a new stream, add value to the dictionary
	if ([data objectForKey:stream.objectID] == nil) {	
		NSMutableArray *frames = [[NSMutableArray alloc] init];
		[data setObject:frames forKey:stream.objectID];
		[frames release];
	}
}

- (void)streamWasRemoved:(Stream *)stream index:(NSInteger)index {
	[stream removeStreamDelegate:self];
	[data removeObjectForKey:stream.objectID];
}		

#pragma mark StreamDelegate

- (void)frameWasAdded:(Frame *)frame {
	// cache frame	
	NSMutableArray *frames = [data objectForKey:frame.feed.stream.objectID];
	[frames addObject:frame];
	
	if ([frames count] > CACHE_LIMIT) {
		[frames removeObjectAtIndex:0];
	}	
}

- (void)frameWasRemoved:(Frame *)frame {
	// remove from cache, if necessary
}

#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {		
		[[Core sharedInstance] addCoreDelegate:self];							  		
		
		self.data = [[[NSMutableDictionary alloc] init] autorelease];
	}
	return self;
}

- (void)dealloc {
	self.data = nil;
	[super dealloc];
}


@end
