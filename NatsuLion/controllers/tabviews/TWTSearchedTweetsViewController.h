//
//  TWTSearchedTweetsViewController.h
//  tweetee
//
//  Created by fizban on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TWTSearchedTweetsViewController : UITableViewController {
	NSString *searchString;
	NSMutableArray *tweetsArray;
	NSMutableArray *screenNamesArray;	
	
}

@property (nonatomic, retain) NSString *searchString;
@property (nonatomic, retain) NSMutableArray *tweetsArray;
@property (nonatomic, retain) NSMutableArray *screenNamesArray;

- (id)initWithSearch:(NSString *)searchString;
- (void) getTrendTweet;
@end
