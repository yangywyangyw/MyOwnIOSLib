//
//  NSStringCategory.m
//  funMatch_iphone
//
//  Created by Dean on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSStringCategory.h"

@implementation NSString(NSStringUTF8)

- (id)encodedURLByEncoding:(NSStringEncoding)stringEncoding {
	NSString *newString = [(NSString *)CFURLCreateStringByAddingPercentEscapes(
																			   kCFAllocatorDefault,
																			   (CFStringRef)self,
																			   NULL,
																			   CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), 
																			   CFStringConvertNSStringEncodingToEncoding(stringEncoding)) autorelease];
	if (newString) {
		return newString;
	}
	return self;
}


@end
