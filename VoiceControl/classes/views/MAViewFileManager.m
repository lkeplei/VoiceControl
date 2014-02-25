//
//  MAViewFileManager.m
//  VoiceControl
//
//  Created by 刘坤 on 13-8-2.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewFileManager.h"
#import "MADataManager.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"
#import "MAViewAudioPlayControl.h"
#import "MAMenu.h"

#define KCellLabelNameTag          (100)
#define KCellButtonTag(a,b)        ((1000 * (a + 1)) + b)
#define KCellButtonRow(a)          (a % 1000)
#define KCellButtonSec(a)          ((a / 1000) - 1)

#define KKeyToday                 @"key_today"
#define KKeyYestoday              @"key_yestoday"
#define KKeyOneWeek               @"key_one_week"
#define KKeyOneWeekAgo            @"key_one_week_ago"
#define KKeyEver                  @"key_ever"

@interface MAViewFileManager (){
    BOOL    showAudioPlay;
    int     currentRow;
    int     currentSection;
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* resourceArray;
@property (nonatomic, strong) NSMutableDictionary* resourceDic;
@property (nonatomic, strong) MAViewAudioPlayControl* audioPlayControl;
@end

@implementation MAViewFileManager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
        
        [self initTable];
        
        self.viewType = MAViewTypeFileManager;
        self.viewTitle = MyLocal(@"view_title_file_manager");
        
        showAudioPlay = NO;
        currentRow = 0;
        currentSection = 0;
    }
    return self;
}

#pragma mark - init area
- (void) initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.frame.size.width,
                                                               self.frame.size.height - 20)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_resourceArray) {
        return _resourceArray.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_resourceArray) {
        NSArray* array = [[_resourceArray objectAtIndex:section] objectForKey:KArray];
        if (array) {
            return array.count;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_resourceArray) {
        return [[_resourceArray objectAtIndex:section] objectForKey:KName];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSDictionary* resDic = [[[_resourceArray objectAtIndex:indexPath.section] objectForKey:KArray] objectAtIndex:indexPath.row];
    if (resDic) {
        UILabel* name = (UILabel*)[cell.contentView viewWithTag:KCellLabelNameTag];
        NSString* str = [@"" stringByAppendingFormat:@"%@ - (%@)", [resDic objectForKey:KDataBaseFileName],
                         [[MAModel shareModel] getStringTime:[[resDic objectForKey:KDataBaseDuration] intValue] type:MATypeTimeCh]];
        if (name == nil) {
            name = [MAUtils labelWithTxt:str
                                    frame:CGRectMake(5, 0, cell.frame.size.width, cell.frame.size.height)
                                     font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                    color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
            name.tag = KCellLabelNameTag;
            name.textAlignment = KTextAlignmentLeft;
            [cell.contentView addSubview:name];
        } else {
            name.text = str;
        }

        UIButton* button = (UIButton*)[cell.contentView viewWithTag:KCellButtonTag(indexPath.section, indexPath.row)];
        if (button) {
            [button removeFromSuperview];
        }
        button = [MAUtils buttonWithImg:nil off:0 zoomIn:YES
                                   image:[[MAModel shareModel] getImageByType:MATypeImgHomeMenu default:NO]
                                imagesec:[[MAModel shareModel] getImageByType:MATypeImgHomeMenu default:NO]
                                  target:self
                                  action:@selector(fileBtnClicked:)];
        button.tag = KCellButtonTag(indexPath.section, indexPath.row);
        button.frame = CGRectMake(cell.frame.size.width - cell.frame.size.height, 0, cell.frame.size.height, cell.frame.size.height);
        [cell.contentView addSubview:button];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!showAudioPlay) {
        [self showAudioPlay];
    }
    
    NSDictionary* resDic = [[[_resourceArray objectAtIndex:indexPath.section] objectForKey:KArray] objectAtIndex:indexPath.row];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docspath = [paths objectAtIndex:0];
    NSString* file = [docspath stringByAppendingFormat:@"/%@.zip", [resDic objectForKey:KDataBaseFileName]];
    
    if ([MAUtils unzipFiles:file unZipFielPath:nil]) {
        [_audioPlayControl playWithPath:resDic array:[[_resourceArray objectAtIndex:indexPath.section] objectForKey:KArray]];
    } else {
        [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
    }
    
    currentSection = [indexPath section];
    currentRow = [indexPath row];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - for play control view
-(void)showAudioPlay {
    showAudioPlay = YES;
    
    if (_audioPlayControl == nil) {
        _audioPlayControl = [[MAViewAudioPlayControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height,
                                                                                     self.frame.size.width, KAudioPlayViewHeight)];
        [self addSubview:_audioPlayControl];

        _audioPlayControl.audioPlayCallBack = ^(MAAudioPlayType type){
            BOOL res = YES;
            if (type == MAAudioPlayNext) {
                res = [self playNext];
            } else if (type == MAAudioPlayPre) {
                res = [self playPre];
            } else if (type == MAAudioPlayHide) {
                [self hideAudioPlay];
            }
            return res;
        };

    }
    
	[UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _audioPlayControl.frame = CGRectOffset(_audioPlayControl.frame, 0, -KAudioPlayViewHeight);
        _tableView.frame = CGRectMake(0, 0, self.frame.size.width, _tableView.frame.size.height - KAudioPlayViewHeight + 20);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [_tableView reloadData];
                         }
                     }];
}

-(void)hideAudioPlay {
	[UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _audioPlayControl.frame = CGRectOffset(_audioPlayControl.frame, 0, KAudioPlayViewHeight);
        _tableView.frame = CGRectMake(0, 0, self.frame.size.width, _tableView.frame.size.height + KAudioPlayViewHeight - 20);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             showAudioPlay = NO;
                             [_tableView reloadData];
                         }
                     }];
}

