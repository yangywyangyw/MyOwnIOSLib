//
//  Category.m
//  funMatch
//
//  Created by 谈 文钊 on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SubCategory.h"
#import "Goods.h"
#import "Background.h"
#import "MatchUser.h"
#import "Utils.h"

@interface SubCategory()
{
    int page;
    int pageSize;
}
@property (nonatomic, retain) FunMatchEngine *matchEngine;
@end

@implementation SubCategory

@synthesize subType = _subType;
@synthesize subId = _subId;
@synthesize size = _size;
@synthesize name = _name;
@synthesize typeKey = _typeKey;
@synthesize queryMethod = _queryMethod;
@synthesize contentList = _contentList;
@synthesize category = _category;

@synthesize matchEngine = _matchEngine;

//@synthesize goodsList = _goodsList;
//@synthesize backgroundList = _backgroundList;

- (void)dealloc
{
    [_name release];
    [_typeKey release];
    [_queryMethod release];
    [_contentList release];
    [_matchEngine release];
//    [_goodsList release];
//    [_backgroundList release];
    [super dealloc];
}

- (id)initWithAttributes:(NSDictionary *)attributes
{
    if (self = [super init]) {
        self.subId = [[attributes valueForKey:@"sub_id"] integerValue];
        self.name = [attributes valueForKey:@"name"];
    }
    return self;
}

- (void)loadSucceed:(ModelDataLoadedSucceed)succeed
             failed:(ModelDataLoadedFialed)failed
{
    if (!self.contentList) self.contentList = [NSMutableArray array];
    if (self.subType == CategorySubTypeHistory) 
    {
        //load local data
        if (self.subId == 0) {
            self.contentList = [Utils loadDataFrom:kHistorFilename];
        } else {
            MatchUser *user = [Utils loadDataFrom:kMatchUserFilename];
            self.contentList = [Utils loadDataFrom:[NSString stringWithFormat:@"%@%@",user.matchUserId,kSaveGoodsFilePath]];
        }
        succeed();
    } 
    else if (self.subType == CategorySubTypeBackground && [self.name isEqualToString:@"我的背景"]) 
    {
        MatchUser *user=[Utils loadDataFrom:kMatchUserFilename];
        if (user && !user.isLogout) {
            [user queryBackgroundpage:page
                             pageSize:pageSize
                           Completion:^{
                               self.contentList = user.backgroundList;
                               self.size = user.backgroundListCount;
                               succeed();
                           } onError:^(NSError *error) {
                               failed(error);
                           }];
        } else succeed();
        
    }
    else 
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:[NSNumber numberWithInt:self.subId] forKey:self.typeKey];
        [params setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        [params setValue:[NSNumber numberWithInt:pageSize] forKey:@"page_size"];
       
        __block FunMatchEngine *matchEngine = [[FunMatchEngine alloc] init];
        [matchEngine startRequestMethod:self.queryMethod
                                 params:params
                           onCompletion:^(id result) {
                               self.size = [[result valueForKey:@"size"] integerValue];
                               if (self.subType == CategorySubTypeKind || self.subType == CategorySubTypeBrand) {     //goods
                                   NSArray *goodsArray = [result valueForKey:@"goods_list"];
                                   for (NSDictionary *goodsDic in goodsArray)
                                   {
                                       Goods *goods = [[Goods alloc] initWithAttributes:goodsDic];
                                       [self.contentList addObject:goods];
                                       [goods release];
                                   }
                               } else {     //background
                                   if (self.contentList.count == 0) {
                                       Background *emptyBackground = [[Background alloc] init];
                                       [self.contentList addObject:emptyBackground];
                                       [emptyBackground release];
                                   }
                                   NSArray *backgroundArray = [result valueForKey:@"bg_list"];
                                   for (NSDictionary *bgDic in backgroundArray)
                                   {
                                       Background *background = [[Background alloc] initWithAttributes:bgDic];
                                       [self.contentList addObject:background];
                                       [background release];
                                   }
                               }
                               succeed();
                               [matchEngine release];
                               matchEngine = nil;
                           } onError:^(NSError *error) {
                               failed(error);
                               [matchEngine release];
                               matchEngine = nil;
                           }];
        
    }
    
/*
    if (self.matchEngine == nil) self.matchEngine = [[[FunMatchEngine alloc] init] autorelease];
    NSString *typeKey = @"";
    NSString *queryMethod = @"";
    if (self.catType == CategoryTypeKind) {typeKey = @"type_id"; queryMethod = kGoodsQueryTypePath;}
    else if (self.catType == CategoryTypeBrand) {typeKey = @"brand_id"; queryMethod = kGoodsQueryBrandPath;}
    else if (self.catType == CategoryTypeBackground) {typeKey = @"type"; queryMethod = kGoodsQueryBackgroundPath;}
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInt:self.subId] forKey:typeKey];
    [params setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setValue:[NSNumber numberWithInt:pageSize] forKey:@"page_size"];
    [self.matchEngine startRequestMethod:queryMethod
                                  params:params
                            onCompletion:^(id result) {
                                self.size = [[result valueForKey:@"size"] integerValue];
                                
                                if (self.catType == CategoryTypeKind || self.catType == CategoryTypeBrand) {
                                    if (self.goodsList == nil) self.goodsList= [NSMutableArray array];
//                                    [self.goodsList removeAllObjects];
                                    NSArray *goodsArray = [result valueForKey:@"goods_list"];
                                    for (NSDictionary *goodsDic in goodsArray)
                                    {
                                        Goods *goods = [[Goods alloc] initWithAttributes:goodsDic];
                                        [self.goodsList addObject:goods];
                                        [goods release];
                                    }
                                    
                                } else {
                                    if (self.backgroundList == nil) self.backgroundList = [NSMutableArray array];
//                                    [self.backgroundList removeAllObjects];
                                    if (self.backgroundList.count == 0) {
                                        Background *emptyBackground = [[Background alloc] init];
                                        [self.backgroundList addObject:emptyBackground];
                                        [emptyBackground release];
                                    }
                                    
                                    NSArray *backgroundArray = [result valueForKey:@"bg_list"];
                                    for (NSDictionary *bgDic in backgroundArray)
                                    {
                                        Background *background = [[Background alloc] initWithAttributes:bgDic];
                                        [self.backgroundList addObject:background];
                                        [background release];
                                    }
                                }
                                succeed();
                                
                            } onError:^(NSError *error) {
                                failed(error);
                            }];
*/
}

- (void)loadContentsSucceed:(ModelDataLoadedSucceed)succeed
                      failed:(ModelDataLoadedFialed)failed;
{
    page = 1;
    pageSize = 40;
//    [self.goodsList removeAllObjects];
//    [self.backgroundList removeAllObjects];
    [self.contentList removeAllObjects];
    [self loadSucceed:succeed failed:failed];
}

- (void)loadMoreContentdSucceed:(ModelDataLoadedSucceed)succeed
                         failed:(ModelDataLoadedFialed)failed;
{
    page++;
    [self loadSucceed:succeed failed:failed];
}

@end
