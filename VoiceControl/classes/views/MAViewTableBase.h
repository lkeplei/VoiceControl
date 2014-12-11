//
//  MAViewTableBase.h
//  VoiceControl
//
//  Created by 刘坤 on 13-7-31.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewBase.h"
#import "MACellBase.h"
#import "MASectionHeadBase.h"

#define KTableBaseCellHeight            (IsPad ? 88.f : 44.f)

@interface MAViewTableBase : MAViewBase<UITableViewDataSource, UITableViewDelegate, MASectionHeadDelegate>

@property (assign) BOOL cellEnabled;
@property (nonatomic,strong) NSArray* sectionArray;
@property (nonatomic,strong) UITableView* tableView;

- (void)setTableResource:(NSString*)res;

- (CGRect)getTableFrame;
- (void)cellWillLoad:(MACellBase*)cell;
- (void)cellDidLoad:(MACellBase*)cell;

@end
