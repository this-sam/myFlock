#import <UIKit/UIKit.h>
#import "NTLNAccelerometerSensor.h"
#import "NTLNWebView.h"

#import "ReadItLaterLite.h"

@interface NTLNBrowserViewController : UIViewController<UIWebViewDelegate,ReadItLaterDelegate> {
	NSString *url;
	NTLNWebView *webView;
	UIToolbar *toobarTop;
	UIToolbar *toobarBottom;

	BOOL loading;
	
	UIBarButtonItem *title;
	UIBarButtonItem *reloadButton;
	UIBarButtonItem *prevButton;
	UIBarButtonItem *nextButton;

	NSMutableArray *toobarTopItems;
}

@property (readwrite, retain) NSString *url;

@end
