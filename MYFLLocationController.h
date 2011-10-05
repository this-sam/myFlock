//
//  MYFLLocationController.h
//  myFlock
//
//  Created by Austin Emmons on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MYFLLocationController : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) CLLocationManager *locationManager;




//. These are all the functions the delegate has defined. We can implement them as we see fit.
//
//-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region;
//-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region;
//-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
//-(void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;



-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;



@end
