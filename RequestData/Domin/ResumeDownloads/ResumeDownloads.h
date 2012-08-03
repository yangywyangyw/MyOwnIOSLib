//
//  ResumeDownloads.h
//  RequestData
//
//  Created by Dean on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@interface ResumeDownloads : NSObject<ASIHTTPRequestDelegate>{
 @private
  ASINetworkQueue *_netWorkQueue;
  NSMutableDictionary *_downloadUrl;
}

@property (nonatomic,retain) ASINetworkQueue *netWorkQueue;
@property (nonatomic,retain) NSMutableDictionary *downloadUrl;

//pause a download item by file name...
- (bool)pauseDownloadItem:(NSString*)pauseFileName;


//begin or continue download a file...
- (void)downloadFile:(NSString*)fileName 
         DownLoadUrl:url
    ProgressDelegate:(id)progressDelegate;
@end
