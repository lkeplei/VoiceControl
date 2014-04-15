//
//  MAViewAddPlanDuration.m
//  VoiceControl
//
//  Created by apple on 14-2-14.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAddPlanDuration.h"
#import "MAConfig.h"
#import "MAModel.h"

@interface MAViewAddPlanDuration ()
@property (nonatomic, strong) NSArray* durationArray;
@property (nonatomic, strong) UITableView* tableView;
@end

@implementation MAViewAddPlanDuration

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAddPlanDuration;
        self.viewTitle = MyLocal(@"view_title_add_plan_duration");
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:nil enabled:YES];
}

-(void)showView{
    [self initTable];
}

#pragma mark - init area
- (void)initTable{
    _durationArray = [[NSArray alloc] initWithObjects:@"5", @"10", @"20", @"30", @"60", @"120",
                      @"180", @"300", @"480", @"720", @"1080", @"1440", nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.frame.size.width,
                                                               self.frame.size.height - KStatusBarHeight)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_durationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    [[cell textLabel] setText:[self getDateString:[[_durationArray objectAtIndex:indexPath.row] intValue]]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        if (self.durationCallBack) {
            NSMutableDictionary* resDic = [[NSMutableDictionary alloc] init];
            [resDic setObject:[_durationArray objectAtIndex:indexPath.row] forKey:KText];
            self.durationCallBack(resDic, self.viewType);
        }
        
        [self popView:MATypeChangeViewNull];
    }
}

#pragma mark -others
-(void)eventTopBtnClicked:(BOOL)left{
    if (left) {
        [self popView:MATypeChangeViewNull];
    } else {
    }
}

-(NSString*)getDateString:(int)date{
    if (date < 60) {
        return [NSString stringWithFormat:MyLocal(@"time_minute"), date];
    } else {
        return [NSString stringWithFormat:MyLocal(@"time_hour"), date / 60];
    }
}
@end
