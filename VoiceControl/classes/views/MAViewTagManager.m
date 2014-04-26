//
//  MAViewTagManager.m
//  VoiceControl
//
//  Created by apple on 14-4-25.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewTagManager.h"
#import "MAConfig.h"
#import "MARecordController.h"
#import "MACellTag.h"

#define KCellTagHeight          (50)

@interface MAViewTagManager ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, copy) NSMutableArray* resourceArray;
@end

@implementation MAViewTagManager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MaviewTypeTagManager;
        self.viewTitle = MyLocal(@"view_title_tag_manager");
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:nil enabled:YES];
}

-(void)showView{
    [self initTable];
}


- (void) initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.frame.size.width,
                                                               self.frame.size.height)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.rowHeight = KCellTagHeight;
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
    MACellTag* cell = (MACellTag*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[MACellTag alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if (_resourceArray && [_resourceArray count] > 0) {
        if (_resourceArray && [indexPath row] < [_resourceArray count]) {
            [cell.detailTextLabel setText:[(MATagObject*)[_resourceArray objectAtIndex:indexPath.row] name]];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

//编辑状态
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

    }
}

#pragma mark - other
-(void)eventTopBtnClicked:(BOOL)left{
    if (left)  {
        [self popView:MATypeChangeViewCurlUp];
    }
}

-(void)initTagObject:(NSArray*)tagArray{
    _resourceArray = [tagArray copy];
}
@end
