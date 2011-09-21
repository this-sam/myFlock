#import "NTLNTweetPostViewController.h"
#import "NTLNAppDelegate.h"
#import "NTLNAccount.h"
#import "NTLNCache.h"
#import "NTLNConfiguration.h"
#import "NTLNTwitterPost.h"

#import "bit_ly_apikeys.h"

#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"
#import "JSON.h"




@interface NTLNTweetPostViewController(Private)
UIView * activityView;

- (IBAction)closeButtonPushed:(id)sender;
- (IBAction)sendButtonPushed:(id)sender;
- (IBAction)trashButtonPushed:(id)sender;
- (IBAction)cameraButtonPushed:(id)sender;
- (IBAction)audioButtonPushed:(id)sender;
- (IBAction)linkButtonPushed:(id)sender;
- (IBAction)actionButtonPressed:(id)sender;
- (void) setUpActivityIndicator:(BOOL) show;

- (NSString*) shortenURL: (NSString*) f_longURL;
@end

static NTLNTweetPostViewController *_tweetViewController;

@implementation NTLNTweetPostViewController

@synthesize imageToPost;
@synthesize locationManager;
@synthesize strLocationURL;


+ (BOOL)active {
	return _tweetViewController ? YES : NO;
}

+ (void)dismiss {
	[_tweetViewController dismissModalViewControllerAnimated:NO];
	[_tweetViewController release];
	_tweetViewController = nil;
}

+ (void)present:(UIViewController*)parentViewController {
	[NTLNTweetPostViewController dismiss];
	NTLNTweetPostViewController *vc = [[[NTLNTweetPostViewController alloc] init] autorelease];
	[parentViewController presentModalViewController:vc animated:NO];
	_tweetViewController = [vc retain];
}

- (void)updateViewColors {
	UIColor *textColor, *backgroundColor, *backgroundColorBottom;
	if ([[NTLNConfiguration instance] darkColorTheme]) {
		textColor = [UIColor whiteColor];
		if ([[NTLNTwitterPost shardInstance] isDirectMessage]) {
			backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.5f alpha:1.f];
		} else {
			backgroundColor = [UIColor colorWithWhite:61.f/255.f alpha:1.0f];
		}
		backgroundColorBottom = [UIColor colorWithWhite:24.f/255.f alpha:1.0f];
	} else {
		textColor = [UIColor blackColor];
		if ([[NTLNTwitterPost shardInstance] isDirectMessage]) {
			backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:1.f alpha:1.f];
		} else {
			backgroundColor = [UIColor colorWithWhite:252.f/255.f alpha:1.0f];
		}
		backgroundColorBottom = [UIColor colorWithWhite:200.f/255.f alpha:1.0f];
	}
	
	self.view.backgroundColor = backgroundColorBottom;//[UIColor blackColor];
	
	tweetPostView.textView.textColor = textColor;
	tweetPostView.textView.backgroundColor = backgroundColor;
	
	if ([[NTLNTwitterPost shardInstance] replyMessage]) {
		tweetPostView.backgroundColor = backgroundColorBottom;
	} else {
		tweetPostView.backgroundColor = backgroundColor;
	}
	
	if ([[NTLNConfiguration instance] darkColorTheme]) {
		// to use black keyboard appearance
		tweetPostView.textView.keyboardAppearance = UIKeyboardAppearanceAlert;
	} else {
		// to use default keyboard appearance
		tweetPostView.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
	}
}

