//
//  LocationController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 23/02/2012.
//  Copyright (c) 2012 StreamGlider, Inc. All rights reserved.
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

#import "LocationController.h"

@implementation LocationController {
    CLLocationManager *manager;
}

@synthesize location, locationAvailable;

#pragma mark Properties

- (BOOL)isLocationAvailable {
    return [CLLocationManager locationServicesEnabled];
}

#pragma mark Singleton

static LocationController* instance = nil;

+ (LocationController*)sharedInstance {
	if (instance == nil) {
		instance = [[LocationController alloc] init];   
	}
	return instance;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (location != nil) 
        [location release];
    
    location = [newLocation copy];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location error: %@", error);
}

#pragma mark Lifecycle

- (id)init {
    if (self = [super init]) {
        if (self.locationAvailable) {
            manager = [[CLLocationManager alloc] init];
            manager.delegate = self;
            manager.purpose = [NSString stringWithFormat:@"%@ uses location services in order to deliver data located near you.", APP_NAME];
            
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            manager.distanceFilter = 1000;
            
            [manager startUpdatingLocation];
            
            location = [manager.location copy];
        }
    }
    
    return self;
}

- (void)dealloc {
    [manager stopMonitoringSignificantLocationChanges];
    [manager release];
    [location release];
    
    [super dealloc];
}


@end
