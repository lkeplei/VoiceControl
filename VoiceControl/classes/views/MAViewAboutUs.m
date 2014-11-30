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

#define KViewHorOffset      (20)

@interface MAViewAboutUs ()
@property (nonatomic, strong) UITableView* tableView;
@end

#define KAboutOffset        (6)

@implementation MAViewAboutUs

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAboutUs;
        self.viewTitle = MyLocal(@"view_title_about_us");
    }
    return self;
}

-(void)showView{
    _tableView = [[UITableView alloc] initWithFrame:(CGRect){CGPointZero, self.size} style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_tableView];
    
    [_tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getCellHeight:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"aboutUsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell setFrame:(CGRect){cell.origin, cell.width, [self getCellHeight:indexPath.row]}];
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (indexPath.row == 0) {
        UIImageView* imgView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"werecorder_qr_code.png"]];
        imgView.center = CGPointMake(self.centerX, cell.centerY);
        [cell.contentView addSubview:imgView];
        
        UILabel* label = [MAUtils labelWithTxt:[NSString stringWithFormat:@"V %@", [MAUtils getAppVersion]]
                                         frame:CGRectMake(0, CGRectGetMaxY(imgView.frame), cell.width, 24)
                                          font:[[MAModel shareModel] getLabelFontSize:KLabelFontHelvetica
                                                                                 size:IsPad ? KLabelFontSize22 : KLabelFontSize18]
                                         color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
        label.center = CGPointMake(self.centerX, CGRectGetMaxY(imgView.frame) + 20);
        [cell.contentView addSubview:label];
    } else {
        UILabel* label = [MAUtils labelWithTxt:MyLocal(@"about_us_content")
                                         frame:CGRectMake(KAboutOffset, 0, self.width - KAboutOffset * 2, cell.height)
                                          font:[[MAModel shareModel] getLabelFontSize:KLabelFontHelvetica
                                                                                 size:IsPad ? KLabelFontSize22 : KLabelFontSize16]
                                         color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
        label.textAlignment = KTextAlignmentLeft;
        label.numberOfLines = 0;
        
        [cell.contentView addSubview:label];
    }
    
    return cell;
}

- (CGFloat)getCellHeight:(int8_t)index {
    if (index == 0) {
        return 160.f;
    } else {
        return 400.f;
    }
}
@end
