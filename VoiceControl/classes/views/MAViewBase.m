//
//  MAViewBase.m
//  VoiceControl
//
//  Created by 刘坤 on 13-8-6.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewBase.h"

@interface MAViewBase ()

@property (nonatomic, strong) NSMutableArray* viewArray;
@property (nonatomic, strong) MAViewBase* parentView;

@end

@implementation MAViewBase

@synthesize viewTitle = _viewTitle;
@synthesize subEventLeft = _subEventLeft;
@synthesize subEventRight = _subEventRight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _viewType = MAViewTypeBase;
        _subEventLeft = NO;
        _subEventRight = NO;
    }
    return self;
}

#pragma mark - view appear methods
-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:nil rightBtn:nil enabled:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
}

#pragma mark - for stack frame
-(void)pushView:(MAViewBase*)view animatedType:(MAType)type{
    [self pushView:self subView:view animatedType:type];
}

-(void)pushView:(MAViewBase*)parentView subView:(MAViewBase*)subView animatedType:(MAType)type{
    if (_parentView) {
        [_parentView pushView:_parentView subView:subView animatedType:type];
    } else {
        //视图缓存
        subView.parentView = self;
        if (_viewArray == nil) {
            _viewArray = [[NSMutableArray alloc] init];
        }
        [_viewArray addObject:subView];
        
        if (type == MATypeChangeViewNull) {
            [subView viewWillAppear:NO];
            [parentView viewWillDisappear:NO];
        } else {
            [subView viewWillAppear:YES];
            [parentView viewWillDisappear:YES];
        }
        
        //切换视图
        [SysDelegate.viewController pushView:subView animatedType:type];
    }
}

-(void)popView:(MAType)type{
    [self popView:self animatedType:type];
}

-(void)popView:(MAViewBase*)subView animatedType:(MAType)type{
    if (_parentView) {
        [_parentView popView:subView animatedType:type];
    } else {
        if (_viewArray) {
            MAViewBase* view = self;
            if ([_viewArray count] >= 2) {
                view = [_viewArray objectAtIndex:[_viewArray count] - 2];
            }
            
            if (type == MATypeChangeViewNull) {
                [view viewWillAppear:NO];
                [subView viewWillDisappear:NO];
            } else {
                [view viewWillAppear:YES];
                [subView viewWillDisappear:YES];
            }

            //切换视图
            [SysDelegate.viewController popView:subView preView:view animatedType:type];
            
            [_viewArray removeLastObject];
            view = nil;
        }
    }
}

#pragma mark - other
-(void)setTopBtn:(NSString*)leftBtn rightBtn:(NSString*)rightBtn enabled:(BOOL)enabled{
    if (enabled) {
        [self setSubEventLeft:YES];
        [self setSubEventRight:YES];
    } else {
        if (leftBtn) {
            [self setSubEventLeft:YES];
        } else {
            [self setSubEventLeft:NO];
        }
        
        if (rightBtn) {
            [self setSubEventRight:YES];
        } else {
            [self setSubEventRight:NO];
        }
    }
    
    [SysDelegate.viewController setTopBtn:leftBtn rightBtn:rightBtn enabled:enabled];
}

-(void)showView{
}

-(void)eventTopBtnClicked:(BOOL)left{
    
}
@end
