//
//  NTLNCache.m
//  tweetee
//
//  Created by Takuma Mori on 08/08/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NTLNCache.h"


@implementation NTLNCache

+ (NSString*)createCacheDirectoryWithName:(NSString*)name {
   
//    
//.     Causes dialog pop-up at init of app
//.     createDirectoryAtPath:attributes: is deprecated
//.     name == "icon_cache" from NSLog
//.    
//    
    
    
    NSLog(@"WARNING__!__: %@", name);
//    original code
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
//    XXX Don't know if above attributes should be nil or not. Handles Permissions. 
//    
    
    
	path = [NSString stringWithFormat:@"%@/%@", path, name];
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL ];
	return [path stringByAppendingString:@"/"];
    
// modified to fit below
//    NSFileManager   *defaultManager;
//    NSString        *filename      = name;
//    NSString        *tildeFilename;
    
//    tildeFilename = [NSString stringWithFormat: @"~/%@", filename]; //puts tilde infront,  ~/filename
//    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"%@", filename];
    //[defaultManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
//    [defaultManager createFileAtPath:path contents:self attributes:nil];
//    NSLog(@"WARNING__!__: %@", [tildeFilename stringByAppendingFormat:@"/"]);
//    return [tildeFilename stringByAppendingFormat:@"/"];
    
    
//    NSString *filename = @"/my/original/file/name";
//    NSString *tildeFilename;
//    tildeFilename = [NSString stringWithFormat: @"%@~", filename];
//    
//    // remove it first, otherwise the move will fail
//    [defaultManager removeFileAtPath: tildeFilename
//                             handler: nil];
//    
//    // now rename the file
//    [defaultManager movePath: filename
//                      toPath: tildeFilename
//                     handler: nil];

}



//
//. Creates caches for icons, archiver, and text backup
//.
//
+ (NSString*)createIconCacheDirectory {
	return [self createCacheDirectoryWithName:@"icon_cache"];
}

+ (NSString*)createArchiverCacheDirectory {
	return [self createCacheDirectoryWithName:@"archiver_cache"];
}

+ (NSString*)createTextCacheDirectory {
	return [self createCacheDirectoryWithName:@"text_backup"];
}

+ (void)saveWithFilename:(NSString*)filename data:(NSData*)data {
//	LOG(@"Write cache to:%@", filename);
	[[NSFileManager defaultManager] createFileAtPath:filename contents:data attributes:nil];
}

+ (NSData*)loadWithFilename:(NSString*)filename {
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:filename];
	NSData *ret = nil;
	if (fh) {
//		LOG(@"Read cache from:%@", filename);
		ret = [fh readDataToEndOfFile];
		[fh closeFile];
		//[ret retain];
		//[fh release];
	}
	return ret;
}

+ (void)removeAllCachedData {
	[[NSFileManager defaultManager] removeItemAtPath:[NTLNCache createIconCacheDirectory] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[NTLNCache createArchiverCacheDirectory] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[NTLNCache createTextCacheDirectory] error:nil];
}

@end
