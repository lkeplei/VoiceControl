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

#define KCellPlanHeight         (50)
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

        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
        
        _editing = NO;
        [self initTable];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:nil enabled:NO];
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
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (_resourceArray) {
            return [_resourceArray count];
        }
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    MACellPlan *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MACellPlan alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if ([indexPath section] == 0 && _resourceArray && [_resourceArray count] > 0) {
        if (_resourceArray && [indexPath row] < [_resourceArray count]) {
            [cell setCellResource:[_resourceArray objectAtIndex:[indexPath row]] editing:_editing];
        }
    } else {
        UILabel* label = (UILabel*)[cell.contentView viewWithTag:KDelCellTag([indexPath section], [indexPath row])];
        if (!label) {
            label = [MAUtils labelWithTxt:MyLocal(@"plan_top_right") frame:cell.frame
                                     font:[[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize18]
                                    color:[[MAModel shareModel] getColorByType:MATypeColorDefBlue default:NO]];
            label.tag = KDelCellTag([indexPath section], [indexPath row]);
            [cell.contentView addSubview:label];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] == 0) {
        if (_editing) {
            NSDictionary* dic = [[NSDictionary alloc] initWithDictionary:[_resourceArray objectAtIndex:[indexPath row]]];
            
            [SysDelegate.viewController changeToViewByType:MAViewTypeAddPlan];
            
            MAViewBase* view = [SysDelegate.viewController getView:MAViewTypeAddPlan];
            [(MAViewAddPlan*)view setResource:dic];
        }
    } else if([indexPath section] == 1) {
        [SysDelegate.viewController changeToViewByType:MAViewTypeAddPlan];
    }
}

//编辑状态
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete && [indexPath section] == 0) {
        [[MADataManager shareDataManager] deleteValueFromTabel:nil tableName:KTablePlan
                                                            ID:[[[_resourceArray objectAtIndex:[indexPath row]]objectForKey:KDataBaseId] intValue]];
        [_resourceArray removeObjectAtIndex:[indexPath row]];
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
    }
    
    if (_tableView == nil) {
        [self initTable];
    }
    [_tableView reloadData];
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
        [self setViewStatusEdit:!_editing];
    } else {
        [SysDelegate.viewController changeToViewByType:MAViewTypeAddPlan];
    }
}

-(void)setViewStatusEdit:(BOOL)edit{
    _editing = edit;
    [_tableView setEditing:_editing animated:YES];
    
    if (edit) {
        [self setTopBtn:MyLocal(@"plan_top_ok") rightBtn:nil enabled:NO];
    } else {
        [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:nil enabled:NO];
    }
    
    [_tableView reloadData];
}
@end
