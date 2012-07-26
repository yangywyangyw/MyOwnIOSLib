//
//  CryptionUseSysLib.h
//  encoding
//
//  Created by Dean on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface CryptionUseSysLib : NSObject{

}

+ (NSData *) md5:(NSString *)str;


+ (NSData *) doCipherUseAesMethod:(NSData *)sTextIn
                                key:(NSData *)sKey 
                            context:(CCOperation)encryptOrDecrypt;

+ (NSData *) doCipherUse3DesMethod:(NSData *)sTextIn
                                key:(NSData *)sKey 
                            context:(CCOperation)encryptOrDecrypt;

+ (NSData *) doCipherUseDesMethod:(NSData *)sTextIn
                                key:(NSData *)sKey 
                            context:(CCOperation)encryptOrDecrypt;

+ (NSData *) doCipherUseCastMethod:(NSData *)sTextIn
                              key:(NSData *)sKey 
                          context:(CCOperation)encryptOrDecrypt;

+ (NSString *) encodeBase64WithString:(NSString *)strData;

+ (NSString *) encodeBase64WithData:(NSData *)objData;

+ (NSData *) decodeBase64WithString:(NSString *)strBase64;

@end