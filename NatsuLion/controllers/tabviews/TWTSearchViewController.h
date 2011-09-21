//
//  TWTSearchViewController.h
//  tweetee
//
//  Created by fizban on 3/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TWTSearchViewController : UITableViewController <UISearchBarDelegate>{
	UISearchBar *searchBar;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@end
