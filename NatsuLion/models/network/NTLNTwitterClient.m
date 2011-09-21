#import "NTLNTwitterClient.h"
#import "NTLNAccount.h"
#import "NTLNXMLHTTPEncoder.h"
#import "NTLNConfiguration.h"
#import "NTLNAlert.h"
#import "NTLNRateLimit.h"
#import "NSDateExtended.h"
#import "NTLNTwitterXMLParser.h"
#import "NTLNHttpClientPool.h"

#import "ASIFormDataRequest.h"
#import "RegexKitLite.h"

#import "JSON.h"


@implementation NTLNTwitterClient

@synthesize requestPage, requestForDirectMessage;
@synthesize delegate;

/// private methods

+ (NSString*)URLForTwitterWithAccount {
	return @"http://twitter.com/";
}

// added by corradoignoti.it. 
+ (NSString *)URLForTwitterSearch {
	return @"http://search.twitter.com";
}

// added by corradoignoti.it to parse a JSON twitter answer
- (void)getJSONTimeLine:(NSString *)path page:(int)page count:(int)count {
	NSString *url = [NSString stringWithFormat:@"%@/%@", [NTLNTwitterClient URLForTwitterSearch], path];
	
	requestPage = page;
	parseResultXML = NO;
	parseResultJSON = YES;
	requestForTimeline = YES;
	
	NSLog(@"Request URL %@", url);
	
	[super requestGET:url];
	
	[delegate twitterClientBegin:self];
}

// added by corradoignoti.it
// Parse JSON data
- (NSDictionary *) parseJSONData:(NSData *)data {

	SBJSON *jsonParser = [SBJSON new];
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *dict = (NSDictionary*)[jsonParser objectWithString:jsonString];
	[jsonString release];
	[jsonParser release];
	/*
	NSString *statusCode = [dict objectForKey:@"statusCode"];
	
	if([statusCode isEqualToString:@"OK"])
	{
		
		NSString *shortURL = [[[dict objectForKey:@"results"] 
							   objectForKey:f_longURL] 
							  objectForKey:@"shortUrl"];
		return shortURL;
		
		NSLog(@"sono qui....");
	}*/
	NSDictionary *trend;
	for (trend in [dict objectForKey:@"trends"]) {
		NSLog(@"-->%@", [trend objectForKey:@"url"]);
	}

	//NSLog (@"%@", [dict objectForKey:@"trends"]);
	return nil;
}

- (void)getTimeline:(NSString*)path page:(int)page count:(int)count since_id:(NSString*)since_id {
	NSString* url = [NSString stringWithFormat:@"%@%@.xml?count=%d", 
					 [NTLNTwitterClient URLForTwitterWithAccount], path, count];
		
	if (page >= 2) {
		url = [NSString stringWithFormat:@"%@&page=%d&max_id=%@", url, page, since_id];
	} else if (since_id) {
		url = [NSString stringWithFormat:@"%@&since_id=%@", url, since_id];
	}
	
	requestPage = page;
	parseResultXML = YES;
	parseResultJSON = NO;
	requestForTimeline = YES;
	
#ifdef ENABLE_OAUTH
	[super requestGET:url];
#else	
	NSString *username = [[NTLNAccount sharedInstance] screenName];
	NSString *password = [[NTLNAccount sharedInstance] password];
	
	[super requestGET:url username:username password:password];
#endif	

	[delegate twitterClientBegin:self];
}

- (void)getListsTimeline:(NSString*)ListID {
	
	NSString* url = [NSString stringWithFormat:@"http://api.twitter.com/1/%@/lists/%@/statuses.xml", [[NTLNAccount sharedInstance] screenName], ListID];
	requestPage = 20;
	parseResultXML = YES;
	parseResultJSON = NO;
	requestForTimeline = YES;
	NSLog(@"[Twitter client] Request: %@", url);
	
#ifdef ENABLE_OAUTH
	[super requestGET:url];
#else	
	NSString *username = [[NTLNAccount sharedInstance] screenName];
	NSString *password = [[NTLNAccount sharedInstance] password];
	
	[super requestGET:url username:username password:password];
#endif	
	
	[delegate twitterClientBegin:self];
}

- (void) dealloc {
	[delegate release];
	[screenNameForUserTimeline release];
	[super dealloc];
}

- (void)reset {
	[super reset];
	[xmlParser release];
	xmlParser = [[NTLNTwitterXMLParser alloc] init];
}

- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)response {
	[super connection:c didReceiveResponse:response];

	if (rate_limit) {
		[NTLNRateLimit shardInstance].rate_limit = rate_limit;
		[NTLNRateLimit shardInstance].rate_limit_remaining = rate_limit_remaining;
		[NTLNRateLimit shardInstance].rate_limit_reset = rate_limit_reset;
	}
}

