//
//  MYFLLocationController.m
//  myFlock
//
//  Created by Austin Emmons on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MYFLLocationController.h"


@implementation MYFLLocationController
@synthesize locationManager;



-(void) dealloc
{
    [self.locationManager release];
    [super dealloc];
}


-(id)init
{
    if ((self = [super init])) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;   //send location updates to self, MYFLLocationController instance
    }
    return self;
}



-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"\nLocation: %@\n",[newLocation description]);
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
}


@end