- (void)setupViews {

	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	
	UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	toolbar.barStyle = UIBarStyleBlackTranslucent;
    /*
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] 
									initWithTitle:@"close" 
									style:UIBarButtonItemStyleBordered 
									target:self action:@selector(closeButtonPushed:)] autorelease];
	*/
	UIBarButtonItem *clearButton = [[[UIBarButtonItem alloc] 
									initWithTitle:@"close" 
									style:UIBarButtonItemStyleBordered 
									target:self action:@selector(closeButtonPushed:)] autorelease];
	
	UIView *expandView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 193, 44)] autorelease];

	textLengthView = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 115, 34)];
	textLengthView.font = [UIFont boldSystemFontOfSize:20];
	textLengthView.textAlignment = UITextAlignmentRight;
	textLengthView.textColor = [UIColor whiteColor];
	textLengthView.backgroundColor = [UIColor clearColor];
	textLengthView.text = @"140";
	
	[expandView addSubview:textLengthView];
	
	UIBarButtonItem	*expand = [[[UIBarButtonItem alloc] initWithCustomView:expandView] autorelease];
	
	UIBarButtonItem *sendButton = [[[UIBarButtonItem alloc] 
									initWithTitle:@"post" 
									style:UIBarButtonItemStyleBordered 
									target:self action:@selector(sendButtonPushed:)] autorelease];
	
	[toolbar setItems:[NSArray arrayWithObjects:clearButton, expand, sendButton, nil]];
	
	
	tweetPostView = [[NTLNTweetPostView alloc] initWithFrame:CGRectMake(0, 44, 320, 200)];
	tweetPostView.textViewDelegate = self;
	
	UIToolbar *bottonbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 200, 320, 44)] autorelease];
	bottonbar.barStyle = UIBarStyleBlackTranslucent;
	
	UIBarButtonItem *cameraButton = [[[UIBarButtonItem alloc] 
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCamera 
									 target:self
									 action:@selector(cameraButtonPushed:)] autorelease];
	/*
	UIBarButtonItem *audioButton = [[[UIBarButtonItem alloc]
									 initWithImage:[UIImage imageNamed:@"icons_07.png"]
									 style:UIBarButtonItemStylePlain
									 target:self 
									 action:@selector(closeButtonPushed:)] autorelease];
	*/
	UIBarButtonItem *linkButton = [[[UIBarButtonItem alloc]
									 initWithImage:[UIImage imageNamed:@"icons_08.png"]
									 style:UIBarButtonItemStylePlain
									 target:self 
									 action:@selector(linkButtonPushed:)] autorelease];

	UIView *buttonExpandView = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, 133, 24)] autorelease];
	
	UIBarButtonItem	*buttonExpand = [[[UIBarButtonItem alloc] initWithCustomView:buttonExpandView] autorelease];
	
	UIBarButtonItem *trashButton = [[[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
									target:self
									action:@selector(trashButtonPushed:)] autorelease];
	
	UIBarButtonItem *actionButton = [[[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemAction
									 target:self
									 action:@selector(actionButtonPressed:)] autorelease];
	
	[bottonbar setItems:[NSArray arrayWithObjects:cameraButton, linkButton, buttonExpand, trashButton, actionButton, nil]];	

	imagePresentIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(290, 170, 25, 25)] autorelease];
	[imagePresentIcon setImage:[UIImage imageNamed:@"icons_10.png"]];
	[self.view addSubview:toolbar];
	[self.view addSubview:tweetPostView];
	[self.view addSubview:imagePresentIcon];
	[self.view addSubview:bottonbar];
	[self updateViewColors];
	
	imagePresentIcon.hidden = YES;
	imageToPost = [[UIImage alloc] init];
	
	//Setup di activityIndicatorView
	activityView =[[UIView alloc] initWithFrame:CGRectMake(50, 90, 230, 150)];
	activityView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
	
	UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] 
									initWithFrame:CGRectMake(90, 20, 50, 50)];
	[act setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 230, 30)];
	label.text = @"Getting location...";
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:20];
	label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.01];
	
	[act startAnimating];
	[activityView addSubview:act];
	[activityView addSubview:label];
	
	[label release];
	[act release];
}

- (void) setUpActivityIndicator:(BOOL) show {
	//[self.view addSubview:activityView];	
}

- (void)setMaxTextLength {
	maxTextLength = 140;
	NSString *footer = [[NTLNAccount sharedInstance] footer];
	if (footer && [footer length] > 0 && 
		! [[NTLNTwitterPost shardInstance] isDirectMessage]) {
		maxTextLength -= [footer length] + 1;
	}
}

- (void)updateTextLengthView {
	[self setMaxTextLength];
	int len = [tweetPostView.textView.text length];
	[textLengthView setText:[NSString stringWithFormat:@"%d", (maxTextLength-len)]];
	if (len >= maxTextLength) {
		textLengthView.textColor = [UIColor redColor];
	} else {
		textLengthView.textColor = [UIColor whiteColor];
	}	
}

- (void)viewDidLoad {
	[self setMaxTextLength];
	[self setupViews];
	[self updateTextLengthView];
	pictureIsPresent = NO;
	[super viewDidLoad];
}

