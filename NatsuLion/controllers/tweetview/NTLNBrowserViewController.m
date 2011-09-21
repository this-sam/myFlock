#import "NTLNBrowserViewController.h"
#import "NTLNAlert.h"
#import "NTLNAccelerometerSensor.h"
#import "NTLNWebView.h"
#import "NTLNTwitterPost.h"
#import "NTLNTweetPostViewController.h"
#import "NTLNAccount.h"
#import "ReadItLaterLite.h"

#import "JSON.h"
#import "bit_ly_apikeys.h"

@interface NTLNBrowserViewController(Private)
- (void)setupToolbarTop;
- (void)setupToolbarBottom;
- (void)updatePrevNextButton;
- (void)updateReloadButton;

- (void)reloadButtonPushed:(id)sender;
- (void)doneButtonPushed:(id)sender;
- (void)prevButtonPushed:(id)sender;
- (void)nextButtonPushed:(id)sender;
- (void)safariButtonPushed:(id)sender;
- (void)tweetURLButtonPushed:(id)sender;
- (void)saveToRILButtonPushed:(id)sender;
										
- (NSString*)shortenURL:(NSString*)f_longURL;

@end

@implementation NTLNBrowserViewController

@synthesize url;

- (void)loadView {  
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	toobarTop = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	toobarTop.barStyle = UIBarStyleBlackTranslucent;
	[self setupToolbarTop];
	[self.view addSubview:toobarTop];
	
	
	webView = [NTLNWebView sharedInstance];
	webView.frame = CGRectMake(0, 44, 320, 480-44-44);
	[self.view addSubview:webView];
	
	toobarBottom = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 480-44-20, 320, 44)];
	toobarBottom.barStyle = UIBarStyleBlackTranslucent;
	[self setupToolbarBottom];
	[self.view addSubview:toobarBottom];
}

- (void)viewDidDisappear:(BOOL)animated {
	///	self.view = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	webView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {	
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)dealloc {
	LOG(@"NTLNBrowserViewController#dealloc");
	
	[url release];
	[toobarTop release];
	[toobarBottom release];
	
	[reloadButton release];
	[title release];
	[prevButton release];
	[nextButton release];
	
	[toobarTopItems release];
	
	[self.view release];
	[super dealloc];
}

#pragma mark UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	loading = YES;
	[self updateReloadButton];
	[self updatePrevNextButton];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	loading = NO;
	title.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self updateReloadButton];
	[self updatePrevNextButton];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	if (error.code != -999) {
		[[NTLNAlert instance] alert:@"Browser error" withMessage:error.localizedDescription];
	}
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
	NSString *scheme = request.mainDocumentURL.scheme;
	if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
		title.title = request.mainDocumentURL.description;
		return YES;
	} else {
		[[UIApplication sharedApplication] openURL:request.URL];
	}
	return NO;
}

#pragma mark Private

- (void)setupToolbarTop {
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:@"close" 
																	style:UIBarButtonItemStyleBordered 
																   target:self		
																   action:@selector(doneButtonPushed:)] autorelease];
	
	[self updateReloadButton];
	
	title =	[[UIBarButtonItem alloc] initWithTitle:@"" 
											 style:UIBarButtonItemStylePlain
											target:nil 
											action:nil];
	title.width = 220;
	
	UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			 target:nil action:nil] autorelease];
	
	toobarTopItems = [[NSMutableArray arrayWithObjects:doneButton, spacer, title, spacer, reloadButton, nil] retain];
	[toobarTop setItems:toobarTopItems];
}

- (void)setupToolbarBottom {

	
	prevButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browser_icons_01.png"]
												  style:UIBarButtonItemStylePlain 
												 target:self		
												 action:@selector(prevButtonPushed:)];
	prevButton.enabled = NO;
	
	nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browser_icons_03.png"] 
												  style:UIBarButtonItemStylePlain 
												 target:self		
												 action:@selector(nextButtonPushed:)];
	nextButton.enabled = NO;
	
	UIBarButtonItem *safariButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browser_icons_05.png"]
																	  style:UIBarButtonItemStylePlain 
																	 target:self		
																	 action:@selector(safariButtonPushed:)] autorelease];
	
	UIBarButtonItem *tweetURLButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																					 target:self 
																					 action:@selector(tweetURLButtonPushed:)] 
									   autorelease];
	
	UIBarButtonItem *RILButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize 
																					 target:self 
																				action:@selector(saveToRILButtonPushed:)] 
									   autorelease];
	
	
	UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			 target:nil action:nil] autorelease];
	
	[toobarBottom setItems:[NSArray arrayWithObjects:prevButton, spacer, nextButton, spacer, tweetURLButton, spacer, RILButton, spacer, safariButton, nil]];
}

