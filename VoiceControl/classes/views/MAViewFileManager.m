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
#import "MAViewFactory.h"

#import "MACoreDataManager.h"
#import "MAVoiceFiles.h"

#define KCellFileHeight             (60)

#define KCellButtonTag(a,b)        ((1000 * (a + 1)) + b)
#define KCellImageTag(a,b)         ((101 * (a + 1)) + b)
#define KCellImageSecTag(a,b)      ((501 * (a + 1)) + b)
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
    int     currentSecTag;
}
@property (assign) BOOL editing;
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
        _editing = NO;
        currentRow = 0;
        currentSection = 0;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    if ([[SysDelegate.viewController viewFactory] areadyExistAudioPlay]) {
        [self showAudioPlay];
    }
    
    [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:nil enabled:NO];
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
    _tableView.rowHeight = KCellFileHeight;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
    MACellFile* cell = (MACellFile*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[MACellFile alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.delegate = self;
        cell.tag = KCellButtonTag(indexPath.section, indexPath.row);
    }
    
    [cell setCellResource:[[[_resourceArray objectAtIndex:indexPath.section] objectForKey:KArray] objectAtIndex:indexPath.row] editing:_editing];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_editing) {
        MACellFile* cell = (MACellFile*)[tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            MAVoiceFiles* file = [[[_resourceArray objectAtIndex:indexPath.section] objectForKey:KArray] objectAtIndex:indexPath.row];
            [cell setCellEditing:file.status];
            file.status = !file.status;
        }
    } else {
        if (!showAudioPlay) {
            [self showAudioPlay];
        }

        MAVoiceFiles* file = [[[_resourceArray objectAtIndex:indexPath.section] objectForKey:KArray] objectAtIndex:indexPath.row];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docspath = [paths objectAtIndex:0];
        NSString* filePath = [docspath stringByAppendingFormat:@"/%@.zip", file.name];
        
        
        if ([MAUtils unzipFiles:filePath unZipFielPath:nil]) {
            [_audioPlayControl playWithPath:file array:[[_resourceArray objectAtIndex:indexPath.section] objectForKey:KArray]];
        } else {
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
        }
        
        currentSection = [indexPath section];
        currentRow = [indexPath row];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - for play control view
-(void)showAudioPlay {
    showAudioPlay = YES;
    
    if (_audioPlayControl == nil) {
        _audioPlayControl = [[SysDelegate.viewController viewFactory] getAudioPlayControl:CGRectMake(0, self.frame.size.height,
                                                                                           self.frame.size.width, KAudioPlayViewHeight)];
//        _audioPlayControl = [[MAViewAudioPlayControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height,
//                                                                                     self.frame.size.width, KAudioPlayViewHeight)];
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
            } else {
                currentSection = [_resourceArray count] - 1;
            }
        }
    }
    
    if (res) {
        [_audioPlayControl playWithPath:[resArray objectAtIndex:currentRow] array:resArray];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        currentRow = [resArray count] - 1;
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
            } else {
                currentSection = 0;
            }
        }
    }

    if (res) {
        [_audioPlayControl playWithPath:[resArray objectAtIndex:currentRow] array:resArray];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        currentRow = 0;
    }

    return res;
}

#pragma mark - other
-(void)eventTopBtnClicked:(BOOL)left{
    if (left)  {
        if (_editing) {
            [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:nil enabled:NO];
        } else {
            [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KFileManEdit label:nil];
            
            [self setTopBtn:MyLocal(@"plan_top_ok") rightBtn:MyLocal(@"file_top_more") enabled:NO];
        }
        [MAMenu dismissMenu];
        
        _editing = !_editing;
        [self reloadData];
    } else {
        NSMutableArray* menuItems = [[NSMutableArray alloc] init];
        MAMenuItem* first = [MAMenuItem menuItem:@"MENU" image:nil userInfo:nil target:nil action:NULL];
        [menuItems addObject:first];

        MAMenuItem* item1 = [MAMenuItem menuItem:MyLocal(@"delete")
                                           image:nil
                                        userInfo:nil
                                          target:self
                                          action:@selector(deleteFile:)];
        [menuItems addObject:item1];
        
        MAMenuItem* item2 = [MAMenuItem menuItem:MyLocal(@"file_send_email")
                                           image:nil
                                        userInfo:nil
                                          target:self
                                          action:@selector(sendEmail:)];
        [menuItems addObject:item2];
        
        first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
        first.alignment = NSTextAlignmentCenter;

        [MAMenu showMenuInView:self fromRect:CGRectMake(280, -10, 0, 0) menuItems:menuItems];
    }
}

