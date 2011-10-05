//
//  MYFLLocalTweetViewController.m
//  myFlock
//
//  Created by iOS Sam on 10/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "MYFLLocalTweetViewController.h"
#import "TWTSearchedTweetsViewController.h"
#import "NTLNUserTimelineViewController.h"
#import "NTLNStatusCell.h"
#import "NTLNStatus.h"
#import "JSON.h"


@implementation MYFLLocalTweetViewController

@synthesize searchString, tweetsArray, screenNamesArray, userInfo;

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

- (id)initWithSearch:(NSString *)sString {
	self.searchString = sString;
	return self;
}

-(id)initWithLocation{
	//THOUGHTS: ADD FUNCTION TO GET LOCATION IN NATSULION/MODELS/NETWORK/NTLNTwitterUserClient
	//THIS IS INTERFACE BETWEEN THE APP AND TWITTER
	self.searchString = @"&geocode=44.47503566,-73.19574313,10mi";//userInfo.screen_name;
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title=userInfo.screen_name;
	
	tweetsArray = [[NSMutableArray alloc] init];
    
//. location
    locationController = [[MYFLLocationController alloc] init];
    [locationController.locationManager startUpdatingLocation];
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self getTrendTweet];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	screenNamesArray = [[NSMutableArray alloc] init];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweetsArray count];
}




// Customize the appearance of table view cells.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.5; //returns floating point which will be used for a cell row height at specified row index
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.row == 0 || indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];		
        cell.backgroundColor = altCellColor;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //TWTTrendsCustomCell *cell = (TWTTrendsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 5;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.numberOfLines = 5;
	cell.textLabel.font = [UIFont systemFontOfSize:14.0];
	cell.textLabel.text = [[tweetsArray objectAtIndex:indexPath.row] objectForKey:@"tweet"];
	
	NSURL *url = [NSURL URLWithString:[[tweetsArray objectAtIndex:indexPath.row] objectForKey:@"imageURL"]];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
	cell.imageView.image = img;
	
	NSString *from = [[tweetsArray objectAtIndex:indexPath.row] objectForKey:@"from"];
	[screenNamesArray addObject:from];
	NSString *date = [[tweetsArray objectAtIndex:indexPath.row] objectForKey:@"date"];
	NSString *details = [NSString stringWithFormat:@"from: %@ - %@", from, date];
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:10];
	cell.detailTextLabel.text = details;
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NTLNUserTimelineViewController *utvc = [[[NTLNUserTimelineViewController alloc] init] autorelease];
	utvc.screenName = [screenNamesArray objectAtIndex:[indexPath row]];
	[[self navigationController] pushViewController:utvc animated:YES];
}


- (void)dealloc {
    [super dealloc];
	[screenNamesArray release];
//   releases locationController object
    [locationController release];
}

#pragma mark -
#pragma mark utility and support

- (void) getTrendTweet {
	
	NSString *str_requestURL = [[NSString alloc] initWithFormat:@"http://search.twitter.com/search.json?q=%@", searchString];
	NSString *str_escapedUrl = [str_requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	NSURL *_url = [NSURL URLWithString:str_escapedUrl];
	
	NSLog(@"Doing search by calling %@", str_escapedUrl);
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:_url];
	
	NSHTTPURLResponse* urlResponse = nil;  
	NSError *error = [[[NSError alloc] init] autorelease];  
	
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&urlResponse error:&error];	
	
	if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
	{
		SBJSON *jsonParser = [SBJSON new];
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary *objects = (NSDictionary *) [jsonParser objectWithString:jsonString];
		[jsonString release];
		[jsonParser release];
		
		NSArray *listObjects = [objects objectForKey:@"results"];
		NSLog(@"%@", listObjects);
		
		for (int i = 0; i < [listObjects count]; i++) {
			NSDictionary *listDictionary =  [listObjects objectAtIndex:i];
			NSString *from = (NSString *)[listDictionary objectForKey:@"from_user"];
			NSString *tweet = (NSString *)[listDictionary objectForKey:@"text"];
			NSString *date = (NSString *)[listDictionary objectForKey:@"created_at"];
			NSString *imageURL = (NSString *)[listDictionary objectForKey:@"profile_image_url"];
			
			NSArray *keys = [NSArray arrayWithObjects:@"from", @"tweet", @"date", @"imageURL",nil];
			NSArray *objects = [NSArray arrayWithObjects:from, tweet, date, imageURL, nil];
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			
			[tweetsArray addObject:dictionary];
			NSLog(@"DEBUG: added: %@", dictionary);
		}
		NSLog(@"tweetsArray content: %@", tweetsArray);
	}
	
}


@end