- (void)dealloc {
	LOG(@"NTLNTweetPostViewController dealloc");
	[tweetPostView release];
	[textLengthView release];
	[locationManager release];
	[strLocationURL release];
	[activityView release];
	[super dealloc];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[self updateViewColors];
	tweetPostView.textView.text = [[NTLNTwitterPost shardInstance] text];
	[tweetPostView.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[tweetPostView.textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
	[[NTLNTwitterPost shardInstance] updateText:tweetPostView.textView.text];
	[self updateTextLengthView];
	[self updateViewColors];
	[tweetPostView updateQuoteView];
}

# pragma mark -
# pragma IBActions

- (IBAction)closeButtonPushed:(id)sender {
	[tweetPostView.textView resignFirstResponder];
	[NTLNTweetPostViewController dismiss];
}

- (IBAction)trashButtonPushed:(id)sender {
	tweetPostView.textView.text = @""; // this will invoke textViewDidChange
	self.imageToPost = nil;
	pictureIsPresent = NO;
	imagePresentIcon.hidden = YES;
}

- (IBAction)sendButtonPushed:(id)sender {
	[[NTLNTwitterPost shardInstance] updateText:tweetPostView.textView.text];
	[[NTLNTwitterPost shardInstance] updateImage:self.imageToPost];
	[[NTLNTwitterPost shardInstance] post];
	
	[tweetPostView.textView resignFirstResponder];
	[NTLNTweetPostViewController dismiss];
}

- (IBAction)cameraButtonPushed:(id)sender {
	
	if (pictureIsPresent) {
		UIActionSheet *mangePhotoActionSheet = [[UIActionSheet alloc]
												 initWithTitle:@"" 
												 delegate:self 
												 cancelButtonTitle:@"Cancel" 
												 destructiveButtonTitle:@"Delete" 
												 otherButtonTitles:@"Choose an other", nil];
		mangePhotoActionSheet.actionSheetStyle=UIActionSheetStyleBlackOpaque;
		mangePhotoActionSheet.tag=2;
		[mangePhotoActionSheet showInView:self.view];
		[mangePhotoActionSheet release];
	} else {
		[self showImagePicker:0];
	}
}

- (IBAction)linkButtonPushed:(id)sender {
	
	//find a URL to short inside the text and short it
	NSString *strURLToShort = [tweetPostView.textView.text stringByMatching:@"http[a-zA-Z0-9.:/]*"];
	NSString *strShortURL = [self shortenURL:strURLToShort];
	
	if (strShortURL != nil) {
		NSString *replacedString = [tweetPostView.textView.text stringByReplacingOccurrencesOfRegex:@"http[a-zA-Z0-9.:/]*" 
																						withString:strShortURL]; 
		tweetPostView.textView.text = replacedString;
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No URL found inside the text" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release]; 
	}
}

- (IBAction)actionButtonPressed:(id)sender {
	

	UIActionSheet *otherButtonActionSheet = [[UIActionSheet alloc]
											 initWithTitle:@""
											 delegate:self 
											 cancelButtonTitle:@"Cancel" 
											 destructiveButtonTitle:nil
											 otherButtonTitles:@"Add a 'I'm here' link", nil];
	otherButtonActionSheet.actionSheetStyle=UIActionSheetStyleBlackOpaque;
	otherButtonActionSheet.tag = 1;
	[otherButtonActionSheet showInView:self.view];
	[otherButtonActionSheet release];
}
						
#pragma mark -
#pragma mark UIImagePickerController delegate
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
		  didFinishPickingImage:(UIImage *)image
					editingInfo:(NSDictionary *)editingInfo {
	
	self.imageToPost = image;
	[picker dismissModalViewControllerAnimated:YES];
	pictureIsPresent = YES;
	
	if (pictureIsPresent) {
		imagePresentIcon.hidden = NO;
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// OtheractionSheet
	if (actionSheet.tag == 1) {

		switch (buttonIndex) {
			case 0: //add 'I'm here link' was pressed
				[self locateme];
				break;
			default:
				break;
		}
		
	}
	
	//mangePhotoActionSheet
	if (actionSheet.tag == 2) {
		switch (buttonIndex) {
			case 0: // Remove Picture
				imageToPost = nil;
				pictureIsPresent = NO;
				imagePresentIcon.hidden = YES;
				break;
			case 1: //choose an other picture
				[self showImagePicker:0];
				break;
			default:
				break;
		}
	}
	
	//cameraActionSheet
	if (actionSheet.tag == 3) {
		switch (buttonIndex) {
			case 0: //take from camera
				[self showImagePicker:1];
				break;
			case 1:
				[self showImagePicker:2];
				break;
			default:
				break;
		}
	}
}

#pragma mark -
#pragma mark utility and support methods

- (NSString *) shortenURL:(NSString *)f_longURL {
	NSString *urlString = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", [f_longURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	NSLog(@"calling %@ to short location URL", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request start];
	NSError *error = [request error];
	NSString *response = [request responseString];
	
	if (!error) {
		return response;
	} else {
		return @"error";
	}
}


/*
- (NSString*) shortenURL: (NSString*) f_longURL {
	
	NSString *BITLYAPIURL = @"http://api.bit.ly/%@?version=2.0.1&login=%@&apiKey=%@&";
	NSString *urlWithoutParams = [NSString stringWithFormat:BITLYAPIURL, @"shorten", BIT_LY_LOGIN, BIT_LY_APIKEYS];
	NSString *parameters = [NSString stringWithFormat:@"longUrl=%@", [f_longURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	NSString *finalURL = [urlWithoutParams stringByAppendingString:parameters];
	
	NSLog(@"calling %@ to short URL", finalURL);
	
	NSURL *url = [NSURL URLWithString:finalURL];
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
	
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
*/
- (void) showImagePicker:(int)sourceType {

	UIImagePickerController *picker = [[UIImagePickerController alloc] init];

	if (sourceType == 0) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			// show an actionsheet to select camera or album
			UIActionSheet *sourceSelectionAS = [[UIActionSheet alloc]
													 initWithTitle:@""
													 delegate:self 
													 cancelButtonTitle:nil 
													 destructiveButtonTitle:nil
													 otherButtonTitles:@"Take from camera", nil];
			[sourceSelectionAS addButtonWithTitle:@"Choose from library"];
			[sourceSelectionAS addButtonWithTitle:@"Cancel"];
			sourceSelectionAS.actionSheetStyle=UIActionSheetStyleBlackOpaque;
			sourceSelectionAS.tag = 3;
			[sourceSelectionAS showInView:self.view];
			[sourceSelectionAS release];
		} else {
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentModalViewController:picker animated:YES];
			picker.delegate = self;
			[picker release];			
		}
	}
	
	if (sourceType == 1) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:picker animated:YES];
		picker.delegate = self;
		[picker release];
		return;
	}
	
	if (sourceType == 2) {
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:picker animated:YES];
		picker.delegate = self;
		[picker release];		
	}
}

