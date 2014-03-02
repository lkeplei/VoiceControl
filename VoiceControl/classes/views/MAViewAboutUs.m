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

@implementation MAViewAboutUs

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAboutUs;
        self.viewTitle = MyLocal(@"view_title_about_us");
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    return self;
}

-(void)showView{
    [self initTopView];
    [self initTable];
}

#pragma mark - init area
-(void)initTopView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, KViewHorOffset, self.frame.size.width, KTopViewHeight)];
    
    UIImageView* imgView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-ipad.png"]];
    imgView.center = CGPointMake(_topView.center.x, _topView.center.y);
    [self addSubview:imgView];
    
    UILabel* label = [MAUtils labelWithTxt:[NSString stringWithFormat:@"V %@", [MAUtils getAppVersion]]
                                     frame:CGRectMake(0, CGRectGetMaxY(imgView.frame), _topView.frame.size.width, 20)
                                      font:[[MAModel shareModel] getLaberFontSize:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_topView addSubview:label];

    [self addSubview:_topView];
}

-(void)initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame) + KViewHorOffset,
                                                               self.frame.size.width,
                                                               self.frame.size.height - (CGRectGetMaxY(_topView.frame) + KViewHorOffset))
                                              style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if ([indexPath row] == 0) {
            [cell.textLabel setText:MyLocal(@"about_cell_qq")];
        } else if ([indexPath row] == 1){
            [cell.textLabel setText:MyLocal(@"about_cell_wechat")];
        } else if ([indexPath row] == 2){
            [cell.textLabel setText:MyLocal(@"about_cell_msn")];
        } else if ([indexPath row] == 3){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.textLabel setText:MyLocal(@"about_cell_email")];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] == 3) {
        NSMutableDictionary* mailDic = [[NSMutableDictionary alloc] init];
        [mailDic setObject:[NSArray arrayWithObject:MyLocal(@"about_mail_to")] forKey:KMailToRecipients];
        [mailDic setObject:MyLocal(@"about_mail_subject") forKey:KMailSubject];
        [SysDelegate.viewController sendEMail:mailDic];
    }
}
@end
