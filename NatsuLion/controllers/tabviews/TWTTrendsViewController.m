//
//  TWTTrendsViewController.m
//  tweetee
//
//  Created by fizban on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TWTTrendsViewController.h"
#import "TWTSearchedTweetsViewController.h"
#import "JSON.h"



@implementation TWTTrendsViewController

@synthesize trendsList, searchBar;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title=@"Twitter trends";
	
	trendsList = [[NSMutableArray alloc] init];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self getTrends];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
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
    return [trendsList count];
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
	cell.textLabel.text = [[trendsList objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	NSString *searchHasTag = [[trendsList objectAtIndex:indexPath.row] objectForKey:@"name"];
	TWTSearchedTweetsViewController *vc = [[[TWTSearchedTweetsViewController alloc] initWithSearch:searchHasTag] autorelease];
	[[self navigationController] pushViewController:vc animated:YES];
	//[vc release];
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
    [super dealloc];
	[trendsList dealloc];
}

#pragma mark -
#pragma mark utility and support

- (void) getTrends {
	
	NSString *str_requestURL = [[NSString alloc] initWithFormat:@"http://search.twitter.com/trends.json"];
	NSURL *_url = [NSURL URLWithString:str_requestURL];
	
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
		
		NSArray *listObjects = [objects objectForKey:@"trends"];
		NSLog(@"%@", listObjects);
		
		for (int i = 0; i < [listObjects count]; i++) {
			NSDictionary *listDictionary =  [listObjects objectAtIndex:i];
			NSString *name = (NSString *)[listDictionary objectForKey:@"name"];
			NSString *url = (NSString *)[listDictionary objectForKey:@"url"];
			
			NSArray *keys = [NSArray arrayWithObjects:@"name", @"url", nil];
			NSArray *objects = [NSArray arrayWithObjects:name, url, nil];
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			
			[trendsList addObject:dictionary];
			NSLog(@"DEBUG: added: %@", dictionary);
		}
		NSLog(@"trendsList content: %@", trendsList);
	}
}


@end