- (void) waitForLocation {
	
		
		NSLog(@"waitForLocation....");
		while (strLocationURL == nil) {
		}
		
		NSLog(@"waitForLocation ended");		

}

- (void) locateme {
	self.locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	
	//[tweetPostView.textView resignFirstResponder];
	[self.view addSubview:activityView];
	[locationManager startUpdatingLocation];
}



-(UIImage*)resizeImage:(UIImage*)inImage { 
	
	CGImageRef			imageRef = [inImage CGImage];
	CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGRect	thumbRect;
	
	// There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
	// see Supported Pixel Formats in the Quartz 2D Programming Guide
	// Creating a Bitmap Graphics Context section
	// only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
	// and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
	// The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	// Build a bitmap context that's the size of the thumbRect
	CGFloat bytesPerRow;
	
	thumbRect.size.width = inImage.size.width/3;
	thumbRect.size.height = inImage.size.height/3;
	
	if( thumbRect.size.width > thumbRect.size.height ) {
		bytesPerRow = 4 * thumbRect.size.width;
	} else {
		bytesPerRow = 4 * thumbRect.size.height;
	}
	
	CGContextRef bitmap = CGBitmapContextCreate(	
												NULL,
												thumbRect.size.width,		// width
												thumbRect.size.height,		// height
												8, //CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
												bytesPerRow, //4 * thumbRect.size.width,	// rowbytes
												CGImageGetColorSpace(imageRef),
												alphaInfo
												);
	
	// Draw into the context, this scales the image
	CGContextDrawImage(bitmap, thumbRect, imageRef);
	
	// Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage*	result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
	
	return result;
}



#pragma mark -
#pragma mark CLLocationManager delegate methods

-(void) locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	
	[locationManager stopUpdatingLocation];
	[activityView removeFromSuperview];

	
	if ( (strLocationURL == nil) && ![strLocationURL isEqualToString:@"NOT"]) {
		
		strLocationURL = [[NSString alloc] initWithFormat:@"http://maps.google.com?q=%g %g", 
						  newLocation.coordinate.latitude, newLocation.coordinate.longitude];
		
		tweetPostView.textView.text = [tweetPostView.textView.text stringByAppendingString:@"I'm here "];
		tweetPostView.textView.text = [tweetPostView.textView.text stringByAppendingString:[self shortenURL:strLocationURL]];
		
	}
}

- (void) locationManager:(CLLocationManager *)manager
		didFailWithError:(NSError *)error {	
	strLocationURL = @"NOT";
	NSLog(@"[DEBUG] location manager did fail with error: %@", error);
	[activityView removeFromSuperview];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}


@end
