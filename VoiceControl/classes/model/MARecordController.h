//
//  MARecordController.h
//  VoiceControl
//
//  Created by apple on 14-2-13.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface MARecordController : NSObject<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

//录音相关
-(void)startRecord;
-(void)stopRecord;

-(void)resetPlan;

/**
 *  设置录音状态
 *
 *  @param status yes:开启自动  no:关闭自动录音
 */
-(void)setRecordAutoStatus:(BOOL)isAuto;

@property (assign) BOOL isRecording;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) AVAudioRecorder* recorder;

@end
