//
//  MACheckBox.h
//  VoiceControl
//
//  Created by ken on 13-5-7.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MACheckBox;
//Protocol协议 ,声明了可以被任何类实现的方法
@protocol checkBoxDelegate <NSObject>
-(void)checkBoxSelectedAtIndex:(MACheckBox*)box curSeleckeds:(NSMutableArray *)selecteds;
@end

@interface MACheckBox : UIView

@property(nonatomic, strong) UIButton* button;
@property(nonatomic, strong) UILabel* label;
@property(nonatomic, strong) NSString* seleceds;
@property(nonatomic, strong) NSString *groupId;
@property(nonatomic, assign) NSUInteger index;

//initWithGroupId始化（将每一个button添加到静态数组rb_instances中）方法
-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index text:(NSString*)text;
-(BOOL)checkboxSelected:(id)sender;
-(void)setButtonSelected:(BOOL)selected;

//addObserverForGroupId添加radio分组对象到静态字典rb_observers中的方法
+(void)addObserverForGroupId:(NSString*)groupId observer:(id)observer;
+(MACheckBox*)findBoxByIndex:(NSUInteger)index;
+(NSMutableArray*)getBoxesByGroupId:(NSString*)groupId selected:(BOOL)selected;

@end
