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

#import "MAVoiceFiles.h"

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
@property (nonatomic, strong) MAVoiceFiles* currentFile;

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
                          forState:UIControlStateNormal];
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
    _currentFile = file;
    
    if (_tagView) {
        [_tagView removeFromSuperview];
        _tagView = nil;
    }
    
    if (_currentFile.tag) {
        NSArray* tagArr = [MAUtils getArrayFromStrByCharactersInSet:_currentFile.tag character:@";"];
        if ([tagArr count] > 0) {
            _tagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, KProgressHeight)];
            [self addSubview:_tagView];
        }
        
        for(int i = 0; i < [tagArr count]; i++){
            NSString* tag = [tagArr objectAtIndex:i];
            MATagObject* tagObject = [[MATagObject alloc] init];
            if ([tagObject initDataWithString:tag]) {
                float x = (tagObject.startTime / [_currentFile.duration floatValue]) * _progressSlider.frame.size.width;
                UIImageView* imgViewS = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tag.png"]];
                imgViewS.frame = CGRectOffset(imgViewS.frame, x, _progressSlider.center.y);
                [_tagView addSubview:imgViewS];
                UILabel* labelS = [MAUtils labelWithTxt:@"s" frame:imgViewS.frame
                                                   font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                                  color:[[MAModel shareModel] getColorByType:MATypeColorDefBlue default:NO]];
                [_tagView addSubview:labelS];
                
                x = (tagObject.endTime / [_currentFile.duration floatValue]) * _progressSlider.frame.size.width;
                UIImageView* imgViewE = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tag.png"]];
                imgViewE.frame = CGRectOffset(imgViewE.frame, x, _progressSlider.center.y);
                [_tagView addSubview:imgViewE];
                UILabel* labelE = [MAUtils labelWithTxt:@"e" frame:imgViewE.frame
                                                   font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                                  color:[[MAModel shareModel] getColorByType:MATypeColorDefBlue default:NO]];
                [_tagView addSubview:labelE];
                
                UILabel* labelA = [MAUtils labelWithTxt:[MAUtils getStringByFloat:tagObject.averageVoice decimal:1]
                                                  frame:CGRectMake(CGRectGetMinX(imgViewS.frame), CGRectGetMaxY(imgViewS.frame),
                                                                   CGRectGetMaxX(imgViewE.frame) - CGRectGetMinX(imgViewS.frame),
                                                                   imgViewE.frame.size.height)
                                                   font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                                  color:[[MAModel shareModel] getColorByType:MATypeColorDefBlue default:NO]];
                [_tagView addSubview:labelA];
                
                UIButton* tagsBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                                     image:nil
                                                  imagesec:nil
                                                    target:self
                                                    action:@selector(tagsBtnClicked:)];
                tagsBtn.frame = CGRectMake(CGRectGetMinX(imgViewS.frame), CGRectGetMinY(imgViewS.frame),
                                           CGRectGetMaxX(imgViewE.frame) - CGRectGetMinX(imgViewS.frame), imgViewS.frame.size.height);
                tagsBtn.tag = i;
                [_tagView addSubview:tagsBtn];
            }
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

-(void)tagsBtnClicked:(id)sender{
    int tagIndex = ((UIButton*)sender).tag;
    if (_currentFile && _currentFile.tag) {
        NSArray* tagArr = [MAUtils getArrayFromStrByCharactersInSet:_currentFile.tag character:@";"];
        if ([tagArr count] > tagIndex) {
            MATagObject* tagObject = [[MATagObject alloc] init];
            if ([tagObject initDataWithString:[tagArr objectAtIndex:tagIndex]]) {
                //stop playing voice
                if (_avPlay.playing) {
                    [_avPlay pause];
                    [self setPlayBtnStatus:YES];
                }
                
                //go to tag detail
                tagObject.totalTime = [_currentFile.duration floatValue];
                tagObject.tag = tagIndex;
                MAViewTagDetail* tagDetail = [[MAViewTagDetail alloc] initWithTagObject:tagObject];
                [tagDetail show];
                tagDetail.tagDetailBlock = ^(MATagObject* object){
                    _avPlay.currentTime = object.pointX;
                    [_avPlay play];
                    [self setPlayBtnStatus:NO];
                };
            }
        }
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

    // Draw sound meter wave
    [self drawTagRect:context];
    
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
    
//  Draw title
//    [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
//    UIBezierPath *line = [UIBezierPath bezierPath];
//    [line moveToPoint:CGPointMake(290, 60)];
//    [line addLineToPoint:CGPointMake(300, 70)];
//    [line setLineWidth:3.0];
//    [line stroke];
}

-(void)drawTagRect:(CGContextRef)context{
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetLineJoin(context, kCGLineJoinRound);
//    
//    CGContextMoveToPoint(context, 20, 30);
//    CGContextAddLineToPoint(context, 200, 30);
//    
//    CGContextStrokePath(context);
}
@end
