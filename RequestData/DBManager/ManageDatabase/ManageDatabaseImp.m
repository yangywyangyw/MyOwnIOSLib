//
//  ManageDatabaseImp.m
//  EnterSQLIte
//
//  Created by wei yang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ManageDatabaseImp.h"

@interface ManageDatabaseImp()<ManageDatabase>
@property (nonatomic,retain) NSString *dbName;
@property (nonatomic,assign) sqlite3 *database;
@end

@implementation ManageDatabaseImp
@synthesize database = _database;
@synthesize dbName = _dbName;

- (void)openDatabase{
  
  NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  
  NSString *databaseFilePath = [[documentsPaths objectAtIndex:0] stringByAppendingFormat:_dbName];
  
  NSLog(databaseFilePath);
  if(sqlite3_open([databaseFilePath UTF8String], &_database) == SQLITE_OK){
    NSLog(@"open sqlite db ok..");
  }
  else{
    NSLog(@"can not open sqlite db..");
    sqlite3_close(_database);
  }
}

- (bool)ErrorMsg:(const char*)item{
  char *errorMsg;
  
  if (sqlite3_exec(self.database,(const char*)item, NULL, NULL, &errorMsg) == SQLITE_OK) {
    NSLog(@"%@ ok.",item);
    return YES;
  }
  else{
    NSLog(@"error: %s",errorMsg);
    sqlite3_free(errorMsg);
    return NO;
  }
}

- (int)my_sqlite_prepare_v2:(const char*)sql 
                     NBytes:(int)nbytes 
                  Statement:(sqlite3_stmt**)stmt
                       Tail:(const char**)tail{
  return sqlite3_prepare_v2(self.database, sql, nbytes, stmt, tail);
}

- (int)my_sqlite_exec:(const char *)sql ErrorMsg:(char **)errMsg{
  return sqlite3_exec(self.database, sql, nil, nil, errMsg);
}

- (void)closeDatabase{
  
  sqlite3_close(_database);
  NSLog(@"close sqlite db..");

}

- (id)initWithDBName:(NSString *)dbName{

  if (self = [super init]) {
    _dbName = dbName;
  }
  
  return self;
}

- (bool)initDatabase{
  return YES;
}

@end
