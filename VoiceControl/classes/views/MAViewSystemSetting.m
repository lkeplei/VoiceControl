//
//  MAViewSystemSetting.m
//  VoiceControl
//
//  Created by apple on 14-4-15.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewSystemSetting.h"
#import "MAConfig.h"

@interface MAViewSystemSetting ()
@property (nonatomic, strong) UITableView* tableView;
@end

@implementation MAViewSystemSetting

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSetting;
        self.viewTitle = MyLocal(@"view_title_setting");
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
        
        [self initView];
    }
    return self;
}

- (void)initView{
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:(CGRect){CGPointZero, self.frame.size}];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
//    [scrollView addSubview:label];
    [self addSubview:scrollView];

    scrollView.contentSize  = self.frame.size;
    scrollView.contentOffset  = CGPointMake(0, 0);
}

@end
