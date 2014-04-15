//
//  MAViewSystemSetting.m
//  VoiceControl
//
//  Created by apple on 14-4-15.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewSystemSetting.h"
#import "MAConfig.h"

#define KViewVerOffset          (10)

@interface MAViewSystemSetting ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* durationView;
@property (nonatomic, strong) UIView* markDBView;
@property (nonatomic, strong) UIView* qualityView;
@property (nonatomic, strong) UIView* contactView;
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

- (void)initView{
    _durationView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _durationView.frame = (CGRect){(CGRectGetWidth(self.frame) - CGRectGetWidth(_durationView.frame)) / 2,
        KViewVerOffset, _durationView.frame.size};
    
    _markDBView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _markDBView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_durationView.frame), _markDBView.frame.size};
    
    _qualityView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _qualityView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_markDBView.frame),
        _qualityView.frame.size};
    
    _contactView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _contactView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_qualityView.frame),
        _contactView.frame.size};
    

    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:(CGRect){CGPointZero, self.frame.size}];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:_durationView];
    [scrollView addSubview:_markDBView];
    [scrollView addSubview:_qualityView];
    [scrollView addSubview:_contactView];
    [self addSubview:scrollView];

    scrollView.contentSize  = CGSizeMake(self.frame.size.width, CGRectGetMaxY(_contactView.frame) + KNavigationHeight);
    scrollView.contentOffset  = CGPointMake(0, 0);
}

@end
