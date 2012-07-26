//
//  CryptionUseSysLib.m
//  encoding
//
//  Created by Dean on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CryptionUseSysLib.h"


static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

@implementation CryptionUseSysLib


+ (NSString *) md5:(NSString *)str

{
	
	const char *cStr = [str UTF8String];
	
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString 
          
          stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
          
          result[0], result[1],
          
          result[2], result[3],
          
          result[4], result[5],
          
          result[6], result[7],
          
          result[8], result[9],
          
          result[10], result[11],
          
          result[12], result[13],
          
          result[14], result[15]
          
          ];
	
}

+ (NSData *)doCipher:(NSData *)sTextIn 
                 key:(NSData *)sKey
           Algorithm:(CCAlgorithm)algorithm 
             context:(CCOperation)encryptOrDecrypt {
	
  NSData * dTextIn;
  
  dTextIn = [sTextIn mutableCopy];    
  
  NSMutableData * dKey = [sKey mutableCopy];    
  int moreSize = 0;
  
  //make key to standard;
  switch (algorithm) {
    case kCCAlgorithmDES:
      moreSize = kCCBlockSizeDES;
      [dKey setLength:kCCKeySizeDES];
      break;
    case kCCAlgorithm3DES:
      moreSize = kCCBlockSize3DES;
      [dKey setLength:kCCKeySize3DES];        
      break;
    case kCCAlgorithmAES128:
      moreSize = kCCBlockSizeAES128;
      [dKey setLength:kCCKeySizeAES128];
      break;
    case kCCAlgorithmCAST:
      moreSize = kCCBlockSizeCAST;
      [dKey setLength:kCCKeySizeMaxCAST];
      break;
    case kCCAlgorithmRC4:
    case kCCAlgorithmRC2:
      moreSize = kCCBlockSizeRC2;
      [dKey setLength:kCCKeySizeMaxRC2];
       break;
    default:
      return nil;
      break;
  }
  
  uint8_t *bufferPtr1 = NULL;    
  size_t bufferPtrSize1 = 0;    
  size_t movedBytes1 = 0;
	unsigned char iv[8];
  memset(iv, 0, 8);
  
  bufferPtrSize1 = [sTextIn length] + moreSize;  

  bufferPtr1 = malloc(bufferPtrSize1);    
  memset((void *)bufferPtr1, 0, bufferPtrSize1);    
  
  // cryption....
  CCCryptorStatus ccStatus = CCCrypt(encryptOrDecrypt, // CCOperation op    
          algorithm, // CCAlgorithm alg    
          kCCOptionPKCS7Padding|kCCOptionECBMode, // CCOptions options    
          [dKey bytes], // const void *key    
          [dKey length], // size_t keyLength    
          iv, // const void *iv    
          [dTextIn bytes], // const void *dataIn
          [dTextIn length],  // size_t dataInLength    
          (void *)bufferPtr1, // void *dataOut    
          bufferPtrSize1,     // size_t dataOutAvailable 
          &movedBytes1);      // size_t *dataOutMoved    
  
  // output situation after crypt
  switch (ccStatus) {
    case kCCSuccess:
      NSLog(@"SUCCESS");
      break;
    case kCCParamError:
      NSLog(@"PARAM ERROR");
      break;
    case kCCBufferTooSmall:
      NSLog(@"BUFFER TOO SMALL");
      break;
    case kCCMemoryFailure:
      NSLog(@"MEMORY FAILURE");
      break;
    case kCCAlignmentError:
      NSLog(@"ALIGNMENT ERROR");
      break;
    case kCCDecodeError:
      NSLog(@"DECODE ERROR");
      break;
    case kCCUnimplemented:
      NSLog(@"UNIMPLEMENTED");
      break;
    default:
      break;
  }
  
  if (ccStatus == kCCSuccess){    
    NSData *result = [NSData dataWithBytes:bufferPtr1 length:movedBytes1];    
    free(bufferPtr1);
    return result;
  }    
  free(bufferPtr1);
  return nil;
}

