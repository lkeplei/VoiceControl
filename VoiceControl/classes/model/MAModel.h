//
//  MAModel.h
//  VoiceControl
//
//  Created by ken on 13-7-24.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAModelDef.h"

@class AVAudioRecorder;

@interface MAModel : NSObject

+(MAModel*)shareModel;

//获取颜色
-(UIColor*)getColorByType:(MAType)type default:(BOOL)defult;
-(UIImage*)getImageByType:(MAType)type default:(BOOL)defult;
//获取字体
-(UIFont *)getLaberFontSize:(NSString *)fontName size:(CGFloat)fontSize;
//初始化一些基本数据
-(void)initAppSource;
//获取时间字符串
-(NSString*)getStringTime:(int32_t)time type:(MAType)type;
//视图切换
-(void)changeView:(UIView*)from to:(UIView*)to type:(MAType)type delegate:(UIViewController*)delegate selector:(SEL)selector;
//获取单文件最大时长
-(int)getFileTimeMax;
//获取录音分贝标记点
-(int)getTagVoice;
//获取repeat时间设置
-(NSString*)getRepeatTest:(NSString*)resource add:(BOOL)add;

//录音相关
-(void)startRecord;
-(void)stopRecord;
-(void)resetPlan;
-(BOOL)isRecording;
-(void)resetRecorderQuality:(MARecorderQualityType)type;
-(NSString*)getCurrentFileName;
-(NSString*)getcurrentFilePath;
-(AVAudioRecorder*)getRecorder;

//百度统计统一入口
-(void)setBaiduMobStat:(MAType)type eventName:(NSString*)eventName label:(NSString*)label;

@property (nonatomic, getter = isAppForeground) BOOL appForeground;

@end
