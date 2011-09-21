//
//  TWTListViewController.m
//  tweetee
//
//  Created by fizban on 1/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TWTListViewController.h"
#import "JSON.h"
#import "NTLNAccount.h"


#import "TWTListTweetsViewController.h"


@implementation TWTListViewController

@synthesize listArray;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Setup the table
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
	self.tableView.backgroundColor = [UIColor colorWithRed:213 green:213 blue:213 alpha:0.9];
	
	//Show an alert if extended twitter account settings aren't ok
	NSString *password = [[NTLNAccount sharedInstance] password];
	
	if ([password length] != 0) {
		listArray = [[NSMutableArray alloc] init];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self getList];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;		
	} else {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Extended configuration is missing" 
															message:@"To access to the list you must configure the 'Extended account setting'" 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[self.view removeFromSuperview];
	}
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = [[listArray objectAtIndex:indexPath.row] objectForKey:@"listNames"];
	
	NSURL *url = [NSURL URLWithString:[[listArray objectAtIndex:indexPath.row] objectForKey:@"profileImageUrls"]];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
	cell.imageView.image = img;
	//cell.backgroundColor = [UIColor clearColor];
		
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *listID = [[listArray objectAtIndex:indexPath.row] objectForKey:@"listNames"];
	TWTListTweetsViewController *vc = [[[TWTListTweetsViewController alloc] initWithListID:listID] autorelease];
	[[self navigationController] pushViewController:vc animated:YES];
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[listArray dealloc];
    [super dealloc];
}

#pragma mark -
#pragma mark utility and support
- (void) getList {
	
	NSString *username = [[NTLNAccount sharedInstance] screenName];
	NSString *password = [[NTLNAccount sharedInstance] password];
	
	
	NSString *str_requestURL = [[[NSString alloc] initWithFormat:@"http://%@:%@@api.twitter.com/1/%@/lists.json", username, password, username] 
							   autorelease];
	
	NSURL *_url = [NSURL URLWithString:str_requestURL];
	
	NSLog(@"list request: %@", str_requestURL);
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:_url];
	[req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[req setHTTPShouldHandleCookies:FALSE];
	
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
		
		NSArray *listObjects = [objects objectForKey:@"lists"];
		NSLog(@"%@", listObjects);
		
		for (int i = 0; i < [listObjects count]; i++) {
			NSDictionary *listDictionary =  [listObjects objectAtIndex:i];
			NSString *listNames = (NSString *)[listDictionary objectForKey:@"name"];
			NSString *listIDs = (NSString *)[listDictionary objectForKey:@"id"];
			NSString *profileImageUrls = (NSString *) [[listDictionary objectForKey:@"user"] objectForKey:@"profile_image_url"];
			
			NSArray *keys = [NSArray arrayWithObjects:@"listNames", @"listIDs", @"profileImageUrls", nil];
			NSArray *objects = [NSArray arrayWithObjects:listNames, listIDs, profileImageUrls, nil];
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			
			[listArray addObject:dictionary];
			NSLog(@"DEBUG: added: %@", dictionary);
		}
	}
}
@end

