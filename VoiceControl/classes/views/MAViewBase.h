//
//  MAViewBase.h
//  VoiceControl
//
//  Created by 刘坤 on 13-8-6.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewController.h"
#import "MAModel.h"

@protocol MAViewBaseDelegate <NSObject>
-(void)MAViewBack:(NSDictionary*)resource viewType:(MAViewType)type;
@end

@interface MAViewBase : UIView

-(void)showView;
//enabled：yes不管有没有文字都有效、no只有有文字显示才有效
-(void)setTopBtn:(NSString*)leftBtn rightBtn:(NSString*)rightBtn enabled:(BOOL)enabled;
-(void)eventTopBtnClicked:(BOOL)left;

-(void)viewDidAppear:(BOOL)animated;
-(void)viewDidDisappear:(BOOL)animated;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;

-(void)pushView:(MAViewBase*)view animatedType:(MAType)type;
-(void)popView:(MAType)type;

@property (assign)MAViewType viewType;
@property (assign)BOOL subEventLeft;
@property (assign)BOOL subEventRight;
@property (nonatomic, strong)NSString* viewTitle;

@property (nonatomic, assign) id<MAViewBaseDelegate> delegate;

@end
