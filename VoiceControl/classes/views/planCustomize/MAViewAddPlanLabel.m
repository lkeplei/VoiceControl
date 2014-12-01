//
//  MAViewAddPlanLabel.m
//  VoiceControl
//
//  Created by apple on 14-2-7.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAddPlanLabel.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"

@interface MAViewAddPlanLabel ()
@property (nonatomic, strong) UITextField* textFieldLabel;
@property (nonatomic, strong) UITableView* tableView;
@end


@implementation MAViewAddPlanLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAddPlanLabel;
        self.viewTitle = MyLocal(@"view_title_add_plan_label");
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:nil enabled:YES];
}

#pragma mark - init area
- (void)initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.width, 240)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO]];
    [_tableView reloadData];
    
    [self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"addPlanLabelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        _textFieldLabel = [MAUtils textFieldInit:CGRectMake(15, 0, _tableView.width - 30, cell.height)
                                           color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:YES]
                                         bgcolor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:YES]
                                            secu:NO
                                            font:[[MAModel shareModel] getLabelFontSize:KLabelFontArial size:KLabelFontSize18]
                                            text:nil];
        _textFieldLabel.delegate = self;
        _textFieldLabel.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [_textFieldLabel becomeFirstResponder];
        [_textFieldLabel setText:MyLocal(@"plan_add_label_default")];
        [cell.contentView addSubview:_textFieldLabel];
    }

    return cell;
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self eventTopBtnClicked:YES];
    
    return YES;
}

#pragma mark -others
-(void)setText:(NSString*)text{
    [_textFieldLabel setText:text];
}

-(void)showView{
    [self initTable];
}

-(void)eventTopBtnClicked:(BOOL)left{
    if (left) {
        if (self.viewBaseDelegate) {
            NSMutableDictionary* resDic = [[NSMutableDictionary alloc] init];
            [resDic setObject:[_textFieldLabel text] forKey:KText];
            [self.viewBaseDelegate MAViewBack:resDic viewType:self.viewType];
        }
        
        [self popView:MATypeChangeViewNull];
    } else {
    }
}
@end
