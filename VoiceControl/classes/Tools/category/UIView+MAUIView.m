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

@end
