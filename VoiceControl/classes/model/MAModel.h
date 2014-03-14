//
//  MAModel.h
//  VoiceControl
//
//  Created by ken on 13-7-24.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioRecorder;

typedef enum {
    MATypeTimeCh = 0,
    MATypeTimeNum,
    
    MATypeSkinDefault = 50,
    MATypeSkinBlack,
    
    MATypeFileNormal = 70,
    MATypeFileForEver,
    MATypeFilePwd,
    
    MATypeChangeViewNull = 100,
    MATypeChangeViewCurlDown,
    MATypeChangeViewCurlUp,
    MATypeChangeViewFlipFromLeft,
    MATypeChangeViewFlipFromRight,
    
    MATypeColorDefault = 200,
    MATypeColorDefWhite,
    MATypeColorDefBlack,
    MATypeColorDefGray,
    MATypeColorDefBlue,
    MATypeColorHomeBg,
    MATypeColorTableLabel,
    MATypeColorDropBG,
    MATypeColorDropCellBG,
    MATypeColorBtnGreen,
    MATypeColorBtnDarkGreen,
    MATypeColorBtnRed,
    MATypeColorBtnDarkRed,
    MATypeColorBtnGray,
    
    MATypeImgHomePhone = 300,
    MATypeImgHomeMenu,
    MATypeImgPlayPlay,
    MATypeImgPlayNext,
    MATypeImgPlayPause,
    MATypeImgPlayPre,
    MATypeImgBtnGreenCircleSec,
    MATypeImgBtnGreenCircle,
    MATypeImgBtnRedCircleSec,
    MATypeImgBtnRedCircle,
    MATypeImgBtnGrayCircle,
    MATypeImgAddPlanReSec,
    MATypeImgCheckBoxNormal,
    MATypeImgCheckBoxSec,
    MATypeImgCellIndicator,
    MATypeImgSliderScrubberKnob,
    MATypeImgSliderScrubberLeft,
    MATypeImgSliderScrubberRight,
    
    MATypeBaiduMobLogEvent = 400,
    MATypeBaiduMobEventStart,
    MATypeBaiduMobEventEnd,
    MATypeBaiduMobPageStart,
    MATypeBaiduMobPageEnd,
} MAType;

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
//获取单文件最短时长
-(int)getFileTimeMin;
//获取单文件最大时长
-(int)getFileTimeMax;
//获取录音分贝开始点
-(int)getVoiceStartPos;
//删除垃圾文件
-(void)clearRubbish:(BOOL)now;
//重设最小时长
-(void)resetFileMin:(int)time;
//获取repeat时间设置
-(NSString*)getRepeatTest:(NSString*)resource add:(BOOL)add;

//录音相关
-(void)startRecord;
-(void)stopRecord;
-(void)resetPlan;
-(BOOL)isRecording;
-(NSString*)getCurrentFileName;
-(NSString*)getcurrentFilePath;
-(AVAudioRecorder*)getRecorder;

//百度统计统一入口
-(void)setBaiduMobStat:(MAType)type eventName:(NSString*)eventName label:(NSString*)label;

@property (nonatomic, getter = isAppForeground) BOOL appForeground;

@end
