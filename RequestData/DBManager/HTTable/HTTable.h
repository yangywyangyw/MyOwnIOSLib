//
//  HTTable.h
//  EnterSQLIte
//
//  Created by wei yang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManageTableImp.h"

@interface HTTable : NSObject{
 @private
  // the table name.
  NSString *_tableName;
  
  //a dictionary that use property for its key and property type for its value
  NSMutableDictionary *_tableProperty;
  
  
  ManageTableImp *_manageTable;
}

@property (nonatomic,retain) NSString *tableName;
@property (nonatomic,retain) NSMutableDictionary *tableProperty;
@property (nonatomic,retain) ManageDatabaseImp *manageTable;

//init a table with table name..
- (id)initWithTableName:(NSString*)tableName;


//query record by where clause,groupby having and orderby
- (NSMutableArray*)queryRecord:(NSArray*)columns 
                UseWhereClause:(NSString*)whereClause
                       GroupBy:(NSString*)groupBy
                        Having:(NSString*)having
                       OrderBy:(NSString*)orderBy;

//list all record of the table
- (NSMutableArray*)listAllRecord;

//find one record just use where clause
- (NSMutableArray*)findRecord:(NSString*)whereClause;

//insert one record to the table
- (bool)insertSingleRecord:(NSDictionary*)record;

//delete one record to the table
- (bool)deleteSingleRecord:(NSString*)whereClause;


- (bool)modifySingleRecord:(NSDictionary*)newRecord 
            UseWhereClause:(NSString*)whereClause;
@end
