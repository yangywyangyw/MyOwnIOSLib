//
//  FunMatchNetEngine.h
//  funMatch_iPad
//
//  Created by weiy on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBEngine.h"

//sina
#define kAppKey @"4176796878"
#define kAppSecret @"c85201313c66d97f0547222b0498617e"


//#define kWebSiteURL  @"http://trandsda.hortor.net"
#define kWebSiteURL  @"http://buyer.test.hortor.net"


typedef void (^RequestCompletion)(id result);
typedef void (^RequestError)(NSError *error);

typedef void (^UserLoginSucceed)(void);
typedef void (^ListLoaded)(NSArray *matchList);

@interface FunMatchNetEngine : NSObject<WBEngineDelegate>
{
 @private
    UserLoginSucceed loginSucceed;
    RequestError loginFailed;
} 
@property (nonatomic, retain)WBEngine *wbEngine;
@property (nonatomic, retain)NSString *username;
@property(nonatomic,assign)NSInteger size;
@property (nonatomic, retain) NSMutableArray *requestList;

- (void)setLoginSucceedBlock:(UserLoginSucceed)succed;
- (void)setLoginFailedBlock:(RequestError)failed;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password;

- (void)startRequestUseMethod:(NSString*)method
                       params:(NSDictionary*)params 
                     receiver:(id)receiver
                 onCompletion:(SEL)complete 
                completeParam:(NSMutableArray*)completeParams
                      onError:(SEL)error 
                   errorParam:(NSMutableArray*)errorParams; 

@end
