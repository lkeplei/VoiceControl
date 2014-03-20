//
//  MACoreDataManager.h
//  SanGameJJH
//
//  Created by apple on 14-3-13.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
//引入CoreData框架
#import <CoreData/CoreData.h>

#define KCoreVoiceFiles         @"MAVoiceFiles"

@interface MACoreDataManager : NSObject

+(MACoreDataManager*)sharedCoreDataManager;

/**
 *  安全退出，如果上下文有改变，做数据保存
 */
-(void)safelyExit;

/**
 *  保存上下文修改
 *
 *  @return 保存成功返回yes，否则返回no
 */
-(BOOL)saveEntry;

/**
 *  删除一行
 *
 *  @param entry 要删除的实体
 *
 *  @return 成功返回yes，否则返回no
 */
-(BOOL)deleteObject:(NSManagedObject*)entry;

/**
 *  删除表
 *
 *  @param object 要删除的表名
 *
 *  @return 成功返回yes，否则返回no
 */
-(BOOL)deleteEntry:(NSString*)object;

/**
 *  获取查询数据
 *
 *  @param object  要查询的数据表
 *  @param sortKey 排序sort key
 *
 *  @return 返回查询结果数组
 */
-(NSArray*)queryFromDB:(NSString*)object sortKey:(NSString*)sortKey;

/**
 *  获取一个新的实例
 *
 *  @param object  数据表
 *
 *  @return 返回一个数据表结构的一个新实例
 */
-(NSManagedObject*)getNewManagedObject:(NSString*)object;

-(NSArray*)getMAVoiceFile:(NSString*)name;
@end
