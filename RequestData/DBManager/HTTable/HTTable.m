//
//  HTTable.m
//  EnterSQLIte
//
//  Created by wei yang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>
#import "HTTable.h"


@implementation HTTable

@synthesize tableName = _tableName;
@synthesize tableProperty = _tableProperty;
@synthesize manageTable = _manageTable;

- (id)init{
  if (self = [super init]) {
    _manageTable = [[ManageTableImp alloc] init];
  }
  return self;
}

- (id)initWithTableName:(NSString *)tableName{
  if(self = [super init]){
    _tableName = tableName;
     _manageTable = [[ManageTableImp alloc] init];
    _tableProperty = [_manageTable getPropertyAndTypeByTableName:tableName];
  }
  return self;
}

- (void)dealloc{
  
  [super dealloc];
  [_manageTable release];

}

- (bool)checkRecord:(id)record{
  unsigned int propertyCount = 0;
  id tableProperty;

  objc_property_t *propertyList = class_copyPropertyList([record class], &propertyCount);
  
  for (int i = 0; i < propertyCount; i++) {
    objc_property_t *thisProperty = propertyList + i;
    const char *propertyName = property_getName(*thisProperty);
    id strProperty = [NSString stringWithFormat:@"%s",propertyName];
    NSEnumerator *tableProperties = [_tableProperty keyEnumerator];
    bool existInTableProperty = NO;
    while ((tableProperty = [tableProperties nextObject])) {  
 //     NSLog(strProperty);
 //     NSLog(tableProperty);
      if ([strProperty isEqualToString:tableProperty]) {
        existInTableProperty = YES;
        break;
      }
    }
    if (existInTableProperty == NO) {
      NSLog(@"data model name(%@) different from the table property name..",strProperty);
      return NO;
    }
  }
  return YES;
}

- (NSMutableArray*)queryRecord:(NSArray*)columns 
                UseWhereClause:(NSString*)whereClause
                       GroupBy:(NSString*)groupBy
                        Having:(NSString*)having
                       OrderBy:(NSString*)orderBy 
                         CLazz:(Class)cls{
  
  //link a select sql sentence..
  NSString *querySql = [NSString stringWithFormat:@"select "];
 
  //link the colums..
  if (columns == nil) {
    querySql = [querySql stringByAppendingFormat:@"*"];
  }
  
  else{
    for (int i = 0; i < [columns count]; i++) {
      querySql = [querySql stringByAppendingFormat:@" %@,",[columns objectAtIndex:i]];
    }
    querySql = [querySql substringToIndex:[querySql length] - 1];
  }
  
  //link groupby having and orderby..
  NSString *where = [NSString stringWithFormat:@"where "];
  if (whereClause != nil) {
    where = [where stringByAppendingString:whereClause];
    whereClause = where;
  }
  whereClause == nil ? whereClause = [NSString stringWithFormat:@""]:whereClause;
  groupBy == nil ? groupBy = [NSString stringWithFormat:@""]:groupBy;
  having == nil ? having = [NSString stringWithFormat:@""]:having;
  orderBy == nil ? orderBy = [NSString stringWithFormat:@""]:orderBy;
  
  querySql = [querySql stringByAppendingFormat:@"from %@ %@ %@ %@ %@",_tableName,whereClause,
              groupBy,having,
              orderBy];
  NSArray *propertyName = [_tableProperty allValues]; 
  int columnCount = [propertyName count];
  return [_manageTable queryBySqlString:[querySql cStringUsingEncoding:NSUTF8StringEncoding]
                            ColumnCount:columnCount 
                                  CLazz:cls];
}

- (NSMutableArray*)listAllRecord:(Class)cls{
  return [self queryRecord:nil UseWhereClause:nil GroupBy:nil Having:nil OrderBy:nil CLazz:cls];
}

- (NSMutableArray*)findRecord:(NSString *)whereClause 
                        CLazz:(Class)cls{
  return [self queryRecord:nil UseWhereClause:whereClause GroupBy:nil Having:nil OrderBy:nil CLazz:cls];
}

