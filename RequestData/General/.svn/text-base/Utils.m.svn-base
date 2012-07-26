//
//  Utils.m
//  funMatch_iPad
//
//  Created by Dean on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(void)alertWithTitle:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title
													 message:message
													delegate:nil
										   cancelButtonTitle:@"好"
										   otherButtonTitles:nil]
						  autorelease];
	[alert show];
}

+ (NSString *)applicationDocumentsDirectory:(NSString *)filename
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString *appendPath = filename;		
    return [basePath stringByAppendingPathComponent:appendPath];
}

+(NSString *)applicationCachesDirectory:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
														 NSUserDomainMask,
														 YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingPathComponent:filename];
}

#pragma mark -
#pragma mark Bookmark load ans save
+(id)loadDataFrom:(NSString *)filename
{
	NSString *filePath = [Utils applicationDocumentsDirectory:filename];
	//NSLog(@"load filePath: %@", filePath);
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		NSData *data = [[NSMutableData alloc]
						initWithContentsOfFile:filePath];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]
										 initForReadingWithData:data];
		id result = [unarchiver decodeObjectForKey:@"data"];
		[unarchiver finishDecoding];
		[unarchiver release];
		[data release];
		return result;
	}
	else
	{
		return nil;
	}
}

+(void)saveData:(id)dataToSave to:(NSString *)filename
{
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
								 initForWritingWithMutableData:data];
	[archiver encodeObject:dataToSave forKey:@"data"];
	[archiver finishEncoding];
	NSString *filePath = [Utils applicationDocumentsDirectory:filename];
	//NSLog(@"save filePath: %@", filePath);
	[data writeToFile:filePath atomically:YES];
	[archiver release];
	[data release];
}


+(NSString *)md5:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			]; 
}

+(NSString *)md5sum:(NSString*)str {
    
    
    unsigned char digest[16], i;
    
    CC_MD5([str UTF8String], [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    NSMutableString *ms = [NSMutableString string];
    
    for (i=0;i<16;i++) {
        
        [ms appendFormat: @"x", (int)(digest[i])];
        
    }
    
    return [[ms copy] autorelease];
    
} 


+(BOOL)versionGE:(NSString *)version
{
    
    //    return NO;
	NSString *deviceVersion = [UIDevice currentDevice].systemVersion;
	return [deviceVersion compare:version] >= NSOrderedSame;
}

+ (void)enumerateAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                       succeed:(PhotoLibraryLoadedSucceed)succeed
                        failed:(PhotoLibraryLoadedFialed)failed;
{
    void (^assetGroupEnumerator)( ALAssetsGroup *, BOOL* ) = ^(ALAssetsGroup *group, BOOL *stop) 
    {
        if (group == nil) 
        {
            return;
        }
        
        NSMutableArray *photos = [NSMutableArray array];
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil) return;
            if ([result isKindOfClass:[ALAsset class]]) {
                [photos addObject:result];
            }
        }];
        
        succeed(photos);
    };
    
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        
        failed(error);
        //[Utils alertWithTitle:@"出错啦!" message:@"未能读取照片库"];
        
    };	
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:assetGroupEnumerator
                               failureBlock:assetGroupEnumberatorFailure];          
}


@end
