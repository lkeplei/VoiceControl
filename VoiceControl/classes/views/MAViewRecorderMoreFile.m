//
//  MAViewRecorderMoreFile.m
//  VoiceControl
//
//  Created by apple on 14-5-12.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewRecorderMoreFile.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"
#import "MAVoiceFiles.h"

#define KContentViewHeight      (250)
#define KContentTitleHeight     (40)

@interface MAViewRecorderMoreFile ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UILabel* contentTitle;
@property (nonatomic, copy) NSMutableArray* resourceArray;
@end

@implementation MAViewRecorderMoreFile

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initContentView];
        [self initTable];
    }
    return self;
}

-(void)initContentView{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - KContentViewHeight, self.frame.size.width, KContentViewHeight)];
    [_contentView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO]];
    _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor; // set color as you want.
    _contentView.layer.borderWidth = 1.0;
    _contentView.layer.cornerRadius = 4.f;
    
    UIImageView* separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_separator_line.png"]];
    separatorLine.frame = CGRectMake(0, KContentTitleHeight - 1, _contentView.frame.size.width, 1);
    [_contentView addSubview:separatorLine];
    
    _contentTitle = [MAUtils labelWithTxt:nil
                                    frame:CGRectMake(0, 0, _contentView.frame.size.width, KContentTitleHeight)
                                     font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                    color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_contentView addSubview:_contentTitle];
    
    [self addSubview:_contentView];
}

- (void)initTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KContentTitleHeight, _contentView.frame.size.width, KContentViewHeight - KContentTitleHeight)
                                              style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.rowHeight = 42;
	_tableView.showsVerticalScrollIndicator = YES;
    _tableView.allowsSelectionDuringEditing = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
	[_contentView addSubview:_tableView];
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
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [cell setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefault default:NO]];
        
        UIImageView* separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_separator_line.png"]];
        separatorLine.frame = CGRectMake(10, cell.frame.size.height - 1, cell.frame.size.width - 20, 1);
        [cell addSubview:separatorLine];
    }
    
    MAVoiceFiles* voiceFile = [_resourceArray objectAtIndex:indexPath.row];
    if (voiceFile) {
        NSMutableString* content = [[NSMutableString alloc] init];
        NSArray* contentArr = [MAUtils getArrayFromStrByCharactersInSet:voiceFile.custom character:KCharactersInSetCustom];
        if ([contentArr count] >= 1) {
            [content appendString:[contentArr objectAtIndex:0]];
        } else {
            [content appendString:MyLocal(@"custom_default")];
        }
        [content appendFormat:@"-%@", [MAUtils getStringFromDate:voiceFile.time format:@"MMM dd,yyyy"]];
        
        [cell.textLabel setText:content];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.recorderMoreFileBlock) {
        self.recorderMoreFileBlock(indexPath.row);
    }
    [self hideView];
}

#pragma mark - others
-(void)setResource:(NSString*)title array:(NSArray*)array{
    [_contentTitle setText:[NSString stringWithFormat:@"%@(%d)", title, [array count]]];
    
    _resourceArray = [array copy];
    [_tableView reloadData];
}

-(void)showView{
    self.frame = (CGRect){self.frame.origin.x, KContentViewHeight, self.frame.size};
    [UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = (CGRect){CGPointZero, self.frame.size};
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - KContentViewHeight)];
                             view.alpha = 0.1;
                             view.tag = 1111;
                             [view setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
                             [self addSubview:view];
                         }
                     }];
}

-(void)hideView{
    UIView* view = [self viewWithTag:1111];
    if (view) {
        [view removeFromSuperview];
        view = nil;
    }
    
    [UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = (CGRect){self.frame.origin.x, KContentViewHeight, self.frame.size};
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }];
}
@end
