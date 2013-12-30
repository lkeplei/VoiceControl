//
//  MADataManager.h
//  SanGameJJH
//
//  Created by ken on 13-5-23.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MADataManager : NSObject

+(MADataManager*)shareDataManager;

+(void)setDataByKey:(id)object forkey:(NSString*)key;
+(void)removeDataByKey:(NSString*)key;
+(id)getDataByKey:(NSString*)key;

-(void)cleanTabel:(NSString*)tableName;
-(void)dropTabel:(NSString*)tableName;
-(void)createTabel:(NSString*)tableName;
-(NSArray*)selectValueFromTabel:(NSString*)statement tableName:(NSString*)tableName;
-(NSDictionary*)deleteValueFromTabel:(NSString*)statement tableName:(NSString*)tableName ID:(uint32_t)ID;
-(NSArray*)insertValueToTabel:(NSArray*)valueArr tableName:(NSString*)tableName maxCount:(uint32_t)maxCount;

@end
