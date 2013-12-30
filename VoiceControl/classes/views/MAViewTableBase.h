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

@interface MAViewTableBase : MAViewBase<UITableViewDataSource, UITableViewDelegate, MASectionHeadDelegate>

@property (assign) BOOL cellEnabled;

- (void) setTableResource:(NSString*)res;

-(void)cellWillLoad:(MACellBase*)cell;
-(void)cellDidLoad:(MACellBase*)cell;

@end
