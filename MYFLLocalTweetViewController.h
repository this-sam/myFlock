//
//  MYFLLocalTweetViewController.h
//  myFlock
//
//  Created by iOS Sam on 10/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTLNTwitterUserClient.h"

#import "MYFLLocationController.h"

@interface MYFLLocalTweetViewController : UITableViewController {
	NSString *searchString;
	NSMutableArray *tweetsArray;
	NSMutableArray *screenNamesArray;	
	
	//iOS Dev
	NTLNUser *userInfo;
    
//.Location
    MYFLLocationController *locationController;
    
    
}

@property (nonatomic, retain) NSString *searchString;
@property (nonatomic, retain) NSMutableArray *tweetsArray;
@property (nonatomic, retain) NSMutableArray *screenNamesArray;

//iOS Dev
@property (nonatomic, retain) NTLNUser *userInfo;

- (id)initWithSearch:(NSString *)searchString;
- (id)initWithLocation;
- (void) getTrendTweet;

@end