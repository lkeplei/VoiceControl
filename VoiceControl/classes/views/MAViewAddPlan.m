//
//  MAViewAddPlan.m
//  VoiceControl
//
//  Created by apple on 14-1-21.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAddPlan.h"
#import "MAModel.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MADataManager.h"
#import "MAViewAddPlanLabel.h"
#import "MAViewAddPlanDuration.h"

#define KCellPlanTimeTag        (1000)
#define KCellTitleTag           (1001)
#define KCellDeleteTag          (1002)

@interface MAViewAddPlan (){
    int     duration;
}

@property (nonatomic, strong) NSMutableDictionary* resourceDic;
@property (nonatomic, strong) UIPickerView* timePicker;
@property (nonatomic, strong) NSArray* hourArray;
@property (nonatomic, strong) NSArray* secondArray;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSString* planTimeString;

@end

@implementation MAViewAddPlan

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAddPlan;
        self.viewTitle = MyLocal(@"view_title_add_plan");

        duration = 60;
        _planTimeString = [NSString stringWithFormat:@"99,%@", [MAUtils getStringFromDate:[NSDate date] format:KDateFormat]];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_left") rightBtn:MyLocal(@"plan_add_top_right") enabled:YES];
}

#pragma mark -
#pragma mark Picker Date Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_hourArray count];
    }
    return [_secondArray count];
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [_hourArray objectAtIndex:row];
    }
    return [_secondArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
//        NSString *selectedState = [self.provinces objectAtIndex:row];
//        NSArray *array = [provinceCities objectForKey:selectedState];
//        self.cities = array;
//        [picker selectRow:0 inComponent:kCityComponent animated:YES];
//        [picker reloadComponent:kCityComponent];
    } else {
        
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    //可以根据选项改变转盘宽
    if (component == 0) {
        return 60;
    }
    return 60;
}

#pragma mark - init area
- (void)initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _timePicker.frame.origin.y + _timePicker.frame.size.height,
                                                               self.frame.size.width,
                                                               self.frame.size.height - _timePicker.frame.size.height)
                                              style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO]];
	[self addSubview:_tableView];
}

- (void)initPicker{
    _hourArray = [NSArray arrayWithObjects:@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10",
                  @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", nil];
    _secondArray = [NSArray arrayWithObjects:@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10",
                    @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25",
                    @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40",
                    @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55",
                    @"56", @"57", @"58", @"59", nil];
    
    _timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 160)];
    _timePicker.delegate = self;
    _timePicker.dataSource = self;
    [_timePicker setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
    
    [_timePicker reloadAllComponents];
    
    //设置转盘默认选中项
    [_timePicker selectRow:[_hourArray count] / 2 inComponent:0 animated:YES];
    [_timePicker selectRow:[_secondArray count] / 2 inComponent:1 animated:YES];
    
    [self addSubview:_timePicker];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_resourceDic) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([indexPath section] == 1) {
            UILabel* label = [MAUtils labelWithTxt:MyLocal(@"plan_add_delete") frame:cell.frame
                                              font:[[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize18]
                                             color:[[MAModel shareModel] getColorByType:MATypeColorDefBlue default:NO]];
            [cell.contentView addSubview:label];
        }
    }

    if ([indexPath section] == 0) {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [[cell textLabel] setText:MyLocal(@"plan_add_repeat")];
            if (_resourceDic && [[_resourceDic objectForKey:KDataBasePlanTime] length] > 0) {
                NSString* planTime = [_resourceDic objectForKey:KDataBasePlanTime];
                if ([planTime length] >= 2 && [[planTime substringToIndex:2] compare:@"99"] != NSOrderedSame) {
                    _planTimeString = planTime;
                }
                [cell.detailTextLabel setText:[[MAModel shareModel] getRepeatTest:_planTimeString add:YES]];
            } else {
                [cell.detailTextLabel setText:MyLocal(@"plan_add_repeat_default")];
            }
        } else if (indexPath.row == 1){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [[cell textLabel] setText:MyLocal(@"plan_add_label")];
            if (_resourceDic) {
                [cell.detailTextLabel setText:[_resourceDic objectForKey:KDataBaseTitle]];
            } else {
                [cell.detailTextLabel setText:MyLocal(@"plan_add_label_default")];
            }
        } else if (indexPath.row == 2){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [[cell textLabel] setText:MyLocal(@"plan_add_duration")];
            if (_resourceDic) {
                duration = [[_resourceDic objectForKey:KDataBaseDuration] intValue];
                [cell.detailTextLabel setText:[self getDateString:duration]];
            } else {
                [cell.detailTextLabel setText:MyLocal(@"plan_add_duration_default")];
            }
        }
    }
    
    return cell;
}