+ (NSData*)doCipherUse3DesMethod:(NSData *)sTextIn 
                               key:(NSData *)sKey 
                           context:(CCOperation)encryptOrDecrypt{
  return [CryptionUseSysLib doCipher:sTextIn
                    key:sKey
              Algorithm:kCCAlgorithm3DES context:encryptOrDecrypt];
}

+ (NSData *) doCipherUseCastMethod:(NSData *)sTextIn
                              key:(NSData *)sKey 
                          context:(CCOperation)encryptOrDecrypt{
  
  return [CryptionUseSysLib doCipher:sTextIn
                                 key:sKey
                           Algorithm:kCCAlgorithmCAST context:encryptOrDecrypt];

}

+ (NSData*)doCipherUseDesMethod:(NSData *)sTextIn
                              key:(NSData *)sKey 
                          context:(CCOperation)encryptOrDecrypt{
  return [CryptionUseSysLib doCipher:sTextIn 
                    key:sKey 
              Algorithm:kCCAlgorithmDES 
                context:encryptOrDecrypt];
}

+ (NSData*)doCipherUseAesMethod:(NSData *)sTextIn
                              key:(NSData *)sKey 
                          context:(CCOperation)encryptOrDecrypt{
  return [CryptionUseSysLib doCipher:sTextIn 
                    key:sKey
              Algorithm:kCCAlgorithmAES128
                context:encryptOrDecrypt];
}

+ (NSString *)encodeBase64WithString:(NSString *)strData {
	return [CryptionUseSysLib encodeBase64WithData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)encodeBase64WithData:(NSData *)objData {

	const unsigned char * objRawData = [objData bytes];
	char * objPointer;
	char * strResult;
	
	// Get the Raw Data length and ensure we actually have data
	int intLength = [objData length];
	if (intLength == 0) return nil;
	
	// Setup the String-based Result placeholder and pointer within that placeholder
	strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
	objPointer = strResult;
	
	// Iterate through everything
	while (intLength > 2) { // keep going until we have less than 24 bits
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
		*objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
		*objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
		
		// we just handled 3 octets (24 bits) of data
		objRawData += 3;
		intLength -= 3; 
	}
	
	// now deal with the tail end of things
	if (intLength != 0) {
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		if (intLength > 1) {
			*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
			*objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
			*objPointer++ = '=';
		} else {
			*objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
			*objPointer++ = '=';
			*objPointer++ = '=';
		}
	}
	
	// Terminate the string-based result
	*objPointer = '\0';
	
	// Return the results as an NSString object
	return [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
}

+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
	const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
	int intLength = strlen(objPointer);
	int intCurrent;
	int i = 0, j = 0, k;
	
	unsigned char * objResult;
	objResult = calloc(intLength, sizeof(char));
	
	// Run through the whole string, converting as we go
	while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
		if (intCurrent == '=') {
			if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
				// the padding character is invalid at this point -- so this entire string is invalid
				free(objResult);
				return nil;
			}
			continue;
		}
		
		intCurrent = _base64DecodingTable[intCurrent];
		if (intCurrent == -1) {
			// we're at a whitespace -- simply skip over
			continue;
		} else if (intCurrent == -2) {
			// we're at an invalid character
			free(objResult);
			return nil;
		}
		
		switch (i % 4) {
			case 0:
				objResult[j] = intCurrent << 2;
				break;
				
			case 1:
				objResult[j++] |= intCurrent >> 4;
				objResult[j] = (intCurrent & 0x0f) << 4;
				break;
				
			case 2:
				objResult[j++] |= intCurrent >>2;
				objResult[j] = (intCurrent & 0x03) << 6;
				break;
				
			case 3:
				objResult[j++] |= intCurrent;
				break;
		}
		i++;
	}
	
	// mop things up if we ended on a boundary
	k = j;
	if (intCurrent == '=') {
		switch (i % 4) {
			case 1:
				// Invalid state
				free(objResult);
				return nil;
				
			case 2:
				k++;
				// flow through
			case 3:
				objResult[k] = 0;
		}
	}
	
	// Cleanup and setup the return NSData
	NSData * objData = [[[NSData alloc] initWithBytes:objResult length:j] autorelease];
	free(objResult);
	return objData;
}

@end
