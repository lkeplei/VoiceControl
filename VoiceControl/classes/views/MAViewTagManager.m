//
//  MAViewTagManager.m
//  VoiceControl
//
//  Created by apple on 14-4-25.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewTagManager.h"
#import "MAConfig.h"
#import "MARecordController.h"
#import "MACellTag.h"
#import "MAUtils.h"
#import "MAVoiceFiles.h"

#define KCellTagHeight          (50)

@interface MAViewTagManager ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, copy) NSMutableArray* resourceArray;
@property (nonatomic, strong) UIButton* playButton;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@end

@implementation MAViewTagManager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MaviewTypeTagManager;
        self.viewTitle = MyLocal(@"view_title_tag_manager");
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:nil enabled:YES];
}

-(void)showView{
    [self initTable];
    [self initBottomView];
}

-(void)initBottomView{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - KNavigationHeight,
                                                           self.frame.size.width, KNavigationHeight)];
    [_bottomView setBackgroundColor:[UIColor blackColor]];
    [self addSubview:_bottomView];
    
    _playButton = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                   image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                  target:self
                                  action:@selector(playBtnClicked:)];
    _playButton.center = CGPointMake(_playButton.center.x + 10, _bottomView.frame.size.height / 2);
    [_bottomView addSubview:_playButton];
}

- (void)initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.frame.size.width,
                                                               self.frame.size.height - KNavigationHeight)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.rowHeight = KCellTagHeight;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.allowsSelectionDuringEditing = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_resourceArray) {
        return [_resourceArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    MACellTag* cell = (MACellTag*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[MACellTag alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if (_resourceArray && [_resourceArray count] > 0) {
        if (_resourceArray && [indexPath row] < [_resourceArray count]) {
            [cell.detailTextLabel setText:[(MATagObject*)[_resourceArray objectAtIndex:indexPath.row] name]];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

//编辑状态
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

    }
}

-(void)setPlayBtnStatus:(BOOL)play{
    if (_playButton) {
        if (play) {
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                   forState:UIControlStateNormal];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                   forState:UIControlStateHighlighted];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                   forState:UIControlStateSelected];
        } else {
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                   forState:UIControlStateNormal];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                   forState:UIControlStateHighlighted];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                   forState:UIControlStateSelected];
        }
    }
}

- (void)detectionVoice{
    if (_avPlay && _avPlay.playing) {
        [_avPlay updateMeters];//刷新音量数据
    } else {
        [self setPlayBtnStatus:YES];
    }
}

#pragma mark - audio player
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}

#pragma mark - btn clicked
-(void)playBtnClicked:(id)sender{
    if (_avPlay.playing) {
        [_avPlay pause];
        
        [self setPlayBtnStatus:YES];
    } else {
        [_avPlay play];
        
        [self setPlayBtnStatus:NO];
    }
}

#pragma mark - other
-(void)eventTopBtnClicked:(BOOL)left{
    if (left)  {
        [self popView:MATypeChangeViewCurlUp];
    }
}

-(void)initTagObject:(MAVoiceFiles*)file{
    _resourceArray = [[NSMutableArray alloc] init];
    
    if (file.tag) {
        NSArray* tagArr = [MAUtils getArrayFromStrByCharactersInSet:file.tag character:@";"];
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
                [_resourceArray addObject:tagObject];
            }
        }
    }
    
    _avPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:file.path] error:nil];
    _avPlay.delegate = self;
}
@end