#pragma mark - MAViewBackDelegate
-(void)MAViewBack:(NSDictionary*)resource viewType:(MAViewType)type{
    if (type == MAViewTypeAddPlanRepeat) {
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell) {
            _planTimeString = [resource objectForKey:KText];
            [cell.detailTextLabel setText:[[MAModel shareModel] getRepeatTest:[resource objectForKey:KText] add:YES]];
        }
    } else if(type == MAViewTypeAddPlanLabel){
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (cell) {
            [cell.detailTextLabel setText:[resource objectForKey:KText]];
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KAddPlanRepeat label:nil];
        
        MAViewBase* view = [SysDelegate.viewController getView:MAViewTypeAddPlanRepeat];
        view.viewBaseDelegate = self;
        [self pushView:view animatedType:MATypeChangeViewFlipFromLeft];
    } else if(indexPath.section == 0 && indexPath.row == 1){
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KAddPlanLabel label:nil];
        
        MAViewBase* view = [SysDelegate.viewController getView:MAViewTypeAddPlanLabel];
        view.viewBaseDelegate = self;
        [self pushView:view animatedType:MATypeChangeViewFlipFromLeft];
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (cell) {
            [(MAViewAddPlanLabel*)view setText:[cell.detailTextLabel text]];
        }
    } else if(indexPath.section == 0 && indexPath.row == 2){
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KAddPlanDuration label:nil];
        
        MAViewBase* view = [SysDelegate.viewController getView:MAViewTypeAddPlanDuration];
        
        ((MAViewAddPlanDuration*)view).durationCallBack = ^(NSDictionary* resDic, MAViewType type){
            if (type == MAViewTypeAddPlanDuration) {
                UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                if (cell) {
                    duration = [[resDic objectForKey:KText] intValue];
                    [cell.detailTextLabel setText:[self getDateString:duration]];
                }
            }
        };
        
        [self pushView:view animatedType:MATypeChangeViewFlipFromLeft];
    } else if(indexPath.section == 1 && indexPath.row == 0){
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KAddPlanDelete label:nil];
        
        [[MADataManager shareDataManager] deleteValueFromTabel:nil tableName:KTablePlan ID:[[_resourceDic objectForKey:KDataBaseId] intValue]];
        
        [SysDelegate.viewController changeToViewByType:MAViewTypePlanCustomize];
    }
}

#pragma mark - other
-(void)showView{
    [self initPicker];
    [self initTable];
}

-(void)eventTopBtnClicked:(BOOL)left{
    if (!left)  {
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KAddPlanSave label:nil];
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        NSString* time = [NSString stringWithFormat:@"%@:%@", [_hourArray objectAtIndex:[_timePicker selectedRowInComponent:0]],
                          [_secondArray objectAtIndex:[_timePicker selectedRowInComponent:1]]];
        [dic setObject:time forKey:KDataBaseTime];
        
        [dic setObject:[NSNumber numberWithBool:YES] forKey:KDataBaseStatus];
        [dic setObject:_planTimeString forKey:KDataBasePlanTime];
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (cell) {
            [dic setObject:[cell.detailTextLabel text] forKey:KDataBaseTitle];
        }
        
        [dic setObject:[MAUtils getStringByInt:duration] forKey:KDataBaseDuration];
        
        if (_resourceDic) {
            [dic setObject:[_resourceDic objectForKey:KDataBaseId] forKey:KDataBaseId];
            [[MADataManager shareDataManager] replaceValueToTabel:[NSArray arrayWithObjects:dic, nil] tableName:KTablePlan];
        } else {
            [[MADataManager shareDataManager] insertValueToTabel:[NSArray arrayWithObjects:dic, nil] tableName:KTablePlan maxCount:0];
        }
        
        //添加或者修改计划之后重置
        [[MAModel shareModel] resetPlan];
    }
    
    [SysDelegate.viewController changeToViewByType:MAViewTypePlanCustomize];
}

-(void)setResource:(NSDictionary*)resDic{
    _resourceDic = [[NSMutableDictionary alloc] initWithDictionary:resDic];
    [_tableView reloadData];
    
    NSArray* array = [MAUtils getArrayFromStrByCharactersInSet:[_resourceDic objectForKey:KDataBaseTime] character:@":"];
    if ([array count] == 2) {
        [_timePicker selectRow:[[array objectAtIndex:0] intValue] inComponent:0 animated:YES];
        [_timePicker selectRow:[[array objectAtIndex:1] intValue] inComponent:1 animated:YES];
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
