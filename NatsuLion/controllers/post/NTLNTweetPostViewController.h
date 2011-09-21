#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NTLNTweetPostView.h"

#import "MBProgressHUD.h"


@class NTLNAppDelegate;

@interface NTLNTweetPostViewController : UIViewController <UITextViewDelegate, 
	UIImagePickerControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate, UINavigationControllerDelegate> {
	NTLNTweetPostView *tweetPostView;
	UILabel *textLengthView;
	UILabel *bBarDescView;
	UIImage *imageToPost;
	int maxTextLength;
	BOOL pictureIsPresent;

		
	CLLocationManager *locationManager;
	NSString *strLocationURL;
		

	UIImageView *imagePresentIcon;
		
	MBProgressHUD *HUD;
}

@property (nonatomic, retain) UIImage *imageToPost;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *strLocationURL;

+ (void)present:(UIViewController*)parentViewController;
+ (void)dismiss;
+ (BOOL)active;

- (void) locateme;
- (void) showImagePicker:(int)sourceType;
- (UIImage *) resizeImage:(UIImage *)inImage;
- (NSString*) shortenURL: (NSString*) f_longURL;

@end
