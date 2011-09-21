#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "NTLNAppDelegate.h"
#import "NTLNTwitterClient.h"

#import "ReadItLaterLite.h"

@class NTLNMessage;
@class NTLNFriendsViewController;
@class NTLNBrowserViewController;
@class NTLNTweetPostViewController;
@class NTLNUserTimelineViewController;

@interface NTLNURLPair : NSObject
{
	NSString *text;
	NSString *url;
	NSString *screenName;
	BOOL conversation;
}

@property(readwrite, retain) NSString *url, *text, *screenName;
@property(readwrite) BOOL conversation;

@end


@interface NTLNTweetViewController : UITableViewController 
										<UITableViewDelegate, 
										UITableViewDataSource, 
										NTLNTwitterClientDelegate,
										UIActionSheetDelegate,
										MFMailComposeViewControllerDelegate, 
										ReadItLaterDelegate> {											
	NTLNMessage *message;
	NSMutableArray *links;	
	UIButton *favButton;
	NSString *navigateTo;
	UIActivityIndicatorView *favAI;
}

@property(readwrite, retain) NTLNMessage *message;
@property(readwrite, retain) NSString *navigateTo;
@end

