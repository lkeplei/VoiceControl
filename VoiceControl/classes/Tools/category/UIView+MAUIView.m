//
//  UIView+MAUIView.m
//  VoiceControl
//
//  Created by 刘坤 on 14-11-30.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "UIView+MAUIView.h"

@implementation UIView (MAUIView)

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGSize)size {
    return self.frame.size;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGFloat)originX {
    return self.frame.origin.x;
}

- (CGFloat)originY {
    return self.frame.origin.y;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setOrigin:(CGPoint)point {
    [self setFrame:(CGRect){point, self.size}];
}

- (void)setOriginX:(CGFloat)x {
    [self setFrame:(CGRect){x, self.originY, self.size}];
}

- (void)setOriginY:(CGFloat)y {
    [self setFrame:(CGRect){self.originX, y, self.size}];
}

- (void)setSize:(CGSize)size {
    [self setFrame:(CGRect){self.origin, size}];
}

- (void)setWidth:(CGFloat)width {
    [self setFrame:(CGRect){self.origin, width, self.height}];
}

- (void)setHeight:(CGFloat)height {
    [self setFrame:(CGRect){self.origin, self.width, height}];
}

- (void)setCenterX:(CGFloat)x {
    self.center = CGPointMake(x, [self centerY]);
}

- (void)setCenterY:(CGFloat)y {
    self.center = CGPointMake([self centerX], y);
}
@end
