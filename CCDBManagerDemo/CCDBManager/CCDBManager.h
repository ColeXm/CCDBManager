//
//  CCDBManager.h
//  CCDBManager
//
//  Created by ColeXm on 16/3/16.
//  Copyright © 2016年 ColeXm. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCDBManager : NSObject

//初始化文件名
- (id)initDBWithName:(NSString *)dbName;
//创建表
- (void)createTable:(NSString *)tableName;
//清理表
- (void)clearTable:(NSString *)tableName;


/** 保存&&更新 */
- (BOOL)setObject:(id)anObject forKey:(NSString*)key table:(NSString *)tableName;

/** 获取 */
- (id)objectForKey:(NSString *)key table:(NSString *)tableName;

/** 移除 */
- (BOOL)removeObjectForKey:(NSString *)key table:(NSString *)tableName;



#pragma mark - extension

- (NSArray *)getAllItemsFromTable:(NSString *)tableName;

- (NSUInteger)getCountFromTable:(NSString *)tableName;

- (BOOL)removeObjectForKeyArray:(NSArray *)keyArray table:(NSString *)tableName;

- (BOOL)removeObjectForKeyPrefix:(NSString *)keyPrefix table:(NSString *)tableName;

@end
