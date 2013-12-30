//
//  JJHDataManager.m
//  SanGameJJH
//
//  Created by ken on 13-5-23.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MADataManager.h"
#import "MAUtils.h"
#import "SQLiteWrapper.h"
#import "MAConfig.h"

#import <string>

@interface MADataManager (){
    SQLiteWrapper sqlite;
}

@end

@implementation MADataManager

static MADataManager* _shareDataManager = nil;

+(MADataManager*)shareDataManager{
	if (!_shareDataManager) {
        _shareDataManager = [[self alloc]init];
        [_shareDataManager openDB:KSqliteDBName];
	}
    
	return _shareDataManager;
};

#pragma mark - user default
+(void)setDataByKey:(id)object forkey:(NSString *)key{
    NSUserDefaults* defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
}

+(void)removeDataByKey:(NSString*)key{
    NSUserDefaults* defaults =[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}

+(id)getDataByKey:(NSString*)key{
    NSUserDefaults* defaults =[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

#pragma mark - sqllite
-(void)openDB:(NSString*)dbName{
	std::string cpath =  [[MAUtils getFilePathInDocument:dbName] UTF8String];
	if (sqlite.Open(cpath.c_str())){
        DebugLog(@"%@", [NSString stringWithFormat:@"%@ created or opened", dbName]);
    } else {
        DebugLog(@"%@", [NSString stringWithFormat:@"%@ can not opened", dbName]);
    }
}

-(void)cleanTabel:(NSString*)tableName{
	if(sqlite.DirectStatement([[NSString stringWithFormat:@"delete from %@", tableName] UTF8String])){
        DebugLog(@"%@", [NSString stringWithFormat:@"delete table %@ successful", tableName]);   
    } else {
        DebugLog(@"%@", [NSString stringWithFormat:@"delete table %@ failed", tableName]);   
    }
}

-(void)dropTabel:(NSString*)tableName{
	if(sqlite.DirectStatement([[NSString stringWithFormat:@"drop table if exists %@", tableName] UTF8String])){
        DebugLog(@"%@", [NSString stringWithFormat:@"drop table %@ successful", tableName]);
    } else {
        DebugLog(@"%@", [NSString stringWithFormat:@"drop table %@ failed", tableName]);
    }
}

-(void)createTabel:(NSString*)tableName{
    BOOL res = NO;
    if ([tableName compare:KTableVoiceFiles] == NSOrderedSame) {
        res = sqlite.DirectStatement([[NSString stringWithFormat:@"create table if not exists %@ (id integer primary key \
                                       , time varchar(32) \
                                       , name varchar(64) \
                                       , duration varchar(8) \
                                       , path varchar(1024) \
                                       , ever integer);", tableName] UTF8String]);
    } 
    
	if(res){
		DebugLog("%@", [NSString stringWithFormat:@"create table %@ successful", tableName]);
	} else {
		DebugLog("%@", [NSString stringWithFormat:@"create table %@ failed", tableName]);
    }
}

-(NSArray*)selectValueFromTabel:(NSString*)statement tableName:(NSString*)tableName{
    NSMutableArray* resArr = [[NSMutableArray alloc] init];
    
    SQLiteStatement* stmt = nil;
    if(statement.length > 0){
        stmt = sqlite.Statement([statement UTF8String]);   
    } else {
        stmt = sqlite.Statement([[NSString stringWithFormat:@"select * from %@;", tableName] UTF8String]);
    }
    
    if (stmt)
    {
		while(stmt->NextRow())
        {
            NSMutableDictionary* resDic = [[NSMutableDictionary alloc] init];
            if ([tableName compare:KTableVoiceFiles] == NSOrderedSame) {
                [resDic setObject:[MAUtils getNumberByInt:stmt->ValueInt(0)] forKey:KDataBaseId];
                [resDic setObject:[MAUtils getStringByStdString:stmt->ValueString(1).c_str()] forKey:KDataBaseTime];
                [resDic setObject:[MAUtils getStringByStdString:stmt->ValueString(2).c_str()] forKey:KDataBaseFileName];
                [resDic setObject:[MAUtils getStringByStdString:stmt->ValueString(3).c_str()] forKey:KDataBaseDuration];
                [resDic setObject:[MAUtils getStringByStdString:stmt->ValueString(4).c_str()] forKey:KDataBasePath];
                [resDic setObject:[MAUtils getNumberByBool:stmt->ValueInt(5)] forKey:KDataBaseDataEver];
            }
            [resArr addObject:resDic];
		}
	}
    
    return resArr;
}

-(NSDictionary*)deleteValueFromTabel:(NSString*)statement tableName:(NSString*)tableName ID:(uint32_t)ID{
    NSMutableDictionary* resDic = nil;
    //delete
    SQLiteStatement* stmt = nil;
    if(statement.length > 0){
        stmt = sqlite.Statement([statement UTF8String]);
    } else {
        //select
        NSString* select = [NSString stringWithFormat:@"select * from %@ where id = %d;", tableName, ID];
        NSArray* array = [self selectValueFromTabel:select tableName:tableName];
        
        if ([array count] > 0) {
            resDic = [array objectAtIndex:0];
        }
        
        stmt = sqlite.Statement([[NSString stringWithFormat:@"delete from %@ where id = %d;", tableName, ID] UTF8String]);
    }
    
    if(stmt->Execute()){
        DebugLog(@"delete value executed");
    } else {
        DebugLog(@"error executing statement: %s", sqlite.LastError().c_str());
    }

    return resDic;
}

-(NSArray*)insertValueToTabel:(NSArray*)valueArr tableName:(NSString*)tableName maxCount:(uint32_t)maxCount{
    if (valueArr == nil) {
        return nil;
    }
    
//    int count = sqlite.lastInsertRowid();
    if (maxCount != 0) {
        if (valueArr.count >= maxCount) {
            [self cleanTabel:tableName];
        } else {
            SQLiteStatement* valueCount = sqlite.Statement([[NSString stringWithFormat:@"select count(*) from %@;", tableName] UTF8String]);
            if(valueCount){
                valueCount->NextRow();
                int count = valueCount->ValueInt(0);
                int arrCount = [valueArr count];
                int off = count + arrCount - maxCount;
                if (off > 0){
                    valueCount = sqlite.Statement([[NSString stringWithFormat:@"select * from %@ order by id asc limit %d;", tableName, off] UTF8String]);
                    if (valueCount) {
                        valueCount->NextRow();
                        int32_t firstId = valueCount->ValueInt(0);
                        //delete
                        NSString* deleteStr = [NSString stringWithFormat:@"delete from %@ where id >= %d and id <= %d;",
                                            tableName, firstId, firstId + off - 1];
                        [self deleteValueFromTabel:deleteStr tableName:tableName ID:0];
                    }
                }
            }
        }
    }
    
    NSMutableArray* idArr = [[NSMutableArray alloc] init];
    for (NSDictionary* resDic in valueArr) {
        SQLiteStatement* stmt = nil;
        if ([tableName compare:KTableVoiceFiles] == NSOrderedSame) {
            stmt = sqlite.Statement([[NSString stringWithFormat:@"insert into %@ (time, name, duration, path, ever)values(?, ?, ?, ?, ?);", tableName] UTF8String]);
            if (stmt){
                stmt->Bind(0, [[resDic objectForKey:KDataBaseTime] UTF8String]);
                stmt->Bind(1, [[resDic objectForKey:KDataBaseFileName] UTF8String]);
                stmt->Bind(2, [[resDic objectForKey:KDataBaseDuration] UTF8String]);
                stmt->Bind(3, [[resDic objectForKey:KDataBasePath] UTF8String]);
                stmt->Bind(4, [[resDic objectForKey:KDataBaseDataEver] intValue]);
            }
        }
        
        if (stmt){
            if(stmt->Execute()){
                stmt = sqlite.Statement([[NSString stringWithFormat:@"select * from %@ order by id desc limit 1;", tableName] UTF8String]);
                if (stmt) {
                    stmt->NextRow();
                    NSMutableDictionary* idDic = [[NSMutableDictionary alloc] init];
                    [idDic setObject:[NSNumber numberWithInt:stmt->ValueInt(0)] forKey:KID];
                    [idDic setObject:resDic forKey:KData];
                    [idArr addObject:idDic];
                }
                DebugLog(@"statement executed");
            } else {
                DebugLog(@"error executing statement: %s", sqlite.LastError().c_str());
            }
            
            delete stmt;
            stmt = NULL;
        }
    }
    
    return idArr;
}
@end
