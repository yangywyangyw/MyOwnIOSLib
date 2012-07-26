//
//  FunMatchNetEngine.m
//  funMatch_iPad
//
//  Created by weiy on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FunMatchNetEngine.h"
#import "WBEngine.h"
#import "ASIFormDataRequest.h"
#import "UIDevice+IdentifierAddition.h"
#import "JSONKit.h"



@implementation NSObject (extend)

- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects {
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    
    NSUInteger i = 1;
    for (id object in objects) {
        [invocation setArgument:&object atIndex:++i];
    }
    [invocation invoke];
    
    if ([signature methodReturnLength]) {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    return nil;
}

@end


@implementation FunMatchNetEngine

@synthesize wbEngine = _wbEngine;
@synthesize requestList = _requestList;
@synthesize username = _username;
@synthesize size=_size;

- (void)dealloc
{
    if (loginSucceed) {
		[loginSucceed release];
		loginSucceed = nil;
	}
    if (loginFailed) {
		[loginFailed release];
		loginFailed = nil;
	}
    for(ASIFormDataRequest *request in self.requestList){
        [request clearDelegatesAndCancel];
    }
    // [_requestList makeObjectsPerformSelector:@selector(clearDelegatesAndCancel)];
    [_requestList release];
    [_wbEngine release];
    [_username release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        self.size=1;
        self.requestList = [NSMutableArray array];
    }
    return self;
}

- (void)setLoginSucceedBlock:(UserLoginSucceed)succed
{
    [loginSucceed release];
    loginSucceed = [succed copy];
}

- (void)setLoginFailedBlock:(RequestError)failed
{
    [loginFailed release];
    loginFailed = [failed copy];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    self.username = username;
    if (!self.wbEngine) {
        self.wbEngine = [[[WBEngine alloc] initWithAppKey:kAppKey appSecret:kAppSecret] autorelease];
        self.wbEngine.delegate = self;
        self.wbEngine.redirectURI = @"http://";
        self.wbEngine.isUserExclusive = NO;
    }
    [self.wbEngine logInUsingUserID:username password:password];
}

- (void)startRequestUseMethod:(NSString*)method
                       params:(NSDictionary*)params 
                     receiver:(id)receiver
                 onCompletion:(SEL)complete 
                completeParam:(NSMutableArray*)completeParams
                      onError:(SEL)errorFunc 
                   errorParam:(NSMutableArray*)errorParams{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kWebSiteURL, method]];
    DLog(@"Url:%@", url);
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [self.requestList addObject:request];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceSn = [device uniqueDeviceIdentifier];
    NSString *iosVersion = [device systemVersion];
    NSInteger deviceType = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1 : 2;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary]; //取出info文件里面的信息
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    // DLog(@"dic :%@",infoDictionary);
    //DLog(@"string :%@",appVersion);
    
    [request addPostValue:[NSNumber numberWithInt:deviceType] forKey:@"device_type"]; //设备类型
    [request addPostValue:deviceSn forKey:@"device_sn"]; //设备编号
    [request addPostValue:iosVersion forKey:@"ios_version"];  //客户端应用名及版本
    [request addPostValue:appVersion forKey:@"app_verion"];   //操作系统版本号
    
    for (NSString *key in [params keyEnumerator])
    {
        [request addPostValue:[params valueForKey:key] forKey:key];
    }
    
    [request setCompletionBlock:^{
        
        NSDictionary *jsonData = [request.responseString objectFromJSONString];
        DLog(@"response jsonData:%@", jsonData);
        NSInteger statusCode = [[jsonData valueForKey:@"status_code"] intValue];
        if (statusCode == 0 && ![jsonData isKindOfClass:[NSNull class]] && jsonData != nil) {
          if (completeParams == nil) {
            if ([receiver respondsToSelector:complete]) {
              [receiver performSelector:complete 
                            withObjects:[NSArray arrayWithObject:jsonData]];
            }
          }
          else
          {
            [completeParams addObject:jsonData];
            if ([receiver respondsToSelector:complete]) {
                [receiver performSelector:complete 
                              withObjects:completeParams];
            }
          }
        } else {
            NSString *errorMsg = [jsonData valueForKey:@"error_msg"];
            if (errorMsg == nil) errorMsg = @"";
            NSError *error = [NSError errorWithDomain:@"funMatch" code:statusCode 
                                             userInfo:[NSDictionary dictionaryWithObject:errorMsg 
                                                                                  forKey:@"error_msg"]];
            if ([receiver respondsToSelector:errorFunc]) {
                [receiver performSelector:errorFunc 
                              withObjects:[NSArray arrayWithObject:error]];
            }
        }
        [self.requestList removeObject:request];
    }];
    [request setFailedBlock:^{
        [self.requestList removeObject:request];
        if ([receiver respondsToSelector:errorFunc]){
            [receiver performSelector:@selector(errorFunc:) 
                          withObjects:[NSArray arrayWithObject:request.error]];
        }
    }];
    [request startAsynchronous];

}

#pragma mark - WBEngineDelegate Methods

#pragma mark Authorize

- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{
}

- (void)engineDidLogIn:(WBEngine *)engine
{
}

- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    loginFailed(error);
}

- (void)engineDidLogOut:(WBEngine *)engine
{
}

- (void)engineNotAuthorized:(WBEngine *)engine
{
    
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result  //返回登入数据
{
    
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    loginFailed(error);
}
@end
