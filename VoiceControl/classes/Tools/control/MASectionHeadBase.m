//
//  MASectionHeadBase.m
//  VoiceControl
//
//  Created by 刘坤 on 13-8-25.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MASectionHeadBase.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"

@interface MASectionHeadBase()
@property (nonatomic, strong) UILabel* titleLabel;
@end

@implementation MASectionHeadBase

@synthesize isExpanded = _isExpanded;
@synthesize enabled = _enabled;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isExpanded = NO;
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
    }
    return self;
}

-(void)setHeadResource:(NSDictionary *)resDic{
    NSDictionary* property = [resDic objectForKey:KSectionProperty];
    _enabled = [[property objectForKey:KEnabled] boolValue];
    if (_enabled) {
        _titleLabel = [MAUtils labelWithTxt:[property objectForKey:KTitle]
                                          frame:CGRectMake(0, 0, 200, 40)
                                           font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize18]
                                          color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
        _titleLabel.textAlignment = KTextAlignmentLeft;
        [self addSubview:_titleLabel];
        
        //添加单击手势
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        //给self.view添加一个手势监测；
        [self addGestureRecognizer:singleRecognizer];
    } else {
        _isExpanded = YES;
    }
}

#pragma mark - tap
-(void)singleTap:(id)sender{
    if (_delegate) {
        [_delegate headSelected:self];
    }
    
    if (_isExpanded) {
        _titleLabel.textColor = [[MAModel shareModel] getColorByType:MATypeColorDefBlue default:NO];
    } else {
        _titleLabel.textColor = [[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO];
    }
}
@end
