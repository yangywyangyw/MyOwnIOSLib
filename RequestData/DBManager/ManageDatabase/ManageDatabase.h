//
//  ConnectDatabase.h
//  EnterSQLIte
//
//  Created by wei yang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ManageDatabase <NSObject>
@optional

//open the database..
- (void)openDatabase;

//close the database..
- (void)closeDatabase;

//init the database;
- (bool)initDatabase;

@end
