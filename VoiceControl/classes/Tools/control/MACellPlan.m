//
//  MACellPlan.m
//  VoiceControl
//
//  Created by apple on 14-2-7.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MACellPlan.h"
#import "MAUtils.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MADataManager.h"

#define KTimeLabelTag       (1000)
#define KTitleLableTag      (1001)
#define KPlanLabelTag       (1002)
#define KSwitchTag          (1003)
#define KIndicatorTag       (1004)
#define kDurationTag        (1005)

#define KSwitchWidth        (60)
#define KSwitchHeight       (16)

@interface MACellPlan ()

@property (nonatomic, strong) NSDictionary* resourceDic;
@property (nonatomic, strong) UIView* bgContentView;
@property (nonatomic, strong) UIView* bgView;

@end

@implementation MACellPlan

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

}

-(void)setCellResource:(NSDictionary*)resDic editing:(BOOL)editing{
    _resourceDic = resDic;
    
    if (_bgView) {
        [_bgView removeFromSuperview];
        _bgView = nil;
    }
    if (!_bgContentView) {
        _bgContentView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, KMainScreenWidth, self.contentView.height}];
        [self.contentView addSubview:_bgContentView];
    }
    
    int offset = 10;
    float heightRate = 0.75;
    //time
    UILabel* label = (UILabel*)[_bgContentView viewWithTag:KTimeLabelTag];
    if (label) {
        label.text = [resDic objectForKey:KDataBaseTime];
    } else {
        label = [MAUtils labelWithTxt:[resDic objectForKey:KDataBaseTime]
                                frame:CGRectMake(offset, offset / 2, self.frame.size.width, self.frame.size.height * heightRate)
                                 font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize36]
                                color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        label.textAlignment = KTextAlignmentLeft;
        label.tag = KTimeLabelTag;
        [_bgContentView addSubview:label];
    }
    
    //duration
    UILabel* duration = (UILabel*)[_bgContentView viewWithTag:kDurationTag];
    if (duration) {
        duration.text = [self getDateString:[[resDic objectForKey:KDataBaseDuration] intValue]];
    } else {
        duration = [MAUtils labelWithTxt:[self getDateString:[[resDic objectForKey:KDataBaseDuration] intValue]]
                                frame:CGRectMake(100, 20, self.frame.size.width, label.frame.size.height / 2)
                                 font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        duration.textAlignment = KTextAlignmentLeft;
        duration.tag = kDurationTag;
        [_bgContentView addSubview:duration];
    }
    
    //title
    UILabel* title = (UILabel*)[_bgContentView viewWithTag:KTitleLableTag];
    if (title) {
        title.text = [resDic objectForKey:KDataBaseTitle];
    } else {
        title = [MAUtils labelWithTxt:[resDic objectForKey:KDataBaseTitle]
                                frame:CGRectMake(offset, CGRectGetMaxY(label.frame) + offset / 2,
                                                 self.frame.size.width, self.frame.size.height - label.frame.size.height)
                                 font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        title.textAlignment = KTextAlignmentLeft;
        title.tag = KTitleLableTag;
        [_bgContentView addSubview:title];
    }
    
    //plan time
    UILabel* planTime = (UILabel*)[_bgContentView viewWithTag:KPlanLabelTag];
    if (planTime) {
        planTime.text = [self getPlanTimeString:[resDic objectForKey:KDataBasePlanTime]];
    } else {
        planTime = [MAUtils labelWithTxt:[self getPlanTimeString:[resDic objectForKey:KDataBasePlanTime]]
                                   frame:CGRectMake(title.frame.origin.x + [MAUtils getFontSize:[resDic objectForKey:KTitle]
                                                                                           font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]].width,
                                                 CGRectGetMinY(title.frame), self.frame.size.width, title.frame.size.height)
                                 font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        planTime.textAlignment = KTextAlignmentLeft;
        planTime.tag = KPlanLabelTag;
        [_bgContentView addSubview:planTime];
    }
    
    //on/off
    UISwitch* switcher = (UISwitch*)[_bgContentView viewWithTag:KSwitchTag];
    if (switcher) {
        [switcher setOn:[[resDic objectForKey:KDataBaseStatus] boolValue]];
    } else {
        switcher = [[UISwitch alloc] initWithFrame:CGRectMake((_bgContentView.width - KSwitchWidth) - offset / 2,
                                                              (self.height - KSwitchHeight) / 2,
                                                              KSwitchWidth, KSwitchHeight)];
        switcher.tag = KSwitchTag;
        [switcher setOn:[[resDic objectForKey:KDataBaseStatus] boolValue]];
        [switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [_bgContentView addSubview:switcher];
    }
    
    //imgView
    UIImageView* imgView = (UIImageView*)[_bgContentView viewWithTag:KIndicatorTag];
    if (!imgView) {
        imgView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgCellIndicator default:NO]];
        imgView.center = CGPointMake(switcher.center.x - offset * 1.5, self.contentView.center.y);
        imgView.tag = KIndicatorTag;
        [_bgContentView addSubview:imgView];
    }

    //other
    if ([[resDic objectForKey:KDataBaseStatus] boolValue]) {
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];
    } else {
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    
    if (editing) {
        [switcher setHidden:YES];
        [imgView setHidden:NO];
    } else {
        [switcher setHidden:NO];
        [imgView setHidden:YES];
    }
}

-(void)setCellResource:(NSString *)resource{
    if (_bgContentView) {
        [_bgContentView removeFromSuperview];
        _bgContentView = nil;
    }
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.contentView.frame.size.height)];
        [self.contentView addSubview:_bgView];
    }
    
    UILabel* label = (UILabel*)[_bgView viewWithTag:KTimeLabelTag];
    if (label) {
        label.text = resource;
    } else {
        label = [MAUtils labelWithTxt:resource
                                frame:self.frame
                                 font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize18]
                                color:[[MAModel shareModel] getColorByType:MATypeColorBtnRed default:NO]];
        label.tag = KTimeLabelTag;
        [_bgView addSubview:label];
    }
}

-(NSString*)getDateString:(int)date{
    if (date < 60) {
        return [NSString stringWithFormat:MyLocal(@"time_minute"), date];
    } else {
        return [NSString stringWithFormat:MyLocal(@"time_hour"), date / 60];
    }
}

-(NSString*)getPlanTimeString:(NSString*)str{
    NSString* string = [[MAModel shareModel] getRepeatTest:str add:NO];

    if (string && [string length] > 0) {
        string = [@", " stringByAppendingString:string];
    }
    
    return string;
}

#pragma mark - switch
-(void)switchAction:(id)sender{
    if ([(UISwitch*)sender isOn]) {
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];
    } else {
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    
    if (_resourceDic) {
        [_resourceDic setValue:[NSNumber numberWithBool:[(UISwitch*)sender isOn]] forKey:KDataBaseStatus];
        [[MADataManager shareDataManager] replaceValueToTabel:[NSArray arrayWithObjects:_resourceDic, nil] tableName:KTablePlan];
        
        //添加或者修改计划之后重置
        [[MAModel shareModel] resetPlan];
    }
}
@end