- (bool)insertSingleRecord:(id)record{
  
  if([self checkRecord:record] == NO){
    return NO;
  }
  
  //link a insert sentence.. 
  NSString *insertSql = [NSString stringWithFormat:@"insert into %@ (",_tableName];

  unsigned int propertyCount = 0;  
  Ivar *propertyList = class_copyIvarList([record class], &propertyCount);
  
  //link the property
  for (int i = 0; i < propertyCount; i++) {
    Ivar *thisProperty = propertyList + i;
    const char *propertyName = ivar_getName(*thisProperty);
    id strProperty = [NSString stringWithCString:propertyName 
                                        encoding:NSUTF8StringEncoding];
    insertSql = [insertSql stringByAppendingFormat:@"%@,",strProperty];
  }
  
  //link the value of property..
  insertSql = [insertSql substringToIndex:[insertSql length] - 1];
  insertSql = [insertSql stringByAppendingFormat:@") values("];
  
  //propertyList = class_copyPropertyList([record class], &propertyCount);
  propertyList = class_copyIvarList([record class], &propertyCount);
  for (int i = 0; i < propertyCount; i++) {
    Ivar *thisProperty = propertyList + i;
    const char *propertyName = ivar_getName(*thisProperty);
    id strProperty = [NSString stringWithCString:propertyName 
                                        encoding:NSUTF8StringEncoding];
    id propertyType = [_tableProperty objectForKey:strProperty];
  //  Ivar propertyValue = class_getClassVariable([record class], propertyName);
    id propertyValue = [record valueForKey:strProperty];
    //NSLog(@"%@  = %@",strProperty, value1);
    switch ([propertyType intValue]) {
      case SQLITE_INTEGER:
        insertSql = [insertSql stringByAppendingFormat:@"%d,",propertyValue];
        break;
      case SQLITE_FLOAT:
        insertSql = [insertSql stringByAppendingFormat:@"%f,",propertyValue];
      case SQLITE_TEXT:
        insertSql = [insertSql stringByAppendingFormat:@"'%@',",propertyValue];
      default:
        insertSql = [insertSql stringByAppendingFormat:@"'%@',",propertyValue];
        break;
    }
  }
  
  insertSql = [insertSql substringToIndex:[insertSql length] - 1];
  insertSql = [insertSql stringByAppendingFormat:@")"];
  
  return [_manageTable insertBySqlString:[insertSql UTF8String]];
  
}

- (bool)deleteSingleRecord:(NSString*)whereClause{
  
  // link a delete sentence..
  
  NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where ",_tableName];
  
  whereClause == nil ? whereClause = [NSString stringWithFormat:@""]:whereClause;
  
  deleteSql = [deleteSql stringByAppendingFormat:@"%@",whereClause];
  
  return [_manageTable deleteBySqlString:[deleteSql UTF8String]];
}

- (bool)modifySingleRecord:(id)newRecord 
            UseWhereClause:(NSString*)whereClause{
  
  if([self checkRecord:newRecord] == NO){
    return NO;
  }
  
  //link a update sentence..
  NSString *modifySql = [NSString stringWithFormat:@"update %@ set ",_tableName];
  
  //check the type of the property
  unsigned int propertyCount = 0;
  Ivar* propertyList = class_copyIvarList([newRecord class], &propertyCount);
  
  for (int i = 0; i < propertyCount; i++) {
    Ivar *thisProperty = propertyList + i;
    const char *propertyName = ivar_getName(*thisProperty);
    id strProperty = [NSString stringWithCString:propertyName 
                                        encoding:NSUTF8StringEncoding];
    id propertyType = [_tableProperty objectForKey:strProperty];
    modifySql = [modifySql stringByAppendingFormat:@"%@ = ",strProperty];
 //   Ivar propertyValue = class_getClassVariable([newRecord class], propertyName);
    id propertyValue = [newRecord valueForKey:strProperty];
    switch ([propertyType intValue]) {
      case SQLITE_INTEGER:
        modifySql = [modifySql stringByAppendingFormat:@"%d,",propertyValue];
        break;
      case SQLITE_FLOAT:
        modifySql = [modifySql stringByAppendingFormat:@"%f,",propertyValue];
      case SQLITE_TEXT:
        modifySql = [modifySql stringByAppendingFormat:@"'%@',",propertyValue];
      default:
        modifySql = [modifySql stringByAppendingFormat:@"'%@',",propertyValue];
        break;
    }
  }

  modifySql = [modifySql substringToIndex:[modifySql length] - 1];
  
  whereClause == nil ? whereClause = [NSString stringWithFormat:@""]:whereClause;
  
  modifySql = [modifySql stringByAppendingFormat:@" where %@",whereClause];
  
  return [_manageTable UpdateBySqlString:[modifySql UTF8String]];
}


@end