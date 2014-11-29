//
//  MAViewAboutUs.m
//  VoiceControl
//
//  Created by 刘坤 on 13-8-10.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewAboutUs.h"
#import "MAModel.h"
#import "MAConfig.h"
#import "MAUtils.h"

#define KViewHorOffset      (10)
#define KTopViewHeight      (150)

@interface MAViewAboutUs ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* topView;
@end

#define KAboutOffset        (6)

@implementation MAViewAboutUs

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAboutUs;
        self.viewTitle = MyLocal(@"view_title_about_us");
    }
    return self;
}

-(void)showView{
    [self initTopView];
    [self initDescribe];
}

#pragma mark - init area
-(void)initTopView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, KViewHorOffset, self.frame.size.width, KTopViewHeight)];
    
    UIImageView* imgView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"werecorder_qr_code.png"]];
    imgView.center = CGPointMake(_topView.center.x, _topView.center.y - KAboutOffset * 2);
    [_topView addSubview:imgView];
    
    UILabel* label = [MAUtils labelWithTxt:[NSString stringWithFormat:@"V %@", [MAUtils getAppVersion]]
                                     frame:CGRectMake(0, CGRectGetMaxY(imgView.frame), _topView.frame.size.width, 20)
                                      font:[[MAModel shareModel] getLabelFontSize:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_topView addSubview:label];
}

-(void)initDescribe{
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"about_us_content")
                                     frame:CGRectMake(KAboutOffset, KAboutOffset + CGRectGetMaxY(_topView.frame),
                                                      self.frame.size.width - KAboutOffset * 2,
                                                      self.frame.size.height - KAboutOffset * 3)
                                      font:[[MAModel shareModel] getLabelFontSize:KLabelFontHelvetica size:KLabelFontSize16]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
//    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textAlignment = KTextAlignmentLeft;
    label.numberOfLines = 0;
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:(CGRect){CGPointZero, self.frame.size}];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:_topView];
    [scrollView addSubview:label];
    [self addSubview:scrollView];
    
    scrollView.contentSize = CGSizeMake(self.frame.size.width, CGRectGetMaxY(label.frame));
    scrollView.contentOffset  = CGPointMake(0, 0);
}
@end
