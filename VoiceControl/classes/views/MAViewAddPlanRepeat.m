//
//  MAViewAddPlanRepeat.m
//  VoiceControl
//
//  Created by apple on 14-2-7.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAddPlanRepeat.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"

#define KTableCellAddPlanReTag(a)           (1000 + a)

@interface MAViewAddPlanRepeat ()
@property (nonatomic, strong) NSMutableArray* weekArray;
@property (nonatomic, strong) UITableView* tableView;
@end

@implementation MAViewAddPlanRepeat

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAddPlanRepeat;
        self.viewTitle = MyLocal(@"view_title_add_plan_repeat");
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
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
    _weekArray = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 0; i < 7; i++) {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
//        NSString* str = [@"plan_add_repeat_" stringByAppendingFormat:@"%d", i];
//        [dic setObject:MyLocal(str) forKey:KText];
        [dic setObject:[MAUtils getStringByInt:i] forKey:KText];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:KStatus];
        [_weekArray addObject:dic];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.frame.size.width,
                                                               self.frame.size.height)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
	[self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_weekArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIImageView* imgView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgAddPlanReSec default:NO]];
        imgView.tag = KTableCellAddPlanReTag(indexPath.row);
        [imgView setHidden:YES];
        imgView.center = CGPointMake(cell.frame.size.width - imgView.frame.size.width, cell.center.y);
        [cell.contentView addSubview:imgView];
    }
    
    NSString* str = [@"plan_add_repeat_" stringByAppendingFormat:@"%@", [[_weekArray objectAtIndex:indexPath.row] objectForKey:KText]];
    [[cell textLabel] setText:MyLocal(str)];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        UIImageView* imgView = (UIImageView*)[cell viewWithTag:KTableCellAddPlanReTag(indexPath.row)];
        if (imgView) {
            BOOL status = [[[_weekArray objectAtIndex:indexPath.row] objectForKey:KStatus] boolValue];
            [imgView setHidden:status];
            [[_weekArray objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:!status] forKey:KStatus];
        }
    }
}

#pragma mark -others
-(void)eventTopBtnClicked:(BOOL)left{
    if (left) {
        if (self.viewBaseDelegate) {
            NSMutableDictionary* resDic = [[NSMutableDictionary alloc] init];
            
            NSString* string = @"";
            int number = 0;
            for (int i = 0; i < [_weekArray count]; i++) {
                if ([[[_weekArray objectAtIndex:i] objectForKey:KStatus] boolValue]) {
                    number++;
                    if (number == 1) {
                        string = [string stringByAppendingString:[[_weekArray objectAtIndex:i] objectForKey:KText]];
                    } else {
                        string = [string stringByAppendingFormat:@",%@", [[_weekArray objectAtIndex:i] objectForKey:KText]];
                    }
                }
            }
            
            if (number == 0) {
                [resDic setObject:[NSString stringWithFormat:@"99,%@", [MAUtils getStringFromDate:[NSDate date] format:KDateFormat]] forKey:KText];
            } else {
                [resDic setObject:string forKey:KText];
            }
            
            [self.viewBaseDelegate MAViewBack:resDic viewType:self.viewType];
        }
        
        [self popView:MATypeChangeViewNull];
    } else {
    }
}
@end
