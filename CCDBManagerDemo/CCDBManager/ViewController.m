//
//  ViewController.m
//  CCDBManager
//
//  Created by ColeXm on 16/3/16.
//  Copyright © 2016年 ColeXm. All rights reserved.
//

#import "ViewController.h"
#import "CCDBManager.h"
#import "Model.h"
#import "CCJSONParse.h"

NSString *const tableName = @"user_table";
NSString *const dbName = @"test.db";

@implementation ViewController{

    CCDBManager *store;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    store = [[CCDBManager alloc] initDBWithName:dbName];
    
    //清表
    [store clearTable:tableName];
    //创表
    [store createTable:tableName];
    
    /*只支持集合和模型，array，dic或者model  ,简单类型存储请走沙盒……*/
    
    
    [self storeArray];
    
    [self storeDic];
    
    
    [self storeObj];
    
    [self remove];
}

-(void)storeArray{
    NSString *key = @"1";
    NSArray *user = @[@"11",@"22"];
    [store setObject:user forKey:key table:tableName];
    
    NSLog(@"query data result: %@", [store objectForKey:key table:tableName]);
}

-(void)storeDic{
    NSString *key = @"1222";
    NSDictionary *user = @{@"id": @1, @"name": @"tangqiao", @"age": @30};
    [store setObject:user forKey:key table:tableName];
    
    NSLog(@"query data result: %@", [store objectForKey:key table:tableName]);

}

-(void)storeObj{
    NSString *key = @"test";

    Model *user = [Model new];
    user.title = @"test";
    user.msg = @(222);
    //存
    [store setObject:user forKey:key table:tableName];
    //取
    id result = [store objectForKey:key table:tableName];
    
    NSLog(@"query data result: %@", result);
    
    
    
}
     
     
-(void)remove{
    [store removeObjectForKeyPrefix:@"12" table:tableName];
     
    id result = [store getAllItemsFromTable:tableName];
    
     NSLog(@"query data result: %@", result);

}

@end
