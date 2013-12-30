//
//  MAViewHome.m
//  VoiceControl
//
//  Created by ken on 13-8-2.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewHome.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"
#import "MADataManager.h"
#import "MAViewAudioPlayControl.h"

#define KHudSizeWidth           (self.frame.size.width * 0.8)
#define KHudSizeHeight          150
#define CANCEL_BUTTON_HEIGHT    50
#define SOUND_METER_COUNT       40
#define KMaxLengthOfWave        (50)
#define KMaxValueOfMetaer       (70)

@interface MAViewHome (){
    float   voiceMax;
    float   voiceMin;
    float   voiceCurrent;
    float   voiceAverage;
    BOOL    isRecording;
    BOOL    isPlaying;
    
    NSTimer *timer;
    NSURL *urlPlay;
    
    
    CGRect hudRect;
    int soundMeters[40];
}

@property (retain, nonatomic) UIImage *imagePhone;
@property (retain, nonatomic) UIButton *startBtn;
@property (retain, nonatomic) UIButton *playBtn;
@property (retain, nonatomic) UILabel* labelVoice;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) NSString* fileTime;
@property (nonatomic, strong) NSMutableDictionary* recordSetting;
@property (nonatomic, strong) AVAudioRecorder* recorder;
@property (retain, nonatomic) AVAudioPlayer *avPlay;

@end

@implementation MAViewHome

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initAudio];
        [self initView];
        [self initHud];
        
        self.viewType = MAViewTypeHome;
        isRecording = NO;
        isPlaying = NO;
        voiceMax = 0;
        voiceMin = 0;
        voiceCurrent = 0;
        voiceAverage = 0;
    }
    return self;
}

#pragma mark - init area
-(void)initHud{
    _imagePhone = [[MAModel shareModel] getImageByType:MATypeImgHomePhone default:NO];
    hudRect = CGRectMake(self.center.x - (KHudSizeWidth / 2), self.center.y - (KHudSizeWidth / 2), KHudSizeWidth, KHudSizeHeight);
    for(int i = 0; i < SOUND_METER_COUNT; i++) {
        soundMeters[i] = KMaxLengthOfWave;
    }

}

-(void)initBtns{
    _startBtn = [MAUtils buttonWithImg:MyLocal(@"start") off:0 zoomIn:NO
                                  image:[[MAModel shareModel] getImageByType:MATypeImgBtn default:NO]
                               imagesec:[[MAModel shareModel] getImageByType:MATypeImgBtnsec default:NO]
                                 target:self
                                 action:@selector(startBtnClicked:)];
    _startBtn.frame = CGRectOffset(_startBtn.frame, 30, 50);
    [self addSubview:_startBtn];
    
    _playBtn = [MAUtils buttonWithImg:MyLocal(@"play") off:0 zoomIn:NO
                                 image:[[MAModel shareModel] getImageByType:MATypeImgBtn default:NO]
                              imagesec:[[MAModel shareModel] getImageByType:MATypeImgBtnsec default:NO]
                               target:self
                                action:@selector(playRecordSound:)];
    _playBtn.frame = CGRectOffset(_playBtn.frame, 30, 100);
    [self addSubview:_playBtn];
}

-(void)initLabels{
    _labelVoice = [MAUtils laeblWithTxt:[NSString stringWithFormat:MyLocal(@"voice_message"), voiceMax, voiceMin, voiceCurrent, voiceAverage]
                                   frame:CGRectMake(210, 50, 100, 80)
                                    font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize16]
                                   color:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];
    _labelVoice.textAlignment = UITextAlignmentLeft;
    [_labelVoice setNumberOfLines:0];
    [self addSubview:_labelVoice];
}

- (void)initView{
    [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorHomeBg default:NO]];
    
    [self initBtns];
    [self initLabels];
}

- (void)initAudio
{
    //录音设置
    _recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [_recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [_recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [_recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [_recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [_recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
}

#pragma mark - btn clicked
- (void)playRecordSound:(id)sender{
    if (isRecording) {
        [self startBtnClicked:nil];
    }
    
    if (isPlaying) {
        [_playBtn setTitle:MyLocal(@"play") forState:UIControlStateNormal];

        [_avPlay stop];
        isPlaying = NO;
    } else {
        [_playBtn setTitle:MyLocal(@"stop") forState:UIControlStateNormal];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docspath = [paths objectAtIndex:0];
        NSString* file = [docspath stringByAppendingFormat:@"/%@.zip", _fileName];
        
        if ([MAUtils unzipFiles:file unZipFielPath:nil]) {
            _avPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_filePath] error:nil];
            _avPlay.delegate = self;
            [_avPlay play];

            isPlaying = YES;
        } else {
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
        }
    }
}

- (void)startBtnClicked:(id)sender{
    if (isRecording) {
        [self stopRecorder];
        //停止计时
        [timer invalidate];
    } else {
        //先关播放，再开录音
        if (isPlaying) {
            [_playBtn setTitle:MyLocal(@"play") forState:UIControlStateNormal];
            [_avPlay stop];
            isPlaying = NO;
        }
        
        [self startRecorder];
        //设置定时检测
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
    
    isRecording = !isRecording;
    if (isRecording) {
        [_startBtn setTitle:MyLocal(@"stop") forState:UIControlStateNormal];
    } else {
        [_startBtn setTitle:MyLocal(@"start") forState:UIControlStateNormal];
    }
}

#pragma mark - audio play
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_playBtn setTitle:MyLocal(@"play") forState:UIControlStateNormal];
    isPlaying = NO;
}

#pragma mark - other methods
-(void)startRecorder{
    NSArray* array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strUrl = [array lastObject];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:KNameFormat];
    _fileName = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    _filePath = [NSString stringWithFormat:@"%@/%@.aac", strUrl, _fileName];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:KTimeFormat];
    _fileTime = [formatter stringFromDate:[NSDate date]];
    
    NSURL* url = [NSURL fileURLWithPath:_filePath];
    urlPlay = url;
    
    NSError *error;
    //初始化
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
    _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:_recordSetting error:&error];
    //开启音量检测
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    //创建录音文件，准备录音
    if ([_recorder prepareToRecord]) {
        //开始
        [_recorder record];
    }
}

