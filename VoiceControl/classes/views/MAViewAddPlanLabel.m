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
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:nil enabled:YES];
}

#pragma mark - init area
- (void)initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40,
                                                               self.frame.size.width, 240)
                                              style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    [_tableView reloadData];
    
    [self addSubview:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //        cell.backgroundColor = [[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO];
        
        _textFieldLabel = [MAUtils textFieldInit:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
                                           color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:YES]
                                         bgcolor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:YES]
                                            secu:NO
                                            font:[[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize18]
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
        if (self.delegate) {
            NSMutableDictionary* resDic = [[NSMutableDictionary alloc] init];
            [resDic setObject:[_textFieldLabel text] forKey:KText];
            [self.delegate MAViewBack:resDic viewType:self.viewType];
        }
        
        [self popView:MATypeChangeViewNull];
    } else {
    }
}
@end
