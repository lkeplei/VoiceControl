//
//  MAViewSelectMenu.m
//  VoiceControl
//
//  Created by 刘坤 on 13-7-28.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewSelectMenu.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MAViewController.h"

@implementation MAViewSelectMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSelectMenu;
        self.viewTitle = MyLocal(@"view_title_select_menu");
        
        //bg
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bg.png"]];
        bgView.frame = (CGRect){CGPointZero, self.size};
        [self addSubview:bgView];
        //table
        [self setTableResource:KMenuTableView];
        //top view
        [self initTopView];
        
        [self.tableView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (CGRect)getTableFrame {
    return CGRectMake(0, KNavigationHeight + KStatusBarHeight, self.width, self.height - (KNavigationHeight + KStatusBarHeight));
}

- (void)initTopView {
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetMinY(self.tableView.frame), self.width, 0.5}];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:line];
    
    //
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_head.png"]];
    bgView.center = CGPointMake(IsPad ? 40 : 25, KStatusBarHeight + KNavigationHeight / 2);
    [self addSubview:bgView];
    
    UIButton *button = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                        image:nil
                                     imagesec:nil
                                       target:self
                                       action:@selector(hideBtnClick)];
    button.frame = (CGRect){CGPointZero, self.width, KNavigationHeight + KStatusBarHeight};
    [self addSubview:button];
    
    float offsetX = IsPad ? 80 : 50;
    UILabel *head = [MAUtils labelWithTxt:MyLocal(@"app_name") frame:(CGRect){offsetX, KStatusBarHeight, self.width - offsetX, KNavigationHeight}
                                     font:[UIFont fontWithName:KLabelFontArial size:IsPad ? KLabelFontSize36 : KLabelFontSize22]
                                    color:RGBCOLOR(138, 138, 138)];
    head.textAlignment = KTextAlignmentLeft;   //first deprecated in IOS 6.0
    [self addSubview:head];
}

- (void)hideBtnClick {
    [SysDelegate.viewController hideMenu];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cellMenu";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    [cell setHeight:KTableBaseCellHeight];
    
    //cell
    NSDictionary* dic = [self.sectionArray objectAtIndex:indexPath.section];
    NSMutableDictionary* resDic = [[dic objectForKey:KCellArray] objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:[resDic objectForKey:KImage]]];
    [cell.textLabel setText:[resDic objectForKey:KContent]];
    if (IsPad) {
        [cell.textLabel setFont:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize32]];
    }
    [cell.textLabel setTextColor:RGBCOLOR(138, 138, 138)];
    
    float offset = IsPad ? 80 : 50;
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){offset, cell.height, self.tableView.width - offset, 0.5}];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [SysDelegate.viewController changeToViewByType:MAViewTypeHome changeType:MATypeTransitionRippleEffect];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [SysDelegate.viewController changeToViewByType:MAViewTypeFileManager changeType:MATypeTransitionRippleEffect];
    } else if(indexPath.section == 2 && indexPath.row == 0){
        [SysDelegate.viewController changeToViewByType:MAViewTypeSetting changeType:MATypeTransitionRippleEffect];
    } else if(indexPath.section == 3 && indexPath.row == 0){
        [SysDelegate.viewController changeToViewByType:MAViewTypePlanCustomize changeType:MATypeTransitionRippleEffect];
    } else if(indexPath.section == 4 && indexPath.row == 0){
        [SysDelegate.viewController changeToViewByType:MAViewTypeAboutUs changeType:MATypeTransitionRippleEffect];
    }
}
@end
