//
//  MAViewSelectMenu.m
//  VoiceControl
//
//  Created by 刘坤 on 13-7-28.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewSelectMenu.h"
#import "MAConfig.h"
#import "MAViewController.h"

@implementation MAViewSelectMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSelectMenu;
        self.viewTitle = MyLocal(@"view_title_select_menu");
        
        [self setTableResource:KMenuTableView];
        
        UIImageView* separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_separator_line.png"]];
        separatorLine.frame = CGRectMake(self.frame.size.width - 1, 0, 1, self.frame.size.height);
        [self addSubview:separatorLine];
        
        [self initTopView];
        
        [self.tableView setBackgroundColor:RGBCOLOR(244, 245, 247)];
        [self setBackgroundColor:RGBCOLOR(244, 245, 247)];
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
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cellMenu";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    [cell setHeight:KTableBaseCellHeight];
    
    
    [cell.contentView setBackgroundColor:RGBCOLOR(244, 245, 247)];
    
    //cell
    NSDictionary* dic = [self.sectionArray objectAtIndex:indexPath.section];
    NSMutableDictionary* resDic = [[dic objectForKey:KCellArray] objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:[resDic objectForKey:KImage]]];
    [cell.textLabel setText:[resDic objectForKey:KContent]];
    [cell.textLabel setTextColor:RGBCOLOR(138, 138, 138)];
    
    float offset = IsPad ? 100 : 50;
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
