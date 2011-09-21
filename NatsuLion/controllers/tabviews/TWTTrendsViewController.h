//
//  TWTTrendsViewController.h
//  tweetee
//
//  Created by fizban on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TWTTrendsViewController : UITableViewController {
	NSMutableArray *trendsList;
	UISearchBar *searchBar;
	
}

@property (nonatomic, retain) NSMutableArray *trendsList;
@property (nonatomic, retain) UISearchBar *searchBar;

- (void) getTrends;
@end
