#import <Foundation/Foundation.h>
#import "NTLNTwitterClient.h"
#import "NTLNMessage.h"

@interface NTLNTwitterPost : NSObject<NTLNTwitterClientDelegate> {
	NSString *text;
	UIImage *data_image; //The NSData version of an attached image
	NSString *backupFilename;
	NTLNMessage *replyMessage; 
}

@property (readonly) NTLNMessage *replyMessage;
@property (nonatomic, retain) UIImage *data_image;

+ (id)shardInstance;

- (void)updateText:(NSString*)text;
- (void)updateImage:(UIImage*)data_image;
- (void)post;

- (void)createReplyPost:(NSString*)reply_to withReplyMessage:(NTLNMessage*)message;
- (void)createDMPost:(NSString*)reply_to withReplyMessage:(NTLNMessage*)message;

- (NSString*)text;
- (UIImage *)data_image;

- (BOOL)isDirectMessage;

- (void)backupText;


@end
