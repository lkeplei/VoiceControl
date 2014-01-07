//
//  MAViewBase.h
//  VoiceControl
//
//  Created by 刘坤 on 13-8-6.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewController.h"

@interface MAViewBase : UIView

-(void)showView;

@property (assign)MAViewType viewType;
@property (nonatomic, strong)NSString* viewTitle;

@end