-(BOOL)playNext{
    BOOL res = NO;
    
    NSArray* resArray = [[_resourceArray objectAtIndex:currentSection] objectForKey:KArray];
    if (resArray && [resArray count] > 0) {
        currentRow++;
        if (currentRow < [resArray count]) {
            res = YES;
        } else {
            currentSection++;
            if (currentSection < [_resourceArray count]) {
                resArray = [[_resourceArray objectAtIndex:currentSection] objectForKey:KArray];
                if (resArray && [resArray count] > 0) {
                    currentRow = 0;
                    res = YES;
                }
            }
        }
    }
    
    if (res) {
        [_audioPlayControl playWithPath:[resArray objectAtIndex:currentRow] array:nil];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return res;
}

-(BOOL)playPre{
    BOOL res = NO;
    
    NSArray* resArray = [[_resourceArray objectAtIndex:currentSection] objectForKey:KArray];
    if (resArray && [resArray count] > 0) {
        currentRow--;
        if (currentRow >= 0) {
            res = YES;
        } else {
            currentSection--;
            if (currentSection >= 0) {
                resArray = [[_resourceArray objectAtIndex:currentSection] objectForKey:KArray];
                if (resArray && [resArray count] > 0) {
                    currentRow = [resArray count] - 1;
                    res = YES;
                }
            }
        }
    }

    if (res) {
        [_audioPlayControl playWithPath:[resArray objectAtIndex:currentRow] array:nil];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

return res;
}

#pragma mark - other
-(void)showView{
    NSArray* array = [[MADataManager shareDataManager] selectValueFromTabel:nil tableName:KTableVoiceFiles];
    if (array) {
        [self initResouce:array];
    }
    
    if (_tableView == nil) {
        [self initTable];
    }
    [_tableView reloadData];
}

- (void)initResouce:(NSArray*)array{
    if (array) {
        NSMutableArray* ever = nil;
        NSMutableArray* today = nil;
        NSMutableArray* yestoday = nil;
        NSMutableArray* week = nil;
        NSMutableArray* weekago = nil;
        for (NSDictionary* dic in array) {
            if ([[dic objectForKey:KDataBaseDataEver] intValue] == MATypeFileForEver) {
                if (ever == nil) {
                    ever = [[NSMutableArray alloc] init];
                }
                [ever addObject:dic];
            } else if ([[dic objectForKey:KDataBaseDataEver] intValue] == MATypeFileNormal) {
                NSDate* date = [MAUtils getDateFromString:[dic objectForKey:KDataBaseTime] format:KTimeFormat];
                NSDateComponents* subcom = [MAUtils getSubFromTwoDate:date to:[NSDate date]];
                
                if ([subcom day] >= 7) {
                    if (weekago == nil) {
                        weekago = [[NSMutableArray alloc] init];
                    }
                    [weekago addObject:dic];
                } else if ([subcom day] == 0) {
                    if (today == nil) {
                        today = [[NSMutableArray alloc] init];
                    }
                    [today addObject:dic];
                } else if ([subcom day] == 1) {
                    if (yestoday == nil) {
                        yestoday = [[NSMutableArray alloc] init];
                    }
                    [yestoday addObject:dic];
                } else if ([subcom day] < 7) {
                    if (week == nil) {
                        week = [[NSMutableArray alloc] init];
                    }
                    [week addObject:dic];
                }
            }
        }
        
        if (_resourceArray == nil) {
            _resourceArray = [[NSMutableArray alloc] init];
        } else {
            [_resourceArray removeAllObjects];
        }
        
        if (ever) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:MyLocal(@"file_ever") forKey:KName];
            [dic setObject:ever forKey:KArray];
            [_resourceArray addObject:dic];
        }
        if (today) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:MyLocal(@"file_today") forKey:KName];
            [dic setObject:today forKey:KArray];
            [_resourceArray addObject:dic];
        }
        if (yestoday) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:MyLocal(@"file_yestoday") forKey:KName];
            [dic setObject:yestoday forKey:KArray];
            [_resourceArray addObject:dic];
        }
        if (week) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:MyLocal(@"file_week") forKey:KName];
            [dic setObject:week forKey:KArray];
            [_resourceArray addObject:dic];
        }
        if (weekago) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:MyLocal(@"file_week_ago") forKey:KName];
            [dic setObject:weekago forKey:KArray];
            [_resourceArray addObject:dic];
        }
    }
}

