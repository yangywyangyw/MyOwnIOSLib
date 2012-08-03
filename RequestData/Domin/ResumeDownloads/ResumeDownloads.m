//
//  ResumeDownloads.m
//  RequestData
//
//  Created by Dean on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ResumeDownloads.h"

@implementation ResumeDownloads

@synthesize netWorkQueue = _netWorkQueue;
@synthesize downloadUrl = _downloadUrl;


- (id)init{

  if (self = [super init]) {
    _netWorkQueue = [[ASINetworkQueue alloc] init];
    [_netWorkQueue reset];
    [_netWorkQueue setShowAccurateProgress:YES];
    [_netWorkQueue go];
  }
  
  _downloadUrl = [[NSMutableDictionary alloc] init];
  
  return self;
}

- (void)dealloc{
  [super dealloc];
  [_netWorkQueue release];
  [_downloadUrl release];
}


- (void)downloadFile:(NSString*)fileName 
         DownLoadUrl:url
    ProgressDelegate:(id)progressDelegate{
  
  [_downloadUrl setObject:url forKey:fileName];
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
  NSString *folderPath = [path stringByAppendingPathComponent:@"DownloadTemp"];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  if (![fileManager fileExistsAtPath:folderPath]) {
    [fileManager createDirectoryAtPath:folderPath 
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
  }
  
  NSURL *downUrl = [NSURL URLWithString:url];
  ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:downUrl];
  request.delegate = self;
  NSString *savaPath = [path stringByAppendingPathComponent:fileName];
  NSString *tempPath = [path stringByAppendingPathComponent:
                        [NSString stringWithFormat:@"DownloadTemp/%@.temp",fileName]];
  [request setDownloadDestinationPath:savaPath];
  [request setTemporaryFileDownloadPath:tempPath];
  [request setDownloadProgressDelegate:progressDelegate];
  [request setAllowResumeForFileDownloads:YES];
  [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileName,@"FileName",nil]];
  [_netWorkQueue addOperation:request];
  
  [request release];
}

- (bool)pauseDownloadItem:(NSString*)pauseFileName{
  
  for (ASIHTTPRequest *request in [_netWorkQueue operations]) {
    NSString *fileName = [request.userInfo objectForKey:@"FileName"];
    if ([fileName isEqualToString:pauseFileName]) {
      [request clearDelegatesAndCancel];
      return YES;
    }
  }
  NSLog(@"pause download item failed... please,check the file name...");
  return NO;
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
  
  NSLog(@"begin download file %@",[request.userInfo objectForKey:@"FileName"]);
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *strContentLength = [NSString stringWithFormat:@"%@_ContentLength",[request.userInfo objectForKey:@"FileName"]];
  float contentLength = [[userDefaults objectForKey:strContentLength] floatValue];
  
  if (contentLength == 0) {
    [userDefaults setObject:[NSNumber numberWithFloat:request.contentLength/1024.0/1024.0] forKey:strContentLength];
  }
}

- (void)requestFinished:(ASIHTTPRequest *)request{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *strContentLength = [NSString stringWithFormat:@"%@_ContentLength",[request.userInfo objectForKey:@"FileName"]];
  float contentLength = [[userDefaults objectForKey:strContentLength] floatValue];

  if (contentLength > 0) {
    NSLog(@"download %@ finished...",[request.userInfo objectForKey:@"FileName"]);    
  }
  else{
    NSLog(@"download %@ failed... please check the url's effection...",[request.userInfo objectForKey:@"FileName"]);
  }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
  NSLog(@"download file %@ failed,please check whether the net is connective..",
        [request.userInfo objectForKey:@"FileName"]);
}
@end
