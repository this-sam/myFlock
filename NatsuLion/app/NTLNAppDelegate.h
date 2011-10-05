#import <UIKit/UIKit.h>

#import "NTLNCacheCleaner.h"

@class NTLNBrowserViewController;
@class NTLNFriendsViewController;
@class NTLNMentionsViewController;
@class NTLNSentsViewController;
@class NTLNUnreadsViewController;
@class NTLNSettingViewController;
@class NTLNFavoriteViewController;
@class NTLNDirectMessageViewController;
@class TWTTrendsViewController;
@class TWTListViewController;
@class TWTSearchViewController;

//iOS Dev
@class MYFLLocalTweetViewController;

@interface NTLNAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, NTLNCacheCleanerDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
	
	NTLNFriendsViewController *friendsViewController;
	NTLNMentionsViewController *replysViewController;
	NTLNSentsViewController *sentsViewController;
	NTLNUnreadsViewController *unreadsViewController;
	NTLNSettingViewController *settingViewController;
	
	NTLNFavoriteViewController *favoriteViewController;
	
	NTLNDirectMessageViewController *directMessageViewController;
	
	TWTTrendsViewController *trendsViewController;
	TWTSearchViewController *searchViewController;
	TWTListViewController *listViewController;
	
	MYFLLocalTweetViewController *localTweetViewController;

	BOOL applicationActive;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (readonly) BOOL applicationActive;

- (BOOL)isInMoreTab:(UIViewController*)vc;
- (void)presentTwitterAccountSettingView;
- (void)presentTwitterExtendedAccountSettingView;
- (void)resetAllTimelinesAndCache;

@end

