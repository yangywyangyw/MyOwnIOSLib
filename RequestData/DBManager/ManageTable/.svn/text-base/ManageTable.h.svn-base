//
//  ManageTable.h
//  EnterSQLIte
//
//  Created by wei yang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ManageTable <NSObject>

@optional

// get a table information of property and property type and set it into a dictionary..
- (NSMutableDictionary*)getPropertyAndTypeByTableName:(NSString*)tableName;

//use a sql sentence to create a table..
- (bool)createTableBySqlString:(const char*)sql;

//use a sql sentence to insert a record to table..
- (bool)insertBySqlString:(const char*)sql;

//use a sql sentece to query the table..
- (NSMutableArray*)queryBySqlString:(const char*)sql ColumnCount:(int) columnCount;

//use a sql sentence to delete some record of the table..
- (bool)deleteBySqlString:(const char*)sql;

//use a sql sentence to modify the table record..
- (bool)UpdateBySqlString:(const char*)sql;

@end
