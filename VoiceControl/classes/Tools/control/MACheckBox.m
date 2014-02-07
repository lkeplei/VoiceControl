//
//  MACheckBox.m
//  VoiceControl
//
//  Created by ken on 13-5-7.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MACheckBox.h"
#import "MAUtils.h"
#import "MAConfig.h"
#import "MAModel.h"

//内部调用的接口方法
@interface MACheckBox()
-(void)defaultInit; //初始化
-(BOOL)checkboxSelected:(id)sender;
-(void)handleButtonTap:(id)sender;     //设置选择
@end

@implementation MACheckBox
//属性
@synthesize groupId = _groupId;
@synthesize index = _index;
@synthesize button = _button;
@synthesize label = _label;
@synthesize seleceds = _seleceds;

//定义静态变量
static const NSUInteger kBoxWidth = 150;
static const NSUInteger kBoxHeight = 25;
static const NSUInteger kBoxOff = 4;
static NSMutableArray* box_instances = nil;      //用于存放按钮的静态数组
static NSMutableDictionary* box_observers = nil; //按分组名称存放空间对象的字典

+(void)addObserverForGroupId:(NSString*)groupId observer:(id)observer{
	//创建box_observers对象
	if (!box_observers) {
		box_observers = [[NSMutableDictionary alloc] init];
	}
	
	//两个参数都存在，则将其添加到可变字典box_observers中
	if ([groupId length]>0 && observer) {
		[box_observers setObject:observer forKey:groupId];
	}
}

//将按钮添加到静态数组rb_instances中
+(void)registerInstance:(MACheckBox *)checkbox{
	//创建rb_instances对象
	if (!box_instances) {
		box_instances = [[NSMutableArray alloc] init];
	}
	//将radioButton添加到可变数组rb_instances中
	[box_instances addObject:checkbox];
}


//选中事件，主要设置选中的项，同时返回该分组中所有选中的按钮的索引数组
+(void)buttonSelected:(MACheckBox *)checkbox{
	//从box_observers字典中取得checkbox的对象observer，id用来定义未知类型的对象
	if (box_observers) {
		id observer = [box_observers objectForKey:checkbox.groupId];
		//respondsToSelector: 方法来确认某个实例是否有某个方法
		//调用协议中的checkBoxSelectedAtIndex方法，将当前点击按钮的索引、分组id、该分组中所有选中按钮的索引返回
		if (observer && [observer respondsToSelector:@selector(checkBoxSelectedAtIndex:curSeleckeds:)]) {
			[observer checkBoxSelectedAtIndex:checkbox
                                 curSeleckeds:[self getBoxesByGroupId:checkbox.groupId selected:YES]];
		}
	}
}

+(NSMutableArray*)getBoxesByGroupId:(NSString*)groupId selected:(BOOL)selected{
    NSMutableArray* tempmy = [[NSMutableArray alloc] init];
	//从静态数组中取出radioButton,并判断是否选中，选中则将该按钮的索引放入临时数组tempmy中
	if (box_instances) {
		for (int i=0; i<[box_instances count]; i++) {
			MACheckBox *button = [box_instances objectAtIndex:i];
			if([button.groupId isEqualToString:groupId]){
                if (selected) {
                    if ([button checkboxSelected:nil]) {
                        [tempmy addObject:button];
                    }
                } else{
                    [tempmy addObject:button];
                }
			}
		}
	}
    
    return tempmy;
}

+(MACheckBox*)findBoxByIndex:(NSUInteger)index{
    if (box_instances) {
		for (int i = 0; i < [box_instances count]; i++) {
			MACheckBox *button = [box_instances objectAtIndex:i];
			if(button.index == index){
                return button;
			}
		}
	}
    
    return nil;
}

//checkbox选中事件
-(void)handleButtonTap:(id)sender{
	if(_button.selected){
		[_button setSelected:NO];
	}else {
		[_button setSelected:YES];
	}
    
    [MACheckBox buttonSelected:self];
}

-(void)setButtonSelected:(BOOL)selected{
    [_button setSelected:selected];
    [_button setNeedsDisplay];
}

-(BOOL)checkboxSelected:(id)sender{
    // 如果button原来为选中状态，则设置为非选中状态
    return _button.selected;
}

//对象的生命周期，初始化radiobutton处理
-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index text:(NSString*)text{
	self = [self init];
    if (self) {
        _groupId = groupId;
        _index = index;
        _label.text = text;
    }
	return  self;
}

- (id)init{
    self = [super init];
    if (self) {
        [self defaultInit];
    }
    return self;
}

-(void)defaultInit{
    self.frame = CGRectMake(0, 0, kBoxWidth, kBoxHeight);
    
    // 定义 UIButton
    _button = [MAUtils buttonWithImg:nil
                                  off:0
                              zoomIn:NO
                                image:[UIImage imageNamed:@"checkbox_off.png"]
                             imagesec:[UIImage imageNamed:@"checkbox_on.png"]
                               target:self
                               action:@selector(handleButtonTap:)];
    [self addSubview:_button];
    
    //定义UILabel
    _label = [MAUtils labelWithTxt:nil
                              frame:CGRectMake(kBoxHeight + kBoxOff, 0, kBoxWidth - kBoxHeight - kBoxOff, kBoxHeight)
                               font:[[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize16]
                              color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:YES]];
    _label.textAlignment = KTextAlignmentLeft;
    [self addSubview:_label];
    
    //将按钮添加的实例数组中
    [MACheckBox registerInstance:self];
}

@end
