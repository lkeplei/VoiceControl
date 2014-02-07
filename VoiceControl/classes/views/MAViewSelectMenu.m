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
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [SysDelegate.viewController changeToViewByType:MAViewTypeHome];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [SysDelegate.viewController changeToViewByType:MAViewTypeFileManager];
    } else if(indexPath.section == 2 && indexPath.row == 0){
        [SysDelegate.viewController changeToViewByType:MAViewTypeSetting];
    } else if(indexPath.section == 2 && indexPath.row == 1){
        [SysDelegate.viewController changeToViewByType:MAViewTypeSettingFile];
    } else if(indexPath.section == 3 && indexPath.row == 0){
        [SysDelegate.viewController changeToViewByType:MAViewTypePlanCustomize];
    } else if(indexPath.section == 4 && indexPath.row == 0){
        [SysDelegate.viewController changeToViewByType:MAViewTypeAboutUs];
    }
}
@end
