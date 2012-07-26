//
//  ManageTableImp.m
//  EnterSQLIte
//
//  Created by wei yang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ManageTableImp.h"


@implementation ManageTableImp

const char* dbName = "FunMatch.sqlite";

- (id)init{
  
  if(self = [super initWithDBName:[NSString stringWithFormat:@"%s",dbName]]){
    [self openDatabase];
    [self initDatabase];
  }
  return  self;
}

- (void)dealloc{
  [self closeDatabase];
  [super dealloc];
}

- (id)initWithDBName:(NSString *)dbName{
  if (self = [super init]) {
    [super initWithDBName:dbName];
    [self openDatabase];
  }
  return self;
}

- (bool)execFuncWithSql:(const char*)sql 
             SuccessMsg:(NSString*)okMsg 
                FailMsg:(NSString*)failMsg{
  char *errorMsg;
  
  //execute a sql commond and log the information of the result..
  if([self my_sqlite_exec:sql ErrorMsg:&errorMsg] == SQLITE_OK){
    NSLog(@"%@",okMsg);
    return YES;
  }
  
  else{
    NSLog(@"%@",failMsg);
    [self ErrorMsg:sql];
    return NO;
  }

}

- (bool)createTableBySqlString:(const char*)sql{
  
  return [self execFuncWithSql:sql 
            SuccessMsg:@"create table success." 
                FailMsg:@"create table fail"];

}

- (bool)insertBySqlString:(const char*)sql{

  return [self execFuncWithSql:sql 
             SuccessMsg:@"insert data success." 
                FailMsg:@"insert data fail"];

}

- (bool)deleteBySqlString:(const char*)sql{

  return [self execFuncWithSql:sql 
             SuccessMsg:@"delete data success." 
                FailMsg:@"delete data fail"];

}

- (bool)UpdateBySqlString:(const char *)sql{

  return [self execFuncWithSql:sql
                    SuccessMsg:@"update data success"
                       FailMsg:@"update data fail."];

}

- (NSMutableDictionary*)getPropertyAndTypeByTableName:(NSString *)tableName{
  
  sqlite3_stmt *statement;
  NSMutableDictionary *propertyAndType = [NSMutableDictionary dictionary];
  NSString *sql = [NSString stringWithFormat:@"select*from %@",tableName];
  
  //get the column infoamtion to use the interface of sqlite_prepare_v2..
  if ([self my_sqlite_prepare_v2:[sql UTF8String] 
                          NBytes:-1
                       Statement:&statement
                            Tail:nil] == SQLITE_OK){
  
    int columnCount = sqlite3_column_count(statement);
    for (int i = 0; i < columnCount; i++) {
      NSString *columnName = [NSString stringWithFormat:@"%s",sqlite3_column_name(statement, i)];
   //   NSLog(@"%d",sqlite3_column_type(statement, i));
   //   NSLog(@"%@",columnName);
      NSNumber *type = [NSNumber numberWithInt:sqlite3_column_type(statement, i)];
      [propertyAndType setObject:type forKey:columnName];
    }
    sqlite3_finalize(statement);
    return propertyAndType;
  }
  
  else{
    [self ErrorMsg:[sql UTF8String]];
    return nil;
  }
  
}
- (NSMutableArray*)queryBySqlString:(const char*)sql ColumnCount:(unsigned int)columnCount{

  sqlite3_stmt *statement;
  NSMutableArray *allRecord = [NSMutableArray array];
  
  //query the table to use the interface of sqlite_prepare_v2..
  if ([self my_sqlite_prepare_v2:sql 
                          NBytes:-1
                       Statement:&statement
                            Tail:nil] == SQLITE_OK){
    NSLog(@"select suscess..");
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
      NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
      for (int i = 0; i < columnCount; i++) {
        if (sqlite3_column_text(statement, i) == NULL) {
          continue;
        }
        NSString *value=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, i) encoding:NSUTF8StringEncoding];
        NSString *key = [[NSString alloc] initWithCString:(char *)sqlite3_column_name(statement, i) encoding:NSUTF8StringEncoding];
        [record setObject:value forKey:key];
        [value release];
        [key release];
      }
      [allRecord addObject:record];
      [record release];
    }
  }
  
  else{
    [self ErrorMsg:sql];
    return nil;
  }
  
  sqlite3_finalize(statement);
  return allRecord;
}
@end
