//
//  MAViewSystemSetting.m
//  VoiceControl
//
//  Created by apple on 14-4-15.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewSystemSetting.h"
#import "MAConfig.h"
#import "MAUtils.h"

#define KViewVerOffset          (10)
#define KViewLabelHeight        (20)

@interface MAViewSystemSetting ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* durationView;
@property (nonatomic, strong) UIView* markDBView;
@property (nonatomic, strong) UIView* qualityView;
@property (nonatomic, strong) UIView* contactView;
@property (nonatomic, strong) UISlider* progressSlider;
@property (nonatomic, strong) UISlider* markSlider;
@end

@implementation MAViewSystemSetting

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSetting;
        self.viewTitle = MyLocal(@"view_title_setting");
        
        [self initView];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [SysDelegate.viewController setGestureEnabled:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    [SysDelegate.viewController setGestureEnabled:YES];
}

- (void)initView{
    [self initDurationView];
    [self initMarkDBView];
    [self initQualityView];
    [self initContactView];
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:(CGRect){CGPointZero, self.frame.size}];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:_durationView];
    [scrollView addSubview:_markDBView];
    [scrollView addSubview:_qualityView];
    [scrollView addSubview:_contactView];
    [self addSubview:scrollView];

    scrollView.contentSize = CGSizeMake(self.frame.size.width, CGRectGetMaxY(_contactView.frame) + KNavigationHeight);
    scrollView.contentOffset  = CGPointMake(0, 0);
}

#pragma mark - duration area
-(void)initDurationView{
    _durationView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _durationView.frame = (CGRect){(CGRectGetWidth(self.frame) - CGRectGetWidth(_durationView.frame)) / 2,
        KViewVerOffset, _durationView.frame.size};
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_duration_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_durationView addSubview:label];

    UILabel* descr = [MAUtils labelWithTxt:MyLocal(@"system_setting_duration_describe")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset / 2 + CGRectGetMaxY(label.frame),
                                                      _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    descr.textAlignment = KTextAlignmentLeft;
    [_durationView addSubview:descr];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 40, _durationView.frame.size.width, 30)];
    [_progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _progressSlider.maximumValue = 1;
    _progressSlider.minimumValue = 180;
    [_durationView addSubview:_progressSlider];
}

-(void)progressSliderMoved:(id)sender{
//    _avPlay.currentTime = _progressSlider.value;
}

#pragma mark - mark db area
-(void)initMarkDBView{
    _markDBView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _markDBView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_durationView.frame), _markDBView.frame.size};
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_mark_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_markDBView addSubview:label];
    
    UILabel* descr = [MAUtils labelWithTxt:MyLocal(@"system_setting_mark_describe")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset / 2 + CGRectGetMaxY(label.frame),
                                                      _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    descr.textAlignment = KTextAlignmentLeft;
    [_markDBView addSubview:descr];
    
    _markSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 40, _durationView.frame.size.width, 30)];
    [_markSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _markSlider.maximumValue = 1;
    _markSlider.minimumValue = 180;
    [_markDBView addSubview:_markSlider];
}

#pragma mark - quality area
-(void)initQualityView{
    _qualityView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _qualityView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_markDBView.frame),
        _qualityView.frame.size};
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_quality_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_qualityView addSubview:label];
}

#pragma mark - contact area
-(void)initContactView{
    _contactView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _contactView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_qualityView.frame),
        _contactView.frame.size};
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_contact_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_contactView addSubview:label];
}
@end