-(void)showView{
    NSArray* array = [[MACoreDataManager sharedCoreDataManager] queryFromDB:KCoreVoiceFiles sortKey:nil];
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
        for (MAVoiceFiles* file in array) {
            file.status = NO;
            if ([file.level intValue] == MATypeFileForEver && !_editing) {
                if (ever == nil) {
                    ever = [[NSMutableArray alloc] init];
                }
                [ever addObject:file];
            } else if ([file.level intValue] == MATypeFileNormal) {
                NSDateComponents* subcom = [MAUtils getSubFromTwoDate:file.time to:[NSDate date]];
                
                if ([subcom day] >= 7) {
                    if (weekago == nil) {
                        weekago = [[NSMutableArray alloc] init];
                    }
                    [weekago addObject:file];
                } else if ([subcom day] == 0) {
                    if (today == nil) {
                        today = [[NSMutableArray alloc] init];
                    }
                    [today addObject:file];
                } else if ([subcom day] == 1) {
                    if (yestoday == nil) {
                        yestoday = [[NSMutableArray alloc] init];
                    }
                    [yestoday addObject:file];
                } else if ([subcom day] < 7) {
                    if (week == nil) {
                        week = [[NSMutableArray alloc] init];
                    }
                    [week addObject:file];
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
    NSArray* array = [[MACoreDataManager sharedCoreDataManager] queryFromDB:KCoreVoiceFiles sortKey:nil];
    if (array) {
        [self initResouce:array];
        [_tableView reloadData];
    }
}

#pragma mark - cell file back
-(void)MACellFileBack:(MACellFile *)cell btn:(UIButton *)btn{
    int section = KCellButtonSec(cell.tag);
    
    NSMutableArray* menuItems = [[NSMutableArray alloc] init];
    MAMenuItem* first = [MAMenuItem menuItem:@"MENU" image:nil userInfo:nil target:nil action:NULL];
    [menuItems addObject:first];
    
    NSString* name = [[_resourceArray objectAtIndex:section] objectForKey:KName];
    
    if ([name compare:MyLocal(@"file_ever")] == NSOrderedSame) {
        MAMenuItem* item1 = [MAMenuItem menuItem:MyLocal(@"file_cancel_ever")
                                           image:nil
                                        userInfo:[NSNumber numberWithInt:cell.tag]
                                          target:self
                                          action:@selector(cancelFileToEver:)];
        [menuItems addObject:item1];
    } else {
        MAMenuItem* item1 = [MAMenuItem menuItem:MyLocal(@"delete")
                                           image:nil
                                        userInfo:[NSNumber numberWithInt:cell.tag]
                                          target:self
                                          action:@selector(deleteFile:)];
        [menuItems addObject:item1];
        
        MAMenuItem* item2 = [MAMenuItem menuItem:MyLocal(@"file_add_ever")
                                           image:nil
                                        userInfo:[NSNumber numberWithInt:cell.tag]
                                          target:self
                                          action:@selector(addFileToEver:)];
        [menuItems addObject:item2];
    }
    
    MAMenuItem* item3 = [MAMenuItem menuItem:MyLocal(@"file_menu_rename")
                                       image:nil
                                    userInfo:[NSNumber numberWithInt:cell.tag]
                                      target:self
                                      action:@selector(fileRename:)];
    [menuItems addObject:item3];
    
    MAMenuItem* item4 = [MAMenuItem menuItem:MyLocal(@"file_send_email")
                                       image:nil
                                    userInfo:[NSNumber numberWithInt:cell.tag]
                                      target:self
                                      action:@selector(sendEmail:)];
    [menuItems addObject:item4];
    
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;

    [MAMenu showMenuInView:self
                  fromRect:CGRectMake(btn.frame.origin.x, cell.frame.origin.y - _tableView.contentOffset.y,
                                      btn.frame.size.width, btn.frame.size.height)
                 menuItems:menuItems];
}

#pragma mark - pop menu
-(void)deleteFile:(id)sender{
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KFileManDelete label:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docspath = [paths objectAtIndex:0];
    
    if (_editing) {
        for (int i = 0; i < [_resourceArray count]; i++) {
            NSArray* array = [[_resourceArray objectAtIndex:i] objectForKey:KArray];
            for (int j = 0; j < [array count]; j++) {
                MAVoiceFiles* file = [array objectAtIndex:j];
                if (file.status) {
                    [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.zip", file.name]];
                    [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.aac", file.name]];
                    [[MACoreDataManager sharedCoreDataManager] deleteObject:file];
                }
            }
        }
        [self reloadData];
    } else {
        int tag = [(NSNumber*)[sender userInfo] intValue];
        int row = KCellButtonRow(tag);
        int section = KCellButtonSec(tag);

        MAVoiceFiles* file = [[[_resourceArray objectAtIndex:section] objectForKey:KArray] objectAtIndex:row];
        //删除数据库与文件
        [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.zip", file.name]];
        [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.aac", file.name]];
        [[MACoreDataManager sharedCoreDataManager] deleteObject:file];
        
        [self reloadData];
    }
}

-(void)sendEmail:(id)sender{
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KFileManSendMail label:nil];
    
    NSMutableArray* attachArray = [[NSMutableArray alloc] init];
    if (_editing) {
        for (int i = 0; i < [_resourceArray count]; i++) {
            NSArray* array = [[_resourceArray objectAtIndex:i] objectForKey:KArray];
            for (int j = 0; j < [array count]; j++) {
                MAVoiceFiles* file = [array objectAtIndex:j];
                if (file.status) {
                    [attachArray addObject:file.name];
                }
            }
        }
    } else {
        int tag = [(NSNumber*)[sender userInfo] intValue];
        int row = KCellButtonRow(tag);
        int section = KCellButtonSec(tag);

        MAVoiceFiles* file = [[[_resourceArray objectAtIndex:section] objectForKey:KArray] objectAtIndex:row];
        [attachArray addObject:file.name];
    }
    
    NSMutableDictionary* mailDic = [[NSMutableDictionary alloc] init];
    [mailDic setObject:attachArray forKey:KMailAttachment];
    [SysDelegate.viewController sendEMail:mailDic];
}

-(void)changeFileType:(MAType)type sender:(id)sender{
    int tag = [(NSNumber*)[sender userInfo] intValue];
    int row = KCellButtonRow(tag);
    int section = KCellButtonSec(tag);
    
    MAVoiceFiles* file = [[[_resourceArray objectAtIndex:section] objectForKey:KArray] objectAtIndex:row];
    
    NSArray* fileArr = [[MACoreDataManager sharedCoreDataManager] getMAVoiceFile:file.name];
    if (fileArr && [fileArr count] > 0) {
        for (int i = 0; i < [fileArr count]; i++) {
            MAVoiceFiles* file = (MAVoiceFiles*)[fileArr objectAtIndex:i];
            file.level = [MAUtils getNumberByInt:type];
        }
        [[MACoreDataManager sharedCoreDataManager] saveEntry];
    }

    [self reloadData];
}

-(void)addPwd:(id)sender{
    [self changeFileType:MATypeFilePwd sender:sender];
}

-(void)addFileToEver:(id)sender{
    if (_editing) {
        
    } else {
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KFileManAddEver label:nil];
        
        [self changeFileType:MATypeFileForEver sender:sender];
    }
}

-(void)cancelFileToEver:(id)sender{
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KFileManCancelEver label:nil];
    
    [self changeFileType:MATypeFileNormal sender:sender];
}

-(void)fileRename:(id)sender{
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KFileManRename label:nil];
    
    UIAlertView* promptAlert = [[UIAlertView alloc] initWithTitle:MyLocal(@"file_input_new_name")
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:MyLocal(@"cancel")
                                                otherButtonTitles:MyLocal(@"ok"), nil];
    promptAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [promptAlert show];
    
    currentSecTag = [(NSNumber*)[sender userInfo] intValue];
}

#pragma mark - alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField* field = [alertView textFieldAtIndex:0];
        
        int row = KCellButtonRow(currentSecTag);
        int section = KCellButtonSec(currentSecTag);
        
        MAVoiceFiles* file = [[[_resourceArray objectAtIndex:section] objectForKey:KArray] objectAtIndex:row];

        NSArray* fileArr = [[MACoreDataManager sharedCoreDataManager] getMAVoiceFile:file.name];
        if (fileArr && [fileArr count] > 0) {
            for (int i = 0; i < [fileArr count]; i++) {
                MAVoiceFiles* file = (MAVoiceFiles*)[fileArr objectAtIndex:i];
                file.custom = field.text;
            }
            [[MACoreDataManager sharedCoreDataManager] saveEntry];
        }
        
        [_tableView reloadData];
    }
}

@end
