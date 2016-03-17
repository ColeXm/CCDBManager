//
//  NSObject+CCParse.m
//  CCNetwork
//
//  Created by Cole on 15/10/2.
//  Copyright © 2015年 Cole. All rights reserved.
//

#import "CCJSONParse.h"
#import <objc/runtime.h>

@implementation NSObject (CCJSONParse)

#pragma mark - 获取当前对象的属性集合
- (id)propertyValueWithObject:(id)obj
{
    id propertyValue = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        propertyValue = [obj propertyArray];
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        propertyValue = [obj p_propertyDictionary];
    }
    else if ([obj isKindOfClass:[NSString class]]||[obj isKindOfClass:[NSNumber class]]) {
        propertyValue = obj;
    }
    else {
        propertyValue = [obj propertyDictionary];
    }
    return propertyValue;
}

- (NSArray *)propertyArray
{
    __block NSMutableArray *propertyArray = [NSMutableArray array];
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *array = [NSArray arrayWithArray:(NSArray *)self];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id propertyValue = [self propertyValueWithObject:obj];
            if (propertyValue) [propertyArray addObject:propertyValue];
        }];
    }
    return propertyArray;
}

- (NSDictionary *)propertyDictionary {
    __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    Class cls = [self class];
    [[self class] propertyNamesUntilClass:cls usingBlock:^(NSString *propertyName, NSString *propertyType) {
        id propertyValue = [self valueForKey:propertyName];
        if(propertyValue) {
            id value = nil;
            if ([propertyValue isKindOfClass:[NSObject class]]) {
                if ([propertyValue isKindOfClass:[NSArray class]]) {
                    value = [propertyValue propertyArray];
                }
                else if ([propertyValue isKindOfClass:[NSDictionary class]]) {
                    value = [propertyValue p_propertyDictionary];
                }
                else if ([propertyValue isKindOfClass:[NSNumber class]] ||
                         [propertyValue isKindOfClass:[NSString class]] ||
                         [propertyValue isKindOfClass:[NSNull class]]) {
                    value = propertyValue;
                }
                else {
                    value = [propertyValue propertyDictionary];
                }
            }
            if (value) [dictionary setValue:value forKey:propertyName];
        }
    }];
    return dictionary;
}

- (NSDictionary *)p_propertyDictionary
{
    __block NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionary];
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:(NSDictionary *)self];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id propertyValue = [self propertyValueWithObject:obj];
            if (propertyValue) [propertyDictionary setObject:propertyValue forKey:key];
        }];
    }
    return propertyDictionary;
}


#pragma mark - 对象的属性列表
+ (NSArray *)propertyNamesUntilClass:(Class)sCls usingBlock:(void (^)(NSString *propertyName, NSString *propertyType))block
{
    Class cls = [self class];
    NSMutableArray *mArray = [NSMutableArray array];
    while ((cls != [NSObject class]) && (cls != [sCls superclass])) {
        unsigned propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        for ( int i = 0 ; i < propertyCount ; i++ ) {
            objc_property_t property = properties[i];
            const char *propertyAttributes = property_getAttributes(property);
            BOOL isReadWrite = (strstr(propertyAttributes, ",V") != NULL);
            if (isReadWrite) {
                NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
                if (propertyName) [mArray addObject:propertyName];
                NSString *propertyType = nil;
                char *propertyAttributeValue = property_copyAttributeValue(property, "T");
                if ((propertyAttributeValue != NULL) && (propertyAttributeValue[0] == '@') && (strlen(propertyAttributeValue) >= 3)) {
                    propertyType = [NSString stringWithCString:strndup(propertyAttributeValue+2, strlen(propertyAttributeValue)-3) encoding:NSUTF8StringEncoding];
                }
                if (block) block(propertyName, propertyType);
            }
        }
        cls = [cls superclass];
        free(properties);
    }
    return mArray;
}


#pragma mark - 根据数据集合&类型，获取对象
+ (id<JSONEntityElementProtocol>)objectWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    Class rspClass = [self class];
    id responseObject = [[rspClass alloc] init];
    
    NSAssert(responseObject, @"对象创建失败:验证%@类是否存在或@implementation是否实现", NSStringFromClass(rspClass));
    
    if ([dictionary count] <= 0) return responseObject;
    [rspClass propertyNamesUntilClass:[NSObject class] usingBlock:^(NSString *propertyName, NSString *propertyType) {
        id propertyValue = dictionary[propertyName];
        if (propertyValue) {
            if ([propertyValue isKindOfClass:[NSDictionary class]]) {
                id propertyObject = nil;
                NSString *propertyClassName = nil;
                if ([self respondsToSelector:@selector(replacedElementDictionary)]) {
                    NSDictionary *replacedDictionary = [self performSelector:@selector(replacedElementDictionary)];
                    propertyClassName = replacedDictionary[propertyName];
                }
                propertyClassName = propertyClassName ?: propertyType;
                if (propertyClassName) {
                    Class cls = NSClassFromString(propertyClassName);
                    if ([cls isSubclassOfClass:[NSDictionary class]])
                    {
                        propertyObject = propertyValue;
                    }
                    else
                    {
                        propertyObject = cls ? [cls objectWithDictionary:propertyValue] : propertyValue;
                    }
                }
                else {  //propertyType为nil代表类型可能是id
                    Class cls = NSClassFromString(propertyName);
                    propertyObject = cls ?[cls objectWithDictionary:propertyValue] : propertyValue;
                }
                [responseObject setValue:propertyObject forKey:propertyName];
            }
            else if ([propertyValue isKindOfClass:[NSArray class]]) {
                NSString *propertyClassName = nil;
                if ([self respondsToSelector:@selector(replacedElementDictionary)]) {
                    NSDictionary *replacedDictionary = [self performSelector:@selector(replacedElementDictionary)];
                    propertyClassName = replacedDictionary[propertyName];
                }
                propertyClassName = propertyClassName ?: propertyName;
                Class cls = NSClassFromString(propertyClassName);
                id propertyObject = cls ? [cls objectWithArray:propertyValue] : propertyValue;
                [responseObject setValue:propertyObject forKey:propertyName];
            }
            else if ([propertyValue isKindOfClass:[NSNull class]]) { }
            else {
                [responseObject setValue:propertyValue forKey:propertyName];
            }
        }
    }];
    return responseObject;
    
}



+ (id)objectWithArray:(NSArray *)array
{
    NSMutableArray *propertyArray = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]]) {
        for (id obj in array) {
            id propertyValue = nil;
            if ([obj isKindOfClass:[NSDictionary class]]) {
                propertyValue = [self objectWithDictionary:obj];
            }
            else if ([obj isKindOfClass:[NSArray class]]) {
                propertyValue = [self objectWithArray:obj];
            }
            else propertyValue = obj;
            if (propertyValue) [propertyArray addObject:propertyValue];
        }
    }
    return propertyArray;
}

@end
