//
//  ViewFriendOnMapControllerView.h
//  tweetee
//
//  Created by fizban on 1/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>

#import "NTLNTwitterUserClient.h"




@interface ViewFriendOnMapControllerView : UIViewController <MKReverseGeocoderDelegate,MKMapViewDelegate>{
	MKMapView *mapView;
	MKReverseGeocoder *geoCoder;
	MKPlacemark *mPlacemark;
	IBOutlet UISegmentedControl *mapType;
	
	NTLNUser *userInfo;
}

@property (nonatomic, retain) NTLNUser *userInfo;

@end
