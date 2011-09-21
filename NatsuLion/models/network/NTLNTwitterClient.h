#import <UIKit/UIKit.h>
#import "NTLNOAuthHttpClient.h"
#import "NTLNTwitterXMLParser.h"

@class NTLNTwitterClient;

@protocol NTLNTwitterClientDelegate
- (void)twitterClientBegin:(NTLNTwitterClient*)sender;
- (void)twitterClientEnd:(NTLNTwitterClient*)sender;
- (void)twitterClientSucceeded:(NTLNTwitterClient*)sender messages:(NSArray*)messages;
- (void)twitterClientFailed:(NTLNTwitterClient*)sender;
@end

#ifdef ENABLE_OAUTH
@interface NTLNTwitterClient : NTLNOAuthHttpClient {
#else
@interface NTLNTwitterClient : NTLNHttpClient {
#endif
	int requestPage;
	NSString *screenNameForUserTimeline;
	BOOL parseResultXML;
	BOOL parseResultJSON;
	NSObject<NTLNTwitterClientDelegate> *delegate;
	BOOL requestForTimeline;
	BOOL requestForDirectMessage;
	NTLNTwitterXMLParser *xmlParser;
}

- (void)getFriendsTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getRepliesTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getSentsTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getUserTimelineWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id;
- (void)getListsTimeline:(NSString*)ListID;
- (void)getDirectMessagesWithPage:(int)page since_id:(NSString*)since_id;
- (void)getTrendsWithPage:(int)page count:(int)count;
- (void)getSentDirectMessagesWithPage:(int)page;
- (void)getFavoriteWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id;
- (void)getStatusWithStatusId:(NSString*)statusId;
- (void) getListTweets:(NSString *)listID;
- (void)createFavoriteWithID:(NSString*)messageId;
- (void)destroyFavoriteWithID:(NSString*)messageId;
- (void)post:(NSString*)tweet reply_id:(NSString*)reply_id;
- (void)post:(NSString*)tweet reply_id:(NSString*)reply_id picture:(NSData *)apicture;

@property (readonly) int requestPage;
@property (readonly) BOOL requestForDirectMessage;
@property (readwrite, retain) NSObject<NTLNTwitterClientDelegate> *delegate;

@end
