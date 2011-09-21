//
//  TWTTrendsViewController.m
//  tweetee
//
//  Created by fizban on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TWTTrendsViewController.h"
#import "NTLNAccount.h"
#import "NTLNConfiguration.h"
#import "NTLNHttpClientPool.h"

@implementation TWTTrendsViewController

- (id)init {
	if (self = [super init]) {
		timeline = [[NTLNTimeline alloc] initWithDelegate:self 
									  withArchiveFilename:@"trends.plist"];
	}
	return self;
}

- (void)setupNavigationBar {
	[super setupNavigationBar];
	[super setupPostButton];
	[self.navigationItem setTitle:@"Trends"];
}

- (void)timeline:(NTLNTimeline*)tl requestForPage:(int)page since_id:(NSString*)since_id {
	
	NTLNTwitterClient *tc = [[NTLNHttpClientPool sharedInstance] 
							 idleClientWithType:NTLNHttpClientPoolClientType_TwitterClient];
	tc.delegate = tl;

	[tc getTrendsWithPage:page
					count:0];
}

@end
