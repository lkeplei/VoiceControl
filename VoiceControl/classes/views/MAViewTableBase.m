//
//  MAViewTableBase.m
//  VoiceControl
//
//  Created by 刘坤 on 13-7-31.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewTableBase.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MAModel.h"

#define KTableBaseCellHeight            (IsPad ? 88.f : 44.f)

@interface MAViewTableBase ()
@property (nonatomic,strong) NSArray* sectionArray;
@property (nonatomic,strong) NSMutableArray* headArray;
@property (nonatomic,strong) NSDictionary* tableResourceDic;
@property (nonatomic,strong) UITableView* tableView;
@end

@implementation MAViewTableBase

@synthesize cellEnabled = _cellEnabled;

- (void) setTableResource:(NSString*)res{
    _cellEnabled = YES;
    
    //table
    NSMutableDictionary* resdic = LOADDIC(@"table_resource", @"plist");
    NSDictionary* dic = [resdic objectForKey:res];
    
    _tableResourceDic = [dic objectForKey:KTableProperty];
    _sectionArray = [dic objectForKey:KSectionArray];
    
    [self initTable];
}

#pragma mark - init area
- (void) initTable{
    [self initHead];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [[MAModel shareModel] getColorByType:MATypeColorDefault default:NO];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:_tableView];
    
    [_tableView reloadData];
}

-(void)initHead{
    _headArray = [[NSMutableArray alloc] init];
    for (NSDictionary* dic in _sectionArray) {
        MASectionHeadBase* head = [[MASectionHeadBase alloc] init];
        head.delegate = self;
        [head setHeadResource:dic];
        [_headArray addObject:head];
    }
}

#pragma mark - cell
-(void)cellWillLoad:(MACellBase*)cell{
    
}

-(void)cellDidLoad:(MACellBase*)cell{
    
}

#pragma mark - head delegate
-(void)headSelected:(MASectionHeadBase *)head{
    if ([head enabled]) {
        [head setIsExpanded:![head isExpanded]];
        
        [_tableView reloadData];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_headArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    MASectionHeadBase* head = [_headArray objectAtIndex:section];
    return [head isExpanded] ? [[[_sectionArray objectAtIndex:section] objectForKey:KCellArray] count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return KTableBaseCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    MASectionHeadBase* view = [_headArray objectAtIndex:section];
    return [view enabled] ? KTableBaseHeaderHeight : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MASectionHeadBase* view = [_headArray objectAtIndex:section];
    return [view enabled] ? view : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    MACellBase* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MACellBase alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        
        //选中状态
        if (_tableResourceDic) {
            NSNumber* secType = [_tableResourceDic objectForKey:KSecStyle];
            if (secType) {
                cell.selectionStyle = [secType intValue];
            }
            
            NSNumber* enabled = [_tableResourceDic objectForKey:KCellEnabled];
            if (secType) {
                _cellEnabled = [enabled boolValue];
            }
        }
    }
    
    [cell setHeight:KTableBaseCellHeight];
    
    [self cellWillLoad:cell];
    
    if (_cellEnabled) {
        NSDictionary* dic = [_sectionArray objectAtIndex:indexPath.section];
        NSMutableDictionary* resdic = [[dic objectForKey:KCellArray] objectAtIndex:indexPath.row];
        if ([[_headArray objectAtIndex:[indexPath section]] isExpanded]) {
            [cell setCellResource:resdic offset:10];
        } else {
            [cell setCellResource:resdic offset:0];
        }
    }
    
    [self cellDidLoad:cell];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DebugLog(@"do some thing");
}
@end
