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
#import "MADataManager.h"
#import "MAViewAddPlanLabel.h"

#define KCellPlanTimeTag        (1000)
#define KCellTitleTag           (1001)

@interface MAViewAddPlan ()

@property (nonatomic, strong) UIPickerView* timePicker;
@property (nonatomic, strong) NSArray* hourArray;
@property (nonatomic, strong) NSArray* secondArray;
@property (nonatomic, strong) UITableView* tableView;

@end

@implementation MAViewAddPlan

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAddPlan;
        self.viewTitle = MyLocal(@"view_title_add_plan");

        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_left") rightBtn:MyLocal(@"plan_add_top_right")];
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
        return 150;
    }
    return 150;
}

#pragma mark - init area
- (void)initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _timePicker.frame.origin.y + _timePicker.frame.size.height,
                                                               self.frame.size.width,
                                                               self.frame.size.height - _timePicker.frame.size.height)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
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
    
    _timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 200)];
    _timePicker.delegate = self;
    _timePicker.dataSource = self;
    
    [_timePicker reloadAllComponents];
    
    //设置转盘默认选中项
    [_timePicker selectRow:[_hourArray count] / 2 inComponent:0 animated:YES];
    [_timePicker selectRow:[_secondArray count] / 2 inComponent:1 animated:YES];
    
    [self addSubview:_timePicker];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        cell.backgroundColor = [[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO];
    }

    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [[cell textLabel] setText:MyLocal(@"plan_add_repeat")];
        [cell.detailTextLabel setText:MyLocal(@"plan_add_repeat_default")];
    } else if (indexPath.row == 1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [[cell textLabel] setText:MyLocal(@"plan_add_label")];
        [cell.detailTextLabel setText:MyLocal(@"plan_add_label_default")];
    }
    
    return cell;
}

#pragma mark - MAViewBackDelegate
-(void)MAViewBack:(NSDictionary*)resource viewType:(MAViewType)type{
    if (type == MAViewTypeAddPlanRepeat) {
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell) {
            [cell.detailTextLabel setText:[resource objectForKey:KText]];
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
        MAViewBase* view = [SysDelegate.viewController getView:MAViewTypeAddPlanRepeat];
        view.delegate = self;
        [self pushView:view animatedType:MATypeChangeViewFlipFromLeft];
    }else if(indexPath.section == 0 && indexPath.row == 1){
        MAViewBase* view = [SysDelegate.viewController getView:MAViewTypeAddPlanLabel];
        view.delegate = self;
        [self pushView:view animatedType:MATypeChangeViewFlipFromLeft];
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (cell) {
            [(MAViewAddPlanLabel*)view setText:[cell.detailTextLabel text]];
        }
    }
}

#pragma mark - other
-(void)showView{
    [self initPicker];
    [self initTable];
}

-(void)eventTopBtnClicked:(BOOL)left{
    if (!left)  {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        NSString* time = [NSString stringWithFormat:@"%@:%@", [_hourArray objectAtIndex:[_timePicker selectedRowInComponent:0]],
                         [_secondArray objectAtIndex:[_timePicker selectedRowInComponent:1]]];
        [dic setObject:time forKey:KDataBaseTime];
        
        [dic setObject:[NSNumber numberWithBool:YES] forKey:KDataBaseStatus];
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell) {
            [dic setObject:[cell.detailTextLabel text] forKey:KDataBasePlanTime];
        }
        
        cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (cell) {
            [dic setObject:[cell.detailTextLabel text] forKey:KDataBaseTitle];
        }

        [[MADataManager shareDataManager] insertValueToTabel:[NSArray arrayWithObjects:dic, nil] tableName:KTablePlan maxCount:0];
    }
    
    [SysDelegate.viewController changeToViewByType:MAViewTypePlanCustomize];
}
@end
