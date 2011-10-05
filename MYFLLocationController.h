//
//  MYFLLocationController.h
//  myFlock
//
//  Created by Austin Emmons on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MYFLLocationController : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
    CLLocationManager *locationManager;
	MKPlacemark *location;	
	MKReverseGeocoder *reverseGeocoder;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKPlacemark *location;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;



//. These are all the functions the delegate has defined. We can implement them as we see fit.
//
//-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region;
//-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region;
//-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
//-(void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;



-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
-(void) reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error;
-(void) reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark;


@end
