//
//  Category.h
//  funMatch
//
//  Created by 谈 文钊 on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ModelObject.h"

typedef enum {
    CategorySubTypeBackground = 0,
    CategorySubTypeKind,
    CategorySubTypeBrand,
    CategorySubTypeHistory
} CategorySubType;

@class Category;

@interface SubCategory : ModelObject

@property (nonatomic) CategorySubType subType;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger subId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *typeKey; //subId parameter key
@property (nonatomic, retain) NSString *queryMethod; //load data method
@property (nonatomic, retain) NSMutableArray *contentList;
@property (nonatomic, assign) Category *category;

//@property (nonatomic, retain) NSMutableArray *goodsList;
//@property (nonatomic, retain) NSMutableArray *backgroundList;


- (void)loadContentsSucceed:(ModelDataLoadedSucceed)succeed
                      failed:(ModelDataLoadedFialed)failed;

- (void)loadMoreContentdSucceed:(ModelDataLoadedSucceed)succeed
                         failed:(ModelDataLoadedFialed)failed;

@end
