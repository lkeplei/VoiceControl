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
-(void)setTopBtn:(NSString*)leftBtn rightBtn:(NSString*)rightBtn;
-(void)eventTopBtnClicked:(BOOL)left;

-(void)viewDidAppear:(BOOL)animated;
-(void)viewDidDisappear:(BOOL)animated;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;

@property (assign)MAViewType viewType;
@property (assign)BOOL subEvent;
@property (nonatomic, strong)NSString* viewTitle;

@end