-(void)reloadData{
    //数据重加载
    NSArray* array = [[MADataManager shareDataManager] selectValueFromTabel:nil tableName:KTableVoiceFiles];
    if (array) {
        [self initResouce:array];
        [_tableView reloadData];
    }
}

#pragma mark - pop menu
- (void)fileBtnClicked:(UIButton *)sender{
    int row = KCellButtonRow(sender.tag);
    int section = KCellButtonSec(sender.tag);
    
    NSMutableArray* menuItems = [[NSMutableArray alloc] init];
    MAMenuItem* first = [MAMenuItem menuItem:@"MENU" image:nil userInfo:nil target:nil action:NULL];
    [menuItems addObject:first];
    
    NSString* name = [[_resourceArray objectAtIndex:section] objectForKey:KName];
    
    if ([name compare:MyLocal(@"file_ever")] == NSOrderedSame) {
        MAMenuItem* item1 = [MAMenuItem menuItem:MyLocal(@"file_cancel_ever")
                                           image:nil
                                        userInfo:[NSNumber numberWithInt:sender.tag]
                                          target:self
                                          action:@selector(cancelFileToEver:)];
        [menuItems addObject:item1];
    } else {
        MAMenuItem* item1 = [MAMenuItem menuItem:MyLocal(@"delete")
                                           image:nil
                                        userInfo:[NSNumber numberWithInt:sender.tag]
                                          target:self
                                          action:@selector(deleteFile:)];
        [menuItems addObject:item1];
        
        MAMenuItem* item2 = [MAMenuItem menuItem:MyLocal(@"file_add_ever")
                                           image:nil
                                        userInfo:[NSNumber numberWithInt:sender.tag]
                                          target:self
                                          action:@selector(addFileToEver:)];
        [menuItems addObject:item2];
    }
    
//    MAMenuItem* item3 = [MAMenuItem menuItem:MyLocal(@"file_add_pwd")
//                                       image:nil
//                                    userInfo:[NSNumber numberWithInt:sender.tag]
//                                      target:self
//                                      action:@selector(addPwd:)];
//    [menuItems addObject:item3];
    
    MAMenuItem* item4 = [MAMenuItem menuItem:MyLocal(@"file_send_email")
                                       image:nil
                                    userInfo:[NSNumber numberWithInt:sender.tag]
                                      target:self
                                      action:@selector(sendEmail:)];
    [menuItems addObject:item4];
    
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    [MAMenu showMenuInView:self
                  fromRect:CGRectMake(sender.frame.origin.x, cell.frame.origin.y - _tableView.contentOffset.y,
                                      sender.frame.size.width, sender.frame.size.height)
                 menuItems:menuItems];
}