-(void)stopRecorder{
    double duration = _recorder.currentTime;
    if (duration < [[MAModel shareModel] getFileTimeMin]) {//如果录制时间小于最小时长 不发送
        //删除记录的文件
        [_recorder deleteRecording];
    } else {
        //insert value to table
        NSMutableArray* resArr = [[NSMutableArray alloc] init];
        NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
        [res setObject:_filePath forKey:KDataBasePath];
        [res setObject:_fileName forKey:KDataBaseFileName];
        [res setObject:_fileTime forKey:KDataBaseTime];
        [res setObject:[MAUtils getStringByFloat:duration decimal:0] forKey:KDataBaseDuration];
        [res setObject:[MAUtils getNumberByBool:NO] forKey:KDataBaseDataEver];
        [resArr addObject:res];
        [[MADataManager shareDataManager] insertValueToTabel:resArr tableName:KTableVoiceFiles maxCount:0];
        
        if ([MAUtils getFileSize:_filePath] > KZipMinSize * 1024) {
            //zip file
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docspath = [paths objectAtIndex:0];
            
            NSMutableArray* array = [[NSMutableArray alloc] init];
            
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[@"" stringByAppendingFormat:@"%@.aac", _fileName] forKey:KName];
            [dic setObject:_filePath forKey:KPath];
            [array addObject:dic];
            
            BOOL result = [MAUtils zipFiles:[docspath stringByAppendingFormat:@"/%@.zip", _fileName] resourceArr:array];
            if (result) {
                //delete file
                [MAUtils deleteFileWithPath:_filePath];
            }
        }
    }
    [_recorder stop];
}

- (void)detectionVoice{
    [_recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    
    voiceAverage = [_recorder averagePowerForChannel:0] + 100;
    voiceCurrent = lowPassResults;
    voiceMax = [_recorder peakPowerForChannel:0] + 100;
    _labelVoice.text = [NSString stringWithFormat:MyLocal(@"voice_message"), voiceMax, voiceMin, voiceCurrent, voiceAverage];
    
    
    [self addSoundMeterItem:[_recorder averagePowerForChannel:0]];
}

#pragma mark - Sound meter operations
- (void)shiftSoundMeterLeft {
    for(int i=0; i<SOUND_METER_COUNT - 1; i++) {
        soundMeters[i] = soundMeters[i+1];
    }
}

- (void)addSoundMeterItem:(int)lastValue {
    [self shiftSoundMeterLeft];
    [self shiftSoundMeterLeft];
    soundMeters[SOUND_METER_COUNT - 1] = lastValue;
    soundMeters[SOUND_METER_COUNT - 2] = lastValue;
    
    [self setNeedsDisplay];
}

#pragma mark - Drawing operations
- (void)drawRect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *strokeColor = [UIColor colorWithRed:0.886 green:0.0 blue:0.0 alpha:0.8];
    UIColor *fillColor = [UIColor colorWithRed:0.5827 green:0.5827 blue:0.5827 alpha:1.0];
    UIColor *gradientColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:
                               (id)fillColor.CGColor,
                               (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:hudRect cornerRadius:10.0];
    CGContextSaveGState(context);
    [border addClip];
    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(hudRect.origin.x + KHudSizeWidth / 2, 120), 10,
                                CGPointMake(hudRect.origin.x + KHudSizeWidth / 2, 195), 215,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    border.lineWidth = 3.0;
    [border stroke];
    
    //draw phone
    [_imagePhone drawAtPoint:CGPointMake(hudRect.origin.x + (hudRect.size.width - _imagePhone.size.width) / 2,
                                         hudRect.origin.y + (hudRect.size.height - _imagePhone.size.height) / 2)];
    
    // Draw sound meter wave
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4] set];
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    int baseLine = hudRect.origin.y + hudRect.size.height / 2;
    int multiplier = 1;
    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--){
        multiplier = ((int)x % 2) == 0 ? 1 : -1;
        
        CGFloat y = baseLine + ((KMaxValueOfMetaer * (KMaxLengthOfWave - abs(soundMeters[(int)x]))) / KMaxLengthOfWave) * multiplier;
        
        if(x == SOUND_METER_COUNT - 1) {
            CGContextMoveToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 5, y);
            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 2, y);
        }
        else {
            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 5, y);
            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 2, y);
        }
    }
    
    CGContextStrokePath(context);

    // Draw title
//    [[UIColor colorWithWhite:0.8 alpha:1.0] setFill];
//    UIBezierPath *line = [UIBezierPath bezierPath];
//    [line moveToPoint:CGPointMake(hudRect.origin.x, hudRect.origin.y + HUD_SIZE - CANCEL_BUTTON_HEIGHT)];
//    [line addLineToPoint:CGPointMake(hudRect.origin.x + HUD_SIZE, hudRect.origin.y + HUD_SIZE - CANCEL_BUTTON_HEIGHT)];
//    [line setLineWidth:3.0];
//    [line stroke];
}
@end