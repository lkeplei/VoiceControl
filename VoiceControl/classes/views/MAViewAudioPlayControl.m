//
//  MAViewAudioPlayControl.m
//  VoiceControl
//
//  Created by ken on 13-7-26.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewAudioPlayControl.h"
#import "MARecordController.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MAModel.h"
#import "MAViewTagDetail.h"
#import "MADataManager.h"

#import "MAVoiceFiles.h"
#import "MAAnimatedLabel.h"

#define KTagBtnTag(a)               (1000 + (a))
#define KIndexFromTag(a)            ((a) - 1000)
#define KSpaceOff                   (10)
#define KTimeLabelHeight            (20)
#define KProgressHeight             (40)
#define KHideRectWidth              (60)

@interface MAViewAudioPlayControl (){
    float fileDuration;
}

@property (nonatomic, strong) UISlider* progressSlider;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UILabel* fileLabel;
@property (nonatomic, strong) UIButton* playBtn;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic) NSMutableArray* resouceArr;
@property (nonatomic, strong) UIView* tagView;
@property (nonatomic, strong) NSMutableArray* fileTagArray;

@end

@implementation MAViewAudioPlayControl

@synthesize audioPlayDelegate = _audioPlayDelegate;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];
        
        //subscription 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        //set back ground alpha
        [self setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
        
        //set gestures
        [self setupGestures];
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - init area
-(void)initView{
    //add progress
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, KSpaceOff, self.frame.size.width, KSpaceOff)];
    [_progressSlider setThumbImage:[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberKnob default:NO]
                          forState:UIControlStateHighlighted];
    [_progressSlider setMinimumTrackImage:[[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberLeft default:NO] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                forState:UIControlStateNormal];
    [_progressSlider setMaximumTrackImage:[[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberRight default:NO] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                forState:UIControlStateNormal];
    [_progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _progressSlider.maximumValue = 0.0;
    _progressSlider.minimumValue = 0.0;
    [self addSubview:_progressSlider];
    
    //add contrl button
    UIButton* preBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                         image:[[MAModel shareModel] getImageByType:MATypeImgPlayPre default:NO]
                                      imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPre default:NO]
                                        target:self
                                        action:@selector(preBtnClicked:)];
    preBtn.frame = CGRectOffset(preBtn.frame, 10, 46);
    [self addSubview:preBtn];
    
    _playBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                 image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                              imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                target:self
                                action:@selector(playBtnClicked:)];
    _playBtn.frame = CGRectOffset(_playBtn.frame, 50, 46);
    [self addSubview:_playBtn];
    
    UIButton* nextBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                          image:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                       imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                         target:self
                                         action:@selector(nextBtnClicked:)];
    nextBtn.frame = CGRectOffset(nextBtn.frame, 90, 46);
    [self addSubview:nextBtn];
    
    //hide btn
    UIButton* hideBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                         image:nil
                                      imagesec:nil
                                        target:self
                                        action:@selector(hideBtnClicked:)];
    hideBtn.frame = CGRectMake(self.frame.size.width - KHideRectWidth, self.frame.size.height - KHideRectWidth, KHideRectWidth, KHideRectWidth);
    [self addSubview:hideBtn];
    
    //add label
    float x = KSpaceOff + CGRectGetMaxX(nextBtn.frame);
    _fileLabel = [MAUtils labelWithTxt:@""
                                 frame:CGRectMake(x, CGRectGetMinY(nextBtn.frame),
                                                  self.frame.size.width - x, KTimeLabelHeight)
                                  font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    _fileLabel.textAlignment = KTextAlignmentLeft;
    [self addSubview:_fileLabel];
    
    _timeLabel = [MAUtils labelWithTxt:@""
                                 frame:CGRectMake(x, CGRectGetMidY(nextBtn.frame),
                                                  self.frame.size.width - x, KTimeLabelHeight)
                                  font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    _timeLabel.textAlignment = KTextAlignmentLeft;
    [self addSubview:_timeLabel];
}

-(void)playWithPath:(MAVoiceFiles*)file array:(NSArray *)array{
    if (_avPlay.playing) {
        [self stopAudio];
    }
    
    if (_timeLabel == nil) {
        [self initView];
    }
    
    //deal with message
    if (file) {
        _filePath = [NSString stringWithString:file.path];
    } else {
        if (_filePath == nil) {
            DebugLog(@"no file path coming");
            return;
        }
    }
    
    if (array) {
        if (_resouceArr == nil) {
            _resouceArr = [[NSMutableArray alloc] init];
        } else {
            [_resouceArr removeAllObjects];
        }
        
        [_resouceArr addObjectsFromArray:array];
    }
    
    //set btn
    if (_playBtn) {
        [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                            forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                            forState:UIControlStateHighlighted];
        [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                            forState:UIControlStateSelected];
    }

    //play
    BOOL play = YES;
    if (![MAUtils fileExistsAtPath:_filePath]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docspath = [paths objectAtIndex:0];
        NSString* fileName = [docspath stringByAppendingFormat:@"/%@.zip", file.name];
        
        if (![MAUtils unzipFiles:fileName unZipFielPath:nil]) {
            play = NO;
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
        }
    }
    
    if (play) {
        _avPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_filePath] error:nil];
        _avPlay.delegate = self;
        if ([_avPlay play]) {
            fileDuration = [file.duration floatValue];
            _timeLabel.text = [NSString stringWithFormat:@"0:00:00 | %@",
                               [[MAModel shareModel] getStringTime:fileDuration type:MATypeTimeClock]];
            _fileLabel.text = [NSString stringWithFormat:@"%@ - %@", file.custom, [MAUtils getStringFromDate:file.time format:KTimeFormat]];
            
            //设置标记点
            [self setTags:file];
            
            //slider
            _progressSlider.maximumValue = _avPlay.duration;
        }
    }
}

