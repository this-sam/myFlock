//
//  TWTListViewController.h
//  tweetee
//
//  Created by fizban on 1/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TWTListViewController : UITableViewController {
	NSMutableArray *listArray;
}

@property (nonatomic, retain) NSMutableArray *listArray;

- (void) getList;

@end
