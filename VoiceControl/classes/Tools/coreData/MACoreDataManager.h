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

typedef enum {
    MACoreDataUnknow = 0,
    
    MACoreDataMTGoodsJSCJ = 10,//模拟交易-即使建仓
    MACoreDataMTGoodsGDJY,//模拟交易-挂单交易
} MACoreDataType;

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

@end
