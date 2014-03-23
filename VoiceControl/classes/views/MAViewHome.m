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

#define KHudSizeWidth           (self.frame.size.width * 1)
#define KHudSizeHeight          220
#define CANCEL_BUTTON_HEIGHT    50
#define SOUND_METER_COUNT       60
#define KMaxLengthOfWave        (50)
#define KMaxValueOfMetaer       (70)

@interface MAViewHome (){
    float   voiceMax;
    float   voiceMin;
    float   voiceCurrent;
    float   voiceAverage;
    BOOL    isPlaying;

    NSURL *urlPlay;
    
    CGRect hudRect;
    int soundMeters[SOUND_METER_COUNT];
}

@property (strong, nonatomic) UIButton *startBtn;
@property (strong, nonatomic) UIButton *playBtn;
@property (strong, nonatomic) UILabel* labelVoice;
@property (strong, nonatomic) UILabel* labelDuration;
@property (strong, nonatomic) AVAudioPlayer *avPlay;

@end

@implementation MAViewHome

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
        [self initHud];
        
        self.viewType = MAViewTypeHome;
        self.viewTitle = MyLocal(@"view_title_home");

        isPlaying = NO;
        voiceMax = 0;
        voiceMin = 0;
        voiceCurrent = 0;
        voiceAverage = 0;
        
        //设置定时检测
        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"home_top_left") rightBtn:MyLocal(@"home_top_right") enabled:YES];
    [self setSubEventLeft:NO];
    [self setSubEventRight:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    if (_avPlay && [_avPlay isPlaying]) {
        [_avPlay stop];
    }
    _avPlay = nil;
}

#pragma mark - init area
-(void)initHud{
//    _imagePhone = [[MAModel shareModel] getImageByType:MATypeImgHomePhone default:NO];
    hudRect = CGRectMake(self.center.x - (KHudSizeWidth / 2), 0, KHudSizeWidth, KHudSizeHeight);
    for(int i = 0; i < SOUND_METER_COUNT; i++) {
        soundMeters[i] = KMaxLengthOfWave;
    }
}

-(void)initBtns{
    NSString* startText = MyLocal(@"start_record");
    if ([[MAModel shareModel] isRecording]) {
        startText = MyLocal(@"filish_record");
    }
    //开始按钮
    _startBtn = [MAUtils buttonWithImg:startText off:0 zoomIn:NO
                                  image:[[MAModel shareModel] getImageByType:MATypeImgBtnGreenCircle default:NO]
                               imagesec:[[MAModel shareModel] getImageByType:MATypeImgBtnGreenCircleSec default:NO]
                                 target:self
                                 action:@selector(startBtnClicked:)];
    _startBtn.frame = CGRectOffset(_startBtn.frame, 30, 300);
    [_startBtn setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorBtnGreen default:NO]
                    forState:UIControlStateNormal];
    [_startBtn setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorBtnDarkGreen default:NO]
                    forState:UIControlStateHighlighted];
    [_startBtn setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorBtnDarkGreen default:NO]
                    forState:UIControlStateSelected];
    [self addSubview:_startBtn];
    
    //播放按钮
    _playBtn = [MAUtils buttonWithImg:MyLocal(@"play") off:0 zoomIn:NO
                                 image:[[MAModel shareModel] getImageByType:MATypeImgBtnGreenCircle default:NO]
                              imagesec:[[MAModel shareModel] getImageByType:MATypeImgBtnGreenCircleSec default:NO]
                               target:self
                                action:@selector(playRecordSound:)];
    [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgBtnGrayCircle default:NO]
                        forState:UIControlStateDisabled];
    _playBtn.frame = CGRectOffset(_playBtn.frame, 215, 300);
    [_playBtn setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorBtnGreen default:NO]
                   forState:UIControlStateNormal];
    [_playBtn setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorBtnDarkGreen default:NO]
                   forState:UIControlStateHighlighted];
    [_playBtn setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorBtnDarkGreen default:NO]
                   forState:UIControlStateSelected];
    [_playBtn setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]
                   forState:UIControlStateDisabled];
    [self addSubview:_playBtn];
}

-(void)initLabels{
    _labelVoice = [MAUtils labelWithTxt:[NSString stringWithFormat:MyLocal(@"voice_message"), voiceMax, voiceMin, voiceCurrent, voiceAverage]
                                   frame:CGRectMake(10, 230, 300, 30)
                                    font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                   color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
//    _labelVoice.textAlignment = KTextAlignmentLeft;
    [_labelVoice setNumberOfLines:0];
    [self addSubview:_labelVoice];
    
    _labelDuration = [MAUtils labelWithTxt:[[MAModel shareModel] getStringTime:0 type:MATypeTimeClock]
                                  frame:CGRectMake(10, 260, 300, 30)
                                   font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                  color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_labelDuration setNumberOfLines:0];
    [self addSubview:_labelDuration];
}

- (void)initView{
    [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    
    [self initBtns];
    [self initLabels];
}

#pragma mark - btn clicked
- (void)playRecordSound:(id)sender{
    if ([[MAModel shareModel] isRecording]) {
        [self startBtnClicked:nil];
    }
    
    NSString* eventLabel = nil;
    if (isPlaying) {
        [_playBtn setTitle:MyLocal(@"play") forState:UIControlStateNormal];
        eventLabel = [MyLocal(@"view_title_home") stringByAppendingFormat:@"-%@", MyLocal(@"play")];

        [_avPlay stop];
        isPlaying = NO;
    } else {
        [_playBtn setTitle:MyLocal(@"stop") forState:UIControlStateNormal];
        eventLabel = [MyLocal(@"view_title_home") stringByAppendingFormat:@"-%@", MyLocal(@"stop")];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docspath = [paths objectAtIndex:0];
        NSString* file = [docspath stringByAppendingFormat:@"/%@.zip", [[MAModel shareModel] getCurrentFileName]];
        
        if ([MAUtils unzipFiles:file unZipFielPath:nil]) {
            _avPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[[MAModel shareModel] getcurrentFilePath]] error:nil];
            _avPlay.delegate = self;
            [_avPlay play];

            isPlaying = YES;
        } else {
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
        }
    }
    
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KHomeRecordBtn label:eventLabel];
}

- (void)startBtnClicked:(id)sender{
    if ([[MAModel shareModel] isRecording]) {
        [[MAModel shareModel] stopRecord];
    } else {
        //先关播放，再开录音
        if (isPlaying) {
            [_playBtn setTitle:MyLocal(@"play") forState:UIControlStateNormal];
            [_avPlay stop];
            isPlaying = NO;
        }
        
        [[MAModel shareModel] startRecord];
    }
    
    [self setStartBtnStatus:[[MAModel shareModel] isRecording]];
    
    NSString* eventLabel = nil;
    if ([[MAModel shareModel] isRecording]) {
        eventLabel = [MyLocal(@"view_title_home") stringByAppendingFormat:@"-%@", MyLocal(@"filish_record")];
    } else {
        eventLabel = [MyLocal(@"view_title_home") stringByAppendingFormat:@"-%@", MyLocal(@"start_record")];
    }

    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KHomePlayBtn label:eventLabel];
}

#pragma mark - audio play
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_playBtn setTitle:MyLocal(@"play") forState:UIControlStateNormal];
    isPlaying = NO;
}

#pragma mark - other methods
-(void)setStartBtnStatus:(BOOL)start{
    if (start) {
        [_startBtn setTitle:MyLocal(@"filish_record") forState:UIControlStateNormal];
        [_playBtn setEnabled:NO];
    } else {
        [_startBtn setTitle:MyLocal(@"start_record") forState:UIControlStateNormal];
        [_playBtn setEnabled:YES];
    }
}

-(void)detectionVoice{
    if ([[MAModel shareModel] isRecording]) {
        if (soundMeters[SOUND_METER_COUNT - 1] == KMaxLengthOfWave) {
            [self setStartBtnStatus:YES];
        }
        
        [[[MAModel shareModel] getRecorder] updateMeters];//刷新音量数据
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [[[MAModel shareModel] getRecorder] peakPowerForChannel:0]));
        
        voiceAverage = [[[MAModel shareModel] getRecorder] averagePowerForChannel:0] + 100;
        voiceCurrent = lowPassResults * 120;
        voiceMax = [[[MAModel shareModel] getRecorder] peakPowerForChannel:0] + 100;
        
        float level; // The linear 0.0 .. 1.0 value we need.
        float minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
        float decibels = [[[MAModel shareModel] getRecorder] averagePowerForChannel:0];
        
        float root = 2.0f;
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp = powf(10.0f, 0.05f * decibels);
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root);
        
        voiceMin = level * 120;
        
        _labelVoice.text = [NSString stringWithFormat:MyLocal(@"voice_message"), voiceMax, voiceMin, voiceCurrent, voiceAverage];
        _labelDuration.text = [[MAModel shareModel] getStringTime:[[MAModel shareModel] getRecorder].currentTime type:MATypeTimeClock];
        
        [self addSoundMeterItem:[[[MAModel shareModel] getRecorder] averagePowerForChannel:0]];
    } else {
        if (soundMeters[SOUND_METER_COUNT - 1] != KMaxLengthOfWave) {
            [self setStartBtnStatus:NO];
        }
        
        [self addSoundMeterItem:KMaxLengthOfWave];
        _labelVoice.text = [NSString stringWithFormat:MyLocal(@"voice_message"), 0, 0, 0, 0];
        _labelDuration.text = [[MAModel shareModel] getStringTime:0 type:MATypeTimeClock];
    }
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
//    UIColor *fillColor = [UIColor colorWithRed:0.5827 green:0.5827 blue:0.5827 alpha:1.0];
//    UIColor *gradientColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    UIColor *fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    UIColor *gradientColor = [UIColor colorWithRed:0.72 green:0.76 blue:0.8 alpha:0.7];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:
                               (id)fillColor.CGColor,
                               (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:hudRect cornerRadius:1.0];
    CGContextSaveGState(context);
    [border addClip];
    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(hudRect.origin.x + KHudSizeWidth / 2, 120), 10,
                                CGPointMake(hudRect.origin.x + KHudSizeWidth / 2, 195), 215,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    border.lineWidth = 0;       //设置边框宽度
    [border stroke];
    
    //draw phone
//    [_imagePhone drawAtPoint:CGPointMake(hudRect.origin.x + (hudRect.size.width - _imagePhone.size.width) / 2,
//                                         hudRect.origin.y + (hudRect.size.height - _imagePhone.size.height) / 2)];
    
    // Draw sound meter wave
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] set];
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    int baseLine = hudRect.origin.y + hudRect.size.height / 2;
    int multiplier = 1;
    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--){
        multiplier = ((int)x % 2) == 0 ? 1 : -1;
        
        CGFloat y = baseLine + ((KMaxValueOfMetaer * (KMaxLengthOfWave - abs(soundMeters[(int)x]))) / KMaxLengthOfWave) * multiplier;
        
        if(x == SOUND_METER_COUNT - 1) {
            CGContextMoveToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 4, y);
            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 2, y);
        }
        else {
            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 4, y);
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