- (void)stopAudio{
    if (_avPlay.playing) {
        //stop
        [_avPlay stop];
        
        //set btn
        if (_playBtn) {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateSelected];
        }
    }
}

- (void)detectionVoice{
    if (_avPlay && _avPlay.playing) {
        [_avPlay updateMeters];//刷新音量数据
        
        _timeLabel.text = [NSString stringWithFormat:@"%@ | %@", [[MAModel shareModel] getStringTime:_avPlay.currentTime type:MATypeTimeClock],
                           [[MAModel shareModel] getStringTime:fileDuration type:MATypeTimeClock]];
        _progressSlider.value = _avPlay.currentTime;
    } else {
        [self setPlayBtnStatus:YES];
    }
}

-(void)setTags:(MAVoiceFiles*)file{
    if (_tagView) {
        [_tagView removeFromSuperview];
        _tagView = nil;
    }
    
    if (_fileTagArray) {
        [_fileTagArray removeAllObjects];
    } else {
        _fileTagArray = [[NSMutableArray alloc] init];
    }
    
    if (file.tag) {
        NSArray* tagArr = [MAUtils getArrayFromStrByCharactersInSet:file.tag character:@";"];
        if ([tagArr count] > 0) {
            _tagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, KProgressHeight)];
            [self addSubview:_tagView];
        }
        
        for(int i = 0; i < [tagArr count]; i++){
            NSString* tag = [tagArr objectAtIndex:i];
            MATagObject* tagObject = [[MATagObject alloc] init];
            if ([tagObject initDataWithString:tag]) {
                tagObject.tag = i;
                tagObject.totalTime = [file.duration floatValue];
                if (tagObject.endTime > tagObject.totalTime) {
                    tagObject.endTime = tagObject.totalTime;
                }
                tagObject.name = file.name;
                [_fileTagArray addObject:tagObject];
                
                
                float x = (tagObject.startTime / tagObject.totalTime) * _progressSlider.frame.size.width;
                float x2 = (tagObject.endTime / tagObject.totalTime) * _progressSlider.frame.size.width;
                UIButton* tagsBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                                     image:nil
                                                  imagesec:nil
                                                    target:self
                                                    action:@selector(tagsBtnClicked:)];
                tagsBtn.frame = CGRectMake(x, 0, x2 - x, KProgressHeight);
                tagsBtn.tag = KTagBtnTag(i);
                [_tagView addSubview:tagsBtn];
                
                [self setNeedsDisplay];
            }
        }
        
        if (![[MADataManager getDataByKey:KUserDefaultTagRemind] boolValue]) {
            CGRect frame = CGRectMake(_tagView.frame.origin.x, _tagView.center.y, _tagView.frame.size.width, _tagView.frame.size.height / 2);
            MAAnimatedLabel* label = [[MAAnimatedLabel alloc] initWithFrame:frame];
            label.text = MyLocal(@"audio_tag_remind");
            label.textColor = [UIColor cyanColor];
            [label startAnimating];
            label.tag = 9999;
            label.textAlignment = KTextAlignmentCenter;
            [_tagView addSubview:label];
            
            UIButton* tagsBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                                 image:nil
                                              imagesec:nil
                                                target:self
                                                action:@selector(remindTagBtnClicked:)];
            tagsBtn.frame = _tagView.frame;
            [_tagView addSubview:tagsBtn];
        }
    }
}

-(void)setPlayBtnStatus:(BOOL)play{
    if (_playBtn) {
        if (play) {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateSelected];
        } else {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateSelected];
        }
    }
}

#pragma mark - btn clicked
- (void)playBtnClicked:(id)sender{
    if (_avPlay.playing) {
        [_avPlay pause];

        [self setPlayBtnStatus:YES];
    } else {
        [_avPlay play];
        
        [self setPlayBtnStatus:NO];
    }
}

- (void)preBtnClicked:(id)sender{
    if (_resouceArr) {
        if (_audioPlayDelegate) {
            if ([_audioPlayDelegate MAAudioPlayBack:MAAudioPlayPre]) {
                
            }
        }
    }
}

- (void)nextBtnClicked:(id)sender{
    if (_resouceArr) {
        if (_audioPlayDelegate) {
            if ([_audioPlayDelegate MAAudioPlayBack:MAAudioPlayNext]) {
                
            }
        }
    }
}

-(void)hideBtnClicked:(id)sender{
    if (_audioPlayDelegate) {
        if ([_audioPlayDelegate MAAudioPlayBack:MAAudioPlayHide]) {
            
        }
    }
}

-(void)remindTagBtnClicked:(UIButton*)sender{
    [MADataManager setDataByKey:[NSNumber numberWithBool:YES] forkey:KUserDefaultTagRemind];
    [self setNeedsDisplay];
    
    [sender removeFromSuperview];
    id animationLabel = [_tagView viewWithTag:9999];
    if (animationLabel) {
        [animationLabel removeFromSuperview];
    }
    
    id btn = [_tagView viewWithTag:KTagBtnTag(0)];
    if (btn) {
        [self tagsBtnClicked:btn];
    }
}

-(void)tagsBtnClicked:(id)sender{
    int tagIndex = KIndexFromTag(((UIButton*)sender).tag);
    if (_fileTagArray && [_fileTagArray count] > tagIndex) {
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobEventStart eventName:KTagDetail label:nil];
        
        //stop playing voice
        if (_avPlay.playing) {
            [_avPlay pause];
            [self setPlayBtnStatus:YES];
        }
        
        //go to tag detail
        MAViewTagDetail* tagDetail = [[MAViewTagDetail alloc] initWithTagObject:_fileTagArray index:tagIndex];
        [tagDetail show];
        tagDetail.tagDetailBlock = ^(MATagObject* object){
            _avPlay.currentTime = object.pointX;
            [_avPlay play];
            [self setPlayBtnStatus:NO];
        };
    }
}

#pragma mark - slider
-(void)progressSliderMoved:(id)sender{
    _avPlay.currentTime = _progressSlider.value;
}

#pragma mark Swipe Gesture Setup/Actions
-(void)setupGestures {
	UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTime:)];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:tapRecognizer];
}

-(void)tapTime:(id)sender {
    DebugLog(@"tap");
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
	CGPoint tapPoint = [(UITapGestureRecognizer*)sender locationInView:self];
    CGRect rect = CGRectMake(_progressSlider.frame.origin.x, _progressSlider.frame.origin.y - 10,
                             _progressSlider.frame.size.width, _progressSlider.frame.size.height + 20);
    if (CGRectContainsPoint(rect, tapPoint)) {
        float p = (tapPoint.x - _progressSlider.frame.origin.x) / _progressSlider.frame.size.width;
        _avPlay.currentTime = _avPlay.duration * p;
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    DebugLog(@"finished");
    _progressSlider.value = 0;
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    DebugLog(@"decode error");
}

#pragma mark - multi task
- (void)applicationDidEnterBackground:(UIApplication *)application{
    DebugLog(@"app did enter back ground");
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    DebugLog(@"app will enter back ground");
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark - Drawing operations
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw hide line
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextMoveToPoint(context, 290, 64);
    CGContextAddLineToPoint(context, 300, 70);
    
    CGContextMoveToPoint(context, 290, 70);
    CGContextAddLineToPoint(context, 300, 76);
    
    CGContextMoveToPoint(context, 300, 70);
    CGContextAddLineToPoint(context, 310, 64);

    CGContextMoveToPoint(context, 300, 76);
    CGContextAddLineToPoint(context, 310, 70);
    
    CGContextStrokePath(context);
    
    // Draw sound meter wave
    [self drawTagRect:context];
    
//  Draw title
//    [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
//    UIBezierPath *line = [UIBezierPath bezierPath];
//    [line moveToPoint:CGPointMake(290, 60)];
//    [line addLineToPoint:CGPointMake(300, 70)];
//    [line setLineWidth:3.0];
//    [line stroke];
}

-(void)drawTagRect:(CGContextRef)context{
    if (_tagView) {
        if (![[MADataManager getDataByKey:KUserDefaultTagRemind] boolValue]) {
            CGRect frame = CGRectMake(_tagView.frame.origin.x, _tagView.center.y, _tagView.frame.size.width, _tagView.frame.size.height / 2);
            [self drawGradientRect:frame context:context];
        } else {
            BOOL goon = YES;
            int tag = 0;
            while (goon) {
                UIView* view = [_tagView viewWithTag:KTagBtnTag(tag)];
                if (view) {
                    CGRect frame = CGRectMake(view.frame.origin.x, view.center.y, view.frame.size.width, view.frame.size.height / 2);
                    [self drawGradientRect:frame context:context];
                    
                    //              start and end line
//                    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
//                
//                    CGContextSetLineWidth(context, 1.0);
//                    CGContextMoveToPoint(context, frame.origin.x, frame.size.height);
//                    CGContextAddLineToPoint(context, frame.origin.x, CGRectGetMaxY(view.frame));
//                    
//                    CGContextMoveToPoint(context, CGRectGetMaxX(frame), frame.size.height);
//                    CGContextAddLineToPoint(context, CGRectGetMaxX(frame), CGRectGetMaxY(frame));
//                    
//                    CGContextStrokePath(context);
                    
                    
                    int number = view.frame.size.width / (self.frame.size.width / 4);
                    number = number <= 0 ? 1 : number;
                    float width = view.frame.size.width / number;
                    CGContextSetLineWidth(context, 0.5);
                    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
                    float y = frame.origin.y + frame.size.height / 2;
                    float x = frame.origin.x;
                    for (int i = 0; i < number; i++) {
                        float off = width / 4;
                        CGContextBeginPath(context);
                        CGContextMoveToPoint(context, x, y);
                        CGContextAddCurveToPoint(context, x , y, x + off, 50, x + width / 2, y);
                        CGContextAddCurveToPoint(context, x + width / 2, y,
                                                 x + off * 3, 10, x + width, y);
                        
                        x += width;
                        CGContextStrokePath(context);
                    }
                } else {
                    goon = NO;
                }
                
                tag++;
            }
        }
    }
}

-(void)drawGradientRect:(CGRect)frame context:(CGContextRef)context{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIColor *strokeColor = [UIColor colorWithRed:0.886 green:0.0 blue:0.0 alpha:0.8];
    UIColor *gradientColor = [UIColor colorWithRed:0.5827 green:0.5827 blue:0.5827 alpha:1.0];
    UIColor *fillColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)fillColor.CGColor, (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:0];
    CGContextSaveGState(context);
    [border addClip];
    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(frame.origin.x, frame.size.height), 20,
                                CGPointMake(CGRectGetMaxX(frame), frame.size.height), 20,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    border.lineWidth = 0;       //设置边框宽度
    [border stroke];
}
@end
