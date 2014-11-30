//
//  UIView+MAUIView.h
//  VoiceControl
//
//  Created by 刘坤 on 14-11-30.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MAUIView)

- (CGFloat)height;
- (CGFloat)width;
- (CGSize)size;
- (CGPoint)origin;
- (CGFloat)originX;
- (CGFloat)originY;
- (CGFloat)centerX;
- (CGFloat)centerY;
- (void)setOrigin:(CGPoint)point;
- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setSize:(CGSize)size;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setCenterX:(CGFloat)x;
- (void)setCenterY:(CGFloat)y;

@end
