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

-(void)startDefaultRecord;
-(void)stopDefaultRecord;

-(void)resetPlan;
-(void)resetTimer;

@property (assign) BOOL isRecording;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) AVAudioRecorder* recorder;

@end




@interface MATagObject : NSObject

@property (readonly) Float32 duration;          //多长时间，私有用来算平均分贝
@property (assign) Float32 startTime;           //开始时间
@property (assign) Float32 endTime;             //结束时间
@property (assign) Float32 averageVoice;        //平均分贝
@property (assign) Float32 totalTime;           //总时长
@property (assign) Float32 pointX;              //选择时间点
@property (assign) int tag;                     //标记，用来找到对应的标记点
@property (nonatomic, retain) NSString* tagName;

-(void)addAverage:(Float32)voice;
-(void)initData;
-(BOOL)initDataWithString:(NSString*)string;
@end