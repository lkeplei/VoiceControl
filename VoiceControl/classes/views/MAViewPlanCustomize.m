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

@interface MAViewPlanCustomize ()

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
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - other
-(void)showView{
    NSArray* array = [[MADataManager shareDataManager] selectValueFromTabel:nil tableName:KTablePlan];
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
        if (_resourceArray == nil) {
            _resourceArray = [[NSMutableArray alloc] init];
        } else {
            [_resourceArray removeAllObjects];
        }
    }
}

-(void)eventTopBtnClicked:(BOOL)left{
    if (left) {
        
    } else {
        [SysDelegate.viewController changeToViewByType:MAViewTypeAddPlan];
    }
}
@end
