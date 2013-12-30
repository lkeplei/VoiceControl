//
//  MAModel.h
//  VoiceControl
//
//  Created by ken on 13-7-24.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MATypeTimeCh = 0,
    MATypeTimeNum,
    
    MATypeSkinDefault = 50,
    MATypeSkinBlack,
    
    MATypeChangeViewCurlDown = 100,
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
    
    MATypeImgHomePhone = 300,
    MATypeImgHomeMenu,
    MATypeImgPlayPlay,
    MATypeImgPlayNext,
    MATypeImgPlayPause,
    MATypeImgPlayPre,
    MATypeImgBtnsec,
    MATypeImgBtn
} MAType;

@interface MAModel : NSObject

+(MAModel*)shareModel;

//获取颜色
-(UIColor*)getColorByType:(MAType)type default:(BOOL)defult;
-(UIImage*)getImageByType:(MAType)type default:(BOOL)defult;

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
-(int)getVoiceStatPos;
@end
