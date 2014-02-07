//
//  MACellBase.m
//  VoiceControl
//
//  Created by 刘坤 on 13-8-11.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MACellBase.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MAModel.h"

#define KOffset         (10)

#define KLabelTag       (1000)
#define KImageTag       (1001)
#define KLeftViewTag    (1002)
#define KRightViewTag   (1003)

@implementation MACellBase

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    if (_separatorLineColor) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, YES);
        CGContextSetLineWidth(context, 1.0f);
        
        CGContextSetStrokeColorWithColor(context, _separatorLineColor.CGColor);
        CGContextMoveToPoint(context, self.frame.origin.x, self.frame.origin.y);
        CGContextAddLineToPoint(context, self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
        
        CGContextStrokePath(context);        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (self.selectionStyle == UITableViewCellSelectionStyleNone) {
        if (selected) {
            if (_selectBackgroundImage) {
                UIImageView* view = [[UIImageView alloc] initWithImage:_selectBackgroundImage];
                view.frame = self.contentView.frame;
                [self setBackgroundView:view];
            } else {
                if (_selectBackgroundColor) {
                    [self setBackgroundColor:_selectBackgroundColor];
                }
            }
        } else {
            if (_normalBackgroundImage) {
                UIImageView* view = [[UIImageView alloc] initWithImage:_normalBackgroundImage];
                view.frame = self.contentView.frame;
                [self setBackgroundView:view];
            } else {
                if (_normalBackgroundColor) {
                    [self setBackgroundColor:_normalBackgroundColor];
                }
            }
        }

    }
}

-(void)setCellResource:(NSDictionary*)resDic offset:(float)offset{
    //是否可以跳转
    BOOL jump = [[resDic objectForKey:KCanJump]boolValue];
    if (jump) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //左右view
    UIView* leftView = [self setLeftView:[resDic objectForKey:KleftView]];
    [self setRightView:[resDic objectForKey:KRightView]];
    
    //背景属性设置
    NSString* bg = [resDic objectForKey:KNorBgColor];
    if (bg) {
        NSArray* colorArr = [bg componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        _normalBackgroundColor = [UIColor colorWithRed:[[colorArr objectAtIndex:0] floatValue] / 255
                                                 green:[[colorArr objectAtIndex:0] floatValue] / 255
                                                  blue:[[colorArr objectAtIndex:0] floatValue] / 255
                                                 alpha:[[colorArr objectAtIndex:0] floatValue]];
    }
    bg = [resDic objectForKey:KSecBgColor];
    if (bg) {
        NSArray* colorArr = [bg componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        _selectBackgroundColor = [UIColor colorWithRed:[[colorArr objectAtIndex:0] floatValue] / 255
                                                 green:[[colorArr objectAtIndex:0] floatValue] / 255
                                                  blue:[[colorArr objectAtIndex:0] floatValue] / 255
                                                 alpha:[[colorArr objectAtIndex:0] floatValue]];
    }
    
    //填内容
    float offx = leftView == nil ? KOffset : leftView.frame.size.width + KOffset;
    offx += offset;
    NSString* img = [resDic objectForKey:KImage];
    if (img) {
        UIImageView* imageView = (UIImageView*)[self.contentView viewWithTag:KImageTag];
        if (imageView) {
            [imageView setImage:[UIImage imageNamed:img]];
        } else {
            imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:img]];
            imageView.frame = CGRectMake(offx, (self.frame.size.height - imageView.frame.size.height) / 2,
                                      imageView.frame.size.width, imageView.frame.size.height);
            imageView.tag = KImageTag;
            [self.contentView addSubview:imageView];
        }
        
        offx += imageView.frame.size.width;
    }
    
    
    UILabel* label = (UILabel*)[self.contentView viewWithTag:KLabelTag];
    if (label) {
        label.text = [resDic objectForKey:KContent];
    } else {
        label = [MAUtils labelWithTxt:[resDic objectForKey:KContent]
                                          frame:CGRectMake(offx, 0,
                                                           self.frame.size.width,
                                                           self.frame.size.height)
                                           font:[UIFont fontWithName:KLabelFontArial
                                                                size:KLabelFontSize18]
                                          color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        label.textAlignment = KTextAlignmentLeft;
        label.tag = KLabelTag;
    }
    [self.contentView addSubview:label];
}

-(UIView*)setLeftView:(NSDictionary*)resDic{
    UIView* view = [self.contentView viewWithTag:KLeftViewTag];
    if (view) {
        [view removeFromSuperview];
    }
    
    if (resDic) {
        view = [[UIView alloc] init];
        NSString* type = [resDic objectForKey:KType];
        if (type) {
            if ([type isEqualToString:KImage]) {
                NSString* img = [resDic objectForKey:KImage];
                if (img) {
                    UIImageView* bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:img]];
                    view.frame = CGRectMake(KOffset, (self.frame.size.height - bgView.frame.size.height) / 2,
                                            bgView.frame.size.width, bgView.frame.size.height);
                    [view addSubview:bgView];
                }
            } else if ([type isEqualToString:KButton]) {
                
            } else if ([type isEqualToString:KText]) {
                self.detailTextLabel.text = [resDic objectForKey:KContent];
            }
            
            view.tag = KLeftViewTag;
            [self.contentView addSubview:view];
        }
    }
    
    return view;
}

-(UIView*)setRightView:(NSDictionary*)resDic{
    UIView* view = [self.contentView viewWithTag:KRightViewTag];
    if (view) {
        [view removeFromSuperview];
    }
    
    if (resDic) {
        view = [[UIView alloc] init];
        NSString* type = [resDic objectForKey:KType];
        if (type) {
            if ([type isEqualToString:KImage]) {
                NSString* img = [resDic objectForKey:KImage];
                if (img) {
                    UIImageView* bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:img]];
                    view.frame = CGRectMake(KOffset, (self.frame.size.height - bgView.frame.size.height) / 2,
                                              bgView.frame.size.width, bgView.frame.size.height);
                    [view addSubview:bgView];
                }
            } else if ([type isEqualToString:KButton]) {
                
            } else if ([type isEqualToString:KSwitch]) {
                float height = [[resDic objectForKey:KHeight] floatValue];
                float width = [[resDic objectForKey:KWidth] floatValue];
                height = height <= 0 ? self.contentView.frame.size.height : height;
                width = width <= 0 ? self.contentView.frame.size.height : width;
                
                UISwitch* switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, width, height)];
                [switcher setOn:[[resDic objectForKey:KSwitchOn]boolValue]];
                [switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                
                view.frame = CGRectMake((self.frame.size.width - width), (self.frame.size.height - height) / 2,
                                        width, height);
                [view addSubview:switcher];
            } else if ([type isEqualToString:KText]) {
                self.detailTextLabel.text = [resDic objectForKey:KContent];
            }
            
            view.tag = KRightViewTag;
            [self.contentView addSubview:view];
        }   
    }
    
    return view;
}

#pragma mark - switch
-(void)switchAction:(id)sender{
    DebugLog(@"switch change");
}
@end