// modified by corradoignoti.it to add JSON parsing process
- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)data {
	// don't use recievedData
	if (statusCode == 200 && parseResultXML && contentTypeIsXml) {
		[xmlParser parseXMLDataPartial:data];
	} else if (statusCode == 200 && parseResultJSON){
		[self parseJSONData:data];
	}
}

- (void)requestSucceeded {

	if (statusCode == 200) {
		if (parseResultXML) {
			if (contentTypeIsXml) {		

				// finish parsing
				[xmlParser parseXMLDataPartial:nil];
				if (xmlParser.messages.count > 0) {
					NSLog(@"%@", xmlParser.messages);
					[delegate twitterClientSucceeded:self messages:xmlParser.messages];
				} else {
					[delegate twitterClientSucceeded:self messages:nil];
				}
								
			} else {
				[[NTLNAlert instance] alert:@"Invaild XML Format" 
								withMessage:@"Twitter responded invalid format message, or please check your network environment."];
				[delegate twitterClientFailed:self];
			}
		} else {
			[delegate twitterClientSucceeded:self messages:nil];
		}
				
	} else {
		if (statusCode != 304) {
			switch (statusCode) {
				case 400:
					[[NTLNAlert instance] alert:@"Twitter: exceeded the rate limit" 
									withMessage:[NSString 
												 stringWithFormat:@"The client has exceeded the rate limit. Clients are allowed %d requests per hour time period. The period will be in %@.", 
												 [NTLNRateLimit shardInstance].rate_limit,
												 [[NTLNRateLimit shardInstance].rate_limit_reset descriptionWithRateLimitRemaining]]];
					
					break;
				case 401:
				case 403:
					if (screenNameForUserTimeline) {
						[[NTLNAlert instance] alert:@"Protected" 
										withMessage:[NSString 
													 stringWithFormat:@"@%@ has protected their updates.", 
													 screenNameForUserTimeline]];
					} else {
						[[NTLNAlert instance] alert:@"Authorization Failed" 
										withMessage:@"Wrong Username/Email and password combination."];
					}
					break;
				default:
					{
						NSString *msg = [NSString stringWithFormat:@"Twitter responded %d", statusCode];
						if (requestForTimeline) {
							[[NTLNAlert instance] alert:@"Retrieving timeline failed" withMessage:msg];
						} else {
							[[NTLNAlert instance] alert:@"Sending a message failed" withMessage:msg];
						}
					}
					break;
			}
		}
		
		[delegate twitterClientFailed:self];
	}
	
	[xmlParser release];
	xmlParser = nil;

	[delegate twitterClientEnd:self];
	[[NTLNHttpClientPool sharedInstance] releaseClient:self];
}

- (void)requestFailed:(NSError*)error {
	if (error) {
		[[NTLNAlert instance] alert:@"Network error" withMessage:[error localizedDescription]];
	}
	
	[delegate twitterClientFailed:self];
	[delegate twitterClientEnd:self];
	[[NTLNHttpClientPool sharedInstance] releaseClient:self];
}

/// public interfaces

- (void)getFriendsTimelineWithPage:(int)page since_id:(NSString*)since_id {
	int count = 20;
	if (since_id == nil && page < 2) {
		count = [[NTLNConfiguration instance] fetchCount]; 
	} else if (since_id && page < 2) {
		count = 200;
	}
	[self getTimeline:@"statuses/friends_timeline" 
				 page:page 
				count:count
			 since_id:since_id];
}

- (void)getRepliesTimelineWithPage:(int)page since_id:(NSString*)since_id {
	int count = 20;
	if (since_id && page < 2) count = 200;
	[self getTimeline:@"statuses/replies" 
				 page:page 
				count:count 
			 since_id:since_id];
}

- (void)getSentsTimelineWithPage:(int)page since_id:(NSString*)since_id {
	int count = 20;
	if (since_id && page < 2) count = 200;
	[self getTimeline:@"statuses/user_timeline" 
				 page:page 
				count:count 
			 since_id:since_id];
}

- (void)getDirectMessagesWithPage:(int)page since_id:(NSString*)since_id{
	int count = 20;
	if (since_id && page < 2) count = 200;
	requestForDirectMessage = YES;
	[self getTimeline:@"direct_messages" 
				 page:page 
				count:count
			 since_id:since_id];
}

- (void)getSentDirectMessagesWithPage:(int)page {
	requestForDirectMessage = YES;
	[self getTimeline:@"direct_messages/sent" 
				 page:page 
				count:20 
			 since_id:nil];
}

- (void)getUserTimelineWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id {
	[screenNameForUserTimeline release];
	screenNameForUserTimeline = screenName;
	[screenNameForUserTimeline retain];
	[self getTimeline:[NSString stringWithFormat:@"statuses/user_timeline/%@", screenName]
				 page:page 
				count:20 
			 since_id:since_id];
}

- (void)getStatusWithStatusId:(NSString*)statusId {
	[self getTimeline:[NSString stringWithFormat:@"statuses/show/%@", statusId]
				 page:1
				count:20 
			 since_id:nil];
}

