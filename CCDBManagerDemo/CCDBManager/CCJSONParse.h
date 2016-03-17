/*---------------------------------------------------------------------
 文件名称 : CCJSONParse
 创建作者 : Cole
 创建时间 : 2015-10-03
 文件描述 : 解析类，实现对象和字典无缝转换
 ---------------------------------------------------------------------*/

#import <Foundation/Foundation.h>

@protocol JSONEntityElementProtocol <NSObject>

@optional
/*  帮助你快速设置JSON和对象属性的映射表(解决接口返回相同对象名称的问题)
 *  key:   中间层命名
 *  value: 客户端命名
 */
+ (NSDictionary *)replacedElementDictionary;

@end

@interface NSObject (CCJSONParse)<JSONEntityElementProtocol>

/** 对象 -> 字典 */
- (NSDictionary *)propertyDictionary;
/** 字典 -> 对象 */
+ (id<JSONEntityElementProtocol>)objectWithDictionary:(NSDictionary *)dictionary;


/** 获取对象的属性列表 ，每获取propertyName运行Block一次 */
+ (NSArray *)propertyNamesUntilClass:(Class)sCls usingBlock:(void (^)(NSString *propertyName, NSString *propertyType))block;

@end
