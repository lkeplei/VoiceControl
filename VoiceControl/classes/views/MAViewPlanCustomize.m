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

#define KCellPlanHeight         (50)

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
    [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:MyLocal(@"plan_top_right")];
}

#pragma mark - init area
- (void) initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.frame.size.width,
                                                               self.frame.size.height)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.allowsSelectionDuringEditing = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_resourceArray) {
        return _resourceArray.count;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return KCellPlanHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    MACellPlan *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MACellPlan alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if (_resourceArray && [indexPath row] < [_resourceArray count]) {
        [cell setCellResource:[_resourceArray objectAtIndex:[indexPath row]] editing:_editing];
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
    }
}

//编辑状态

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MADataManager shareDataManager] deleteValueFromTabel:nil tableName:KTablePlan
                                                            ID:[[[_resourceArray objectAtIndex:[indexPath row]]objectForKey:KDataBaseId] intValue]];
        [_resourceArray removeObjectAtIndex:[indexPath row]];
        [_tableView reloadData];
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
        [self setTopBtn:MyLocal(@"plan_top_ok") rightBtn:MyLocal(@"plan_top_right")];
    } else {
        [self setTopBtn:MyLocal(@"plan_top_left") rightBtn:MyLocal(@"plan_top_right")];
    }
    
    [_tableView reloadData];
}
@end