// added by Corrado Ignoti corradoignoti.it
// to show trends
- (void)getTrendsWithPage:(int)page count:(int)count{
	[self getJSONTimeLine:@"trends.json"
					 page:page 
					count:20];
}

// added by Corrado Ignoti corradoignoti.it
// to show tweets in a list
- (void) getListTweets:(NSString *)listID {
	[self getListsTimeline:listID];
	
}

- (void)post:(NSString*)tweet reply_id:(NSString*)reply_id {
	NSString* url = [NSString stringWithFormat:@"%@statuses/update.xml", 
						[NTLNTwitterClient URLForTwitterWithAccount]];
	NSString *postString; 
	if (reply_id == nil) { 
		postString = [NSString stringWithFormat:@"status=%@&source=Tweetee",  
					  [NTLNXMLHTTPEncoder encodeHTTP:tweet]]; 
	} else { 
		postString = [NSString stringWithFormat:@"status=%@&in_reply_to_status_id=%@&source=Tweetee",  
					  [NTLNXMLHTTPEncoder encodeHTTP:tweet], 
					  reply_id]; 
	}
	
#ifdef ENABLE_OAUTH
	[self requestPOST:url body:postString];
#else	
	NSString *username = [[NTLNAccount sharedInstance] screenName];
	NSString *password = [[NTLNAccount sharedInstance] password];
	[self requestPOST:url body:postString username:username password:password];
#endif
}

/*
 * corradoignoti
 * Post a picture using twitpic
 */

- (void)post:(NSString*)tweet reply_id:(NSString*)reply_id picture:(NSData *)apicture {
	
	//chek if the extended account settings are ok
	if ([[[NTLNAccount sharedInstance] password] length] != 0) {

		//Post the picture
		NSURL *picUrl = [NSURL URLWithString:@"http://twitpic.com/api/upload"];
		NSString *username = [[NTLNAccount sharedInstance] screenName];
		NSString *password = [[NTLNAccount sharedInstance] password];
		
		
		// Now, set up the post data:
		ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:picUrl] autorelease];
		
		//post....
		[request setData:apicture forKey:@"media"];
		[request setPostValue:username forKey:@"username"];
		[request setPostValue:password forKey:@"password"];
		
		// Initiate the WebService request
		[request start];
		
		NSString *response = [request responseString];
		NSString *strPicUrl = [response stringByMatching:@"http[a-zA-Z0-9.:/]*"]; // Match the URL for the twitpic.com post
		
#ifdef DEBUG
		NSLog(@"twitpic response:\n %@", response);
		NSLog(@"Picture Url: %@", strPicUrl);
#endif
		//append picture URL
		tweet = [tweet stringByAppendingFormat:@" %@", strPicUrl];
	} else {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Extended configuration is missing" 
															message:@"To post pictures you must configure the 'Extended account setting'" 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}


	//call the original post function
	[self post:tweet reply_id:reply_id];
	
	/*
	if (reply_id == nil) { 
		postString = [NSString stringWithFormat:@"status=%@&source=Tweetee",  
					  [NTLNXMLHTTPEncoder encodeHTTP:tweet]]; 
	} else { 
		postString = [NSString stringWithFormat:@"status=%@&in_reply_to_status_id=%@&source=Tweetee",  
					  [NTLNXMLHTTPEncoder encodeHTTP:tweet], 
					  reply_id]; 
	}
	
#ifdef DEBUG
	NSLog(@"Going to post the message: %@", postString);
#endif
	
		
	[self requestPOST:url body:postString username:username password:password];
	*/
}

- (void)createFavoriteWithID:(NSString*)messageId {
	NSString* url = [NSString stringWithFormat:@"%@favorites/create/%@.xml", 
					 [NTLNTwitterClient URLForTwitterWithAccount], messageId];
#ifdef ENABLE_OAUTH
	[self requestPOST:url body:nil];
#else	
	NSString *username = [[NTLNAccount sharedInstance] screenName];
	NSString *password = [[NTLNAccount sharedInstance] password];
	[self requestPOST:url body:nil username:username password:password];
#endif
}

- (void)destroyFavoriteWithID:(NSString*)messageId {
	NSString* url = [NSString stringWithFormat:@"%@favorites/destroy/%@.xml", 
					 [NTLNTwitterClient URLForTwitterWithAccount], messageId];
#ifdef ENABLE_OAUTH
	[self requestPOST:url body:nil];
#else	
	NSString *username = [[NTLNAccount sharedInstance] screenName];
	NSString *password = [[NTLNAccount sharedInstance] password];
	[self requestPOST:url body:nil username:username password:password];
#endif
}

- (void)getFavoriteWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id{
	[self getTimeline:[NSString stringWithFormat:@"favorites/%@", screenName]
				 page:page 
				count:20 
			 since_id:since_id];
}

@end
