//
//  ViewFriendOnMapControllerView.m
//  tweetee
//
//  Created by fizban on 1/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ViewFriendOnMapControllerView.h"

#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"


@implementation ViewFriendOnMapControllerView

@synthesize userInfo;

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[super viewDidLoad];
	
	mapView=[[MKMapView alloc] initWithFrame:self.view.bounds];
	mapView.showsUserLocation=TRUE;
	mapView.mapType=MKMapTypeStandard;
	mapView.delegate=self;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.2;
	span.longitudeDelta=0.2;
	
	CLLocationCoordinate2D location=mapView.userLocation.coordinate;
	
	//Request CSV response from google 
	
	NSURL *url = [NSURL URLWithString:@"http://maps.google.com/maps/geo?q=Varese,Italy&output=csv&oe=utf8&sensor=true_or_false&key=ABQIAAAAaMsyt6ablfdDRmnfO5uMLxR3eF0s5Z7dXctaWgIqMABhCM2SDRQSfke88JSTZbw73oF0uGKmAzjP2g"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request start];
	NSError *error = [request error];
	
	NSString *response = [request responseString];
	NSArray *listItems = [response componentsSeparatedByString:@","];
	NSLog(@"Lat: %@", [listItems objectAtIndex:2]);
	NSLog(@"Lon: %@", [listItems objectAtIndex:3]);
	
	location.latitude=[[listItems objectAtIndex:2] floatValue];
	location.longitude=[[listItems objectAtIndex:3] floatValue];
	region.span=span;
	region.center=location;

	MKPlacemark *placemark = [[[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil] autorelease];
	[mapView addAnnotation:placemark];

	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	[self.view insertSubview:mapView atIndex:0];
	
}

- (void) viewDidAppear:(BOOL)animated {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.animatesDrop=TRUE;
	annView.pinColor = MKPinAnnotationColorGreen;
	return annView;
}

/*
 *
 * Return the coordinate to use to show the pin on the map 
 */

- (NSArray *) parseUserInfo {
	NSString *userInfoLocation = userInfo.location;
	
	//Are the coordinate in to 'iPhone: latitude, longitude' shape?
	/*
	if (![[userInfoLocation stringByMatching:@"iPhone\:*"] isEqualToString:@"" ] {
		
	}*/
	
}
@end
