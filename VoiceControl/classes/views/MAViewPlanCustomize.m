//
//  MAViewPlanCustomize.m
//  VoiceControl
//
//  Created by apple on 14-1-21.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewPlanCustomize.h"
#import "MAViewController.h"
#import "MADataManager.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MACellPlan.h"
#import "MAViewAddPlan.h"
#import "MAUtils.h"

#define KCellPlanHeight         (65)
#define KDelCellTag(a, b)       1000 + (100 * a + b)

@interface MAViewPlanCustomize ()

@property (assign) BOOL editing;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* resourceArray;

@end

@implementation MAViewPlanCustomize

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypePlanCustomize;
        self.viewTitle = MyLocal(@"view_title_plan_customize");
        
        _editing = NO;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{

}

#pragma mark - init area
- (void) initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.frame.size.width,
                                                               self.frame.size.height)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.rowHeight = KCellPlanHeight;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.allowsSelectionDuringEditing = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_resourceArray) {
        return [_resourceArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    MACellPlan* cell = (MACellPlan*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[MACellPlan alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    if (_resourceArray && [_resourceArray count] > 0) {
        if (_resourceArray && [indexPath row] < [_resourceArray count]) {
            [cell setCellResource:[_resourceArray objectAtIndex:[indexPath row]] editing:_editing];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_editing) {
        NSDictionary* dic = [[NSDictionary alloc] initWithDictionary:[_resourceArray objectAtIndex:[indexPath row]]];
        
        [SysDelegate.viewController changeToViewByType:MAViewTypeAddPlan];
        
        MAViewBase* view = [SysDelegate.viewController getView:MAViewTypeAddPlan];
        [(MAViewAddPlan*)view setResource:dic];
        
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KPlanCustomModify label:nil];
    }
}

//编辑状态
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MADataManager shareDataManager] deleteValueFromTabel:nil tableName:KTablePlan
                                                            ID:[[[_resourceArray objectAtIndex:[indexPath row]]objectForKey:KDataBaseId] intValue]];
        [_resourceArray removeObjectAtIndex:[indexPath row]];
        
        if ([_resourceArray count] <= 0) {
            [self setViewStatusEdit:NO];
        }
        
        [_tableView reloadData];
        
        //删除计划之后重置
        [[MAModel shareModel] resetPlan];
    }
}


#pragma mark - other
-(void)showView{
    NSArray* array = [[MADataManager shareDataManager] selectValueFromTabel:nil tableName:KTablePlan];
    if (array && [array count] > 0) {
        [self initResouce:array];
        
        if (_tableView == nil) {
            [self initTable];
        }
        [_tableView reloadData];
        
        [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:MyLocal(@"plan_top_right") enabled:NO];
    } else {
        [self setTopBtn:@"" rightBtn:MyLocal(@"plan_top_right") enabled:NO];
        
        UILabel* label = [MAUtils labelWithTxt:MyLocal(@"plan_no_plan")
                                         frame:CGRectMake(10, 150, 300, 30)
                                          font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize22]
                                         color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
        [self addSubview:label];
        
        UILabel* content = [MAUtils labelWithTxt:MyLocal(@"plan_nothing_content")
                                           frame:CGRectMake(10, CGRectGetMaxY(label.frame), 300, 50)
                                            font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                           color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
        content.numberOfLines = 0;
        [self addSubview:content];
    }
}

- (void)initResouce:(NSArray*)array{
    if (array) {
        if (_resourceArray == nil) {
            _resourceArray = [[NSMutableArray alloc] init];
        } else {
            [_resourceArray removeAllObjects];
        }
        
        [_resourceArray addObjectsFromArray:array];
    }
}

-(void)eventTopBtnClicked:(BOOL)left{
    if (left) {
        if (_resourceArray && [_resourceArray count] > 0) {
            [self setViewStatusEdit:!_editing];
        }
    } else {
        [SysDelegate.viewController changeToViewByType:MAViewTypeAddPlan];
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KPlanCustomAdd label:nil];
    }
}

-(void)setViewStatusEdit:(BOOL)edit{
    _editing = edit;
    [_tableView setEditing:_editing animated:YES];
    
    if (edit) {
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KPlanCustomEdit label:nil];
        
        [self setTopBtn:MyLocal(@"plan_top_ok") rightBtn:MyLocal(@"plan_top_right") enabled:NO];
    } else {
        [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:MyLocal(@"plan_top_right") enabled:NO];
    }
    
    [_tableView reloadData];
}
@end
