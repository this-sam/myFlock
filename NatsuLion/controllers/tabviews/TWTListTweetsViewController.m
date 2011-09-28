//
//  TWTListTweetsViewController.m
//  tweetee
//
//  Created by fizban on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TWTListTweetsViewController.h"
#import "NTLNAccount.h"
#import "NTLNConfiguration.h"
#import "NTLNHttpClientPool.h"

@implementation TWTListTweetsViewController
@synthesize listID;

- (id)initWithListID:(NSString*)list_id {
	if ((self = [super init])) {
		NSString *archiveName = [NSString stringWithFormat:@"%@-listTweet.plist", listID];
		timeline = [[NTLNTimeline alloc] initWithDelegate:self 
									  withArchiveFilename:archiveName];
		self.listID=list_id;
	}
	return self;
}

- (void)setupNavigationBar {
	[super setupNavigationBar];
	[super setupPostButton];
	[self.navigationItem setTitle:self.listID];
}

- (void)timeline:(NTLNTimeline*)tl requestForPage:(int)page since_id:(NSString*)since_id {
	
	NTLNTwitterClient *tc = [[NTLNHttpClientPool sharedInstance] 
							 idleClientWithType:NTLNHttpClientPoolClientType_TwitterClient];
	tc.delegate = tl;
	[tc getListTweets:listID];
}

@end
