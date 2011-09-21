//
//  TWTListTweetsViewController.h
//  tweetee
//
//  Created by fizban on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTLNTimelineViewController.h"


@interface TWTListTweetsViewController : NTLNTimelineViewController {
	NSString *listID;
}

@property (copy) NSString *listID;

- (id)initWithListID:(NSString*)listID;

@end