-(void)deleteFile:(id)sender{
    int tag = [(NSNumber*)[sender userInfo] intValue];
    int row = KCellButtonRow(tag);
    int section = KCellButtonSec(tag);
    
    NSDictionary* resDic = [[[_resourceArray objectAtIndex:section] objectForKey:KArray] objectAtIndex:row];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docspath = [paths objectAtIndex:0];
    
    //删除数据库与文件
    [[MADataManager shareDataManager] deleteValueFromTabel:nil tableName:KTableVoiceFiles ID:[[resDic objectForKey:KDataBaseId] intValue]];
    [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.zip", [resDic objectForKey:KDataBaseFileName]]];
    [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.aac", [resDic objectForKey:KDataBaseFileName]]];
    
    [self reloadData];
}

-(void)sendEmail:(id)sender{
    int tag = [(NSNumber*)[sender userInfo] intValue];
    int row = KCellButtonRow(tag);
    int section = KCellButtonSec(tag);
    
    NSDictionary* resDic = [[[_resourceArray objectAtIndex:section] objectForKey:KArray] objectAtIndex:row];
    NSArray* array = [NSArray arrayWithObjects:[resDic objectForKey:KDataBaseFileName], nil];
    [SysDelegate.viewController sendEMail:array];
}

-(void)changeFileType:(MAType)type sender:(id)sender{
    int tag = [(NSNumber*)[sender userInfo] intValue];
    int row = KCellButtonRow(tag);
    int section = KCellButtonSec(tag);
    
    NSMutableDictionary* resDic = [[[_resourceArray objectAtIndex:section] objectForKey:KArray] objectAtIndex:row];
    //删除数据库与文件
    [[MADataManager shareDataManager] deleteValueFromTabel:nil tableName:KTableVoiceFiles ID:[[resDic objectForKey:KDataBaseId] intValue]];
    //添加数据
    NSMutableArray* resArr = [[NSMutableArray alloc] init];
    [resDic setObject:[MAUtils getNumberByInt:type] forKey:KDataBaseDataEver];
    [resArr addObject:resDic];
    [[MADataManager shareDataManager] insertValueToTabel:resArr tableName:KTableVoiceFiles maxCount:0];
    
    [self reloadData];
}

-(void)addPwd:(id)sender{
    [self changeFileType:MATypeFilePwd sender:sender];
}

-(void)addFileToEver:(id)sender{
    [self changeFileType:MATypeFileForEver sender:sender];
}

-(void)cancelFileToEver:(id)sender{
    [self changeFileType:MATypeFileNormal sender:sender];
}

#pragma mark - email


@end
