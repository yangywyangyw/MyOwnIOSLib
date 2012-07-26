//
//  ManageDatabaseImp.h
//  EnterSQLIte
//
//  Created by wei yang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManageDatabase.h"
#import "/usr/include/sqlite3.h"

@interface ManageDatabaseImp : NSObject

- (id)initWithDBName:(NSString*)dbName;

//use sqlite_prepare_v2 interface to package my own prepare_v2 
- (int)my_sqlite_prepare_v2:(const char*)sql 
                     NBytes:(int)nbytes 
                  Statement:(sqlite3_stmt**)stmt
                       Tail:(const char**)tail;

//use sqlite_exec interface to package my own sqlite_exec
- (int)my_sqlite_exec:(const char*)sql ErrorMsg:(char**)errMsg;

//get error information..
- (bool)ErrorMsg:(const char*)item;

@end
