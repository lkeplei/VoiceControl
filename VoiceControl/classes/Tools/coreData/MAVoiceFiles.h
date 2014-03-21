//
//  MAVoiceFiles.h
//  VoiceControl
//
//  Created by apple on 14-3-21.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MAVoiceFiles : NSManagedObject

@property (nonatomic, retain) NSString * name;              //内部名字
@property (nonatomic, retain) NSString * path;              //文件绝对路径
@property (nonatomic, retain) NSString * custom;            //用户自定义文件名字
@property (nonatomic, retain) NSNumber * level;             //文件等级（普通、永久、加密等）
@property (nonatomic, retain) NSNumber * type;              //用户分类（娱乐、家庭等）-- 备用字段
@property (nonatomic, retain) NSDate * time;                //开始时间
@property (nonatomic, retain) NSNumber * duration;          //文件时长
@property (nonatomic, retain) NSString * tag;               //标记（1-***;2-***;3***）
@property (nonatomic, retain) NSString * image;             //头像 -- 备用字段

@property (assign) BOOL status;

@end
