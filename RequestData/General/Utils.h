//
//  Utils.h
//  funMatch_iPad
//
//  Created by Dean on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define RELEASE_SAFELY(obj) [obj release]; obj = nil;

@interface Utils : NSObject

#pragma mark save / restore map state
+(NSString *)applicationDocumentsDirectory:(NSString *)filename;
+(NSString *)applicationCachesDirectory:(NSString *)filename;

#pragma mark -
#pragma mark Bookmark load ans save
+(void)saveData:(id)dataToSave to:(NSString *)filename;
+(id)loadDataFrom:(NSString *)filename;
+(void)alertWithTitle:(NSString *)title message:(NSString *)message;
+(NSString *)md5:(NSString *)str;
+(BOOL)versionGE:(NSString *)version;

typedef void (^PhotoLibraryLoadedSucceed)(NSArray *photos);
typedef void (^PhotoLibraryLoadedFialed)(NSError *error);

+ (void)enumerateAssetsLibrary:(ALAssetsLibrary *)assetsLibrary succeed:(PhotoLibraryLoadedSucceed)succeed failed:(PhotoLibraryLoadedFialed)failed;

@end