- (void) saveToRILButtonPushed:(id)sender {
	NSString *ril_username = [[NTLNAccount sharedInstance] ril_username];
	NSString *ril_password = [[NTLNAccount sharedInstance] ril_password];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[ReadItLater save:[NSURL URLWithString:url] 
				title:@"Saved from Tweetee" 
			 delegate:self 
			 username:ril_username 
			 password:ril_password];
}

- (void)reloadButtonPushed:(id)sender {
	if (loading) {
		[webView stopLoading];
	} else {
		[webView reload];
	}
}

- (void)doneButtonPushed:(id)sender {
	[webView stopLoading];
	[webView loadHTMLString:@"" baseURL:nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)prevButtonPushed:(id)sender {
	[webView goBack];
}

- (void)nextButtonPushed:(id)sender {
	[webView goForward];
}

- (void)safariButtonPushed:(id)sender {
	[[UIApplication sharedApplication] openURL:[[webView request] mainDocumentURL]];
}

- (void)tweetURLButtonPushed:(id)sender {
	//TODO: short URL before showing the pane used to compose the message
	NSString *longURL = [[[webView request] mainDocumentURL] absoluteString];
	NSString *shortURL = [self shortenURL:longURL];
	[[NTLNTwitterPost shardInstance] updateText:shortURL];
	[NTLNTweetPostViewController present:self];
}

- (void)updatePrevNextButton {
	prevButton.enabled = [webView canGoBack];
	nextButton.enabled = [webView canGoForward];
}

- (void)updateReloadButton {
	UIBarButtonSystemItem item;
	if (loading) {
		item = UIBarButtonSystemItemStop;
	} else {
		item = UIBarButtonSystemItemRefresh;
	}
	
	[reloadButton release];
	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item
																 target:self 
																 action:@selector(reloadButtonPushed:)];
	
	if (toobarTop.items.count > 0) {
		[toobarTopItems replaceObjectAtIndex:4 withObject:reloadButton];
		[toobarTop setItems:toobarTopItems];
	}
}

# pragma mark -
# pragma mark Read It Later delegate
-(void)readItLaterSaveFinished:(NSString *)stringResponse error:(NSString *)errorString {
	
	NSString *alertMsg;
	
	if (errorString != nil) {
		alertMsg = [NSString stringWithFormat:@"%@", errorString];
	} else {
		alertMsg = @"URL saved";
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Read It Later server said:" 
													message:alertMsg 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil]; 
	[alert show]; 
	[alert release]; 
}
-(void)readItLaterLoginFinished:(NSString *)stringResponse error:(NSString *)errorString {
	
}
-(void)readItLaterSignupFinished:(NSString *)stringResponse error:(NSString *)errorString {
	
}


#pragma mark -
#pragma mark utility and support methods
- (NSString*) shortenURL: (NSString*) f_longURL {
	
	NSString *BITLYAPIURL = @"http://api.bit.ly/%@?version=2.0.1&login=%@&apiKey=%@&";
	NSString *urlWithoutParams = [NSString stringWithFormat:BITLYAPIURL, @"shorten", BIT_LY_LOGIN, BIT_LY_APIKEYS];
	NSString *parameters = [NSString stringWithFormat:@"longUrl=%@", [f_longURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *finalURL = [urlWithoutParams stringByAppendingString:parameters];
	
	NSURL *_url = [NSURL URLWithString:finalURL];
	NSLog (@"shorting URL %@", f_longURL);
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:_url];
	
	NSHTTPURLResponse* urlResponse = nil;  
	NSError *error = [[[NSError alloc] init] autorelease];  
	
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&urlResponse error:&error];	
	
	if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
	{
		SBJSON *jsonParser = [SBJSON new];
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary *dict = (NSDictionary*)[jsonParser objectWithString:jsonString];
		[jsonString release];
		[jsonParser release];
		
		NSString *statusCode = [dict objectForKey:@"statusCode"];
		
		if([statusCode isEqualToString:@"OK"])
		{
			NSString *shortURL = [[[dict objectForKey:@"results"] 
								   objectForKey:f_longURL] 
								  objectForKey:@"shortUrl"];
			return shortURL;
		}
		else return nil;
		
	}
	else
		return nil;
}

@end
