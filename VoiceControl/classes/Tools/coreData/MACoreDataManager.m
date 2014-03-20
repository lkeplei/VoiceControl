//
//  MACoreDataManager.m
//  SanGameJJH
//
//  Created by apple on 14-3-13.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MACoreDataManager.h"
#import "MAConfig.h"

@interface MACoreDataManager ()

@property(strong,nonatomic) NSManagedObjectModel* managedObjectModel;   //数据模型对象
@property(strong,nonatomic) NSManagedObjectContext* managedObjectContext;   //上下文对象
@property(strong,nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;   //持久性存储区

@end

@implementation MACoreDataManager

+(MACoreDataManager*)sharedCoreDataManager{
    static MACoreDataManager* sharedCoreData = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedCoreData = [[self alloc] init];
    });
    return sharedCoreData;
}

//初始化Core Data使用的数据库
-(NSManagedObjectModel*)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

//managedObjectModel的初始化赋值函数
-(NSPersistentStoreCoordinator*)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //得到数据库的路径
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //CoreData是建立在SQLite之上的，数据库名称需与Xcdatamodel文件同名
    NSURL *storeUrl = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"ma_core_data.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        DebugLog(@"persistentStoreCoordinator Error: %@,%@",error,[error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

//managedObjectContext的初始化赋值函数
-(NSManagedObjectContext*)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator =[self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc]init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

#pragma mark - methods
-(void)safelyExit{
    NSError *error;
    if (_managedObjectContext != nil) {
        //hasChanges方法是检查是否有未保存的上下文更改，如果有，则执行save方法保存上下文
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            DebugLog(@"safelyExit Error: %@,%@",error,[error userInfo]);
            abort();
        }
    }
}

-(BOOL)saveEntry{
    BOOL isSaveSuccess = NO;
    
    NSError *error;
    isSaveSuccess = [[self managedObjectContext] save:&error];
    
    if (!isSaveSuccess) {
        DebugLog(@"saveEntry Error: %@,%@",error,[error userInfo]);
    }else {
        DebugLog(@"Save successful!");
    }
    
    return isSaveSuccess;
}

-(BOOL)deleteObject:(NSManagedObject*)entry{
    BOOL isSuccess = NO;
    
    [[self managedObjectContext] deleteObject:entry];
    isSuccess = [self saveEntry];

    return isSuccess;
}

-(BOOL)deleteEntry:(NSString*)object{
    BOOL isSuccess = NO;
    
    NSArray* array = [self queryFromDB:object sortKey:nil];
    if ([array count] > 0) {
        for (NSManagedObject *obj in array){
            [[self managedObjectContext] deleteObject:obj];
        }
        
        [self saveEntry];
    }
    
    return isSuccess;
}

-(NSArray*)queryFromDB:(NSString*)object sortKey:(NSString*)sortKey{
    //创建取回数据请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:object inManagedObjectContext:[self managedObjectContext]];
    //设置请求实体
    [request setEntity:entity];
    
    if (sortKey) {
        //指定对结果的排序方式
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
        NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptions];
    }
    
    NSError *error = nil;
    //执行获取数据请求，返回数组
    return [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
}

-(NSManagedObject*)getNewManagedObject:(NSString*)object{
    return [NSEntityDescription insertNewObjectForEntityForName:object inManagedObjectContext:[self managedObjectContext]];
}

#pragma mark - special get methods
-(NSArray*)getMAVoiceFile:(NSString*)name{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:KCoreVoiceFiles inManagedObjectContext:[self managedObjectContext]]];
    
    //更新谁的条件在这里配置；
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name==%@", name]];
    
    NSError* error = nil;
    
    NSArray* array = nil;
    array = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return array;
}
@end
