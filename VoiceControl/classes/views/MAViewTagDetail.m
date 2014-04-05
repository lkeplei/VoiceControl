//
//  MAViewTagDetail.m
//  VoiceControl
//
//  Created by apple on 14-4-1.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewTagDetail.h"
#import "MAViewController.h"
#import "MAUtils.h"
#import "MARecordController.h"
#import "MAConfig.h"
#import "MACoreDataManager.h"
#import "MAVoiceFiles.h"

#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

#define KContentViewHeight      (150)
#define KContentViewWidth       (290)
#define KContentViewOffset      (10)
#define KPercentOffset          (0.1)

CGFloat const KDefaultDelay = 0.125f;
CGFloat const KDefaultDuration = 0.2f;
CGFloat const KDefaultBlurScale = 0.075f;
NSString * const KShowNotification = @"tagDetailShow";
NSString * const KHideNotification = @"tagDetailHide";

typedef void (^tagDetailCompletion)(void);





#pragma mark - UIView + Screenshot
@implementation UIView (Screenshot)

- (UIImage*)screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // hack, helps w/ our colors when blurring
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end


#pragma mark - UIImage + Blur
@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}
@end



#pragma mark - RNBlurView
@interface MABlurView : UIImageView
- (id)initWithCoverView:(UIView*)view;
@end

@implementation MABlurView {
    UIView *_coverView;
}

- (id)initWithCoverView:(UIView *)view {
    if (self = [super initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)]) {
        _coverView = view;
        UIImage *blur = [_coverView screenshot];
        self.image = [blur boxblurImageWithBlur:KDefaultBlurScale];
    }
    return self;
}
@end









@interface MAViewTagDetail ()

@property (assign) int16_t currentIndex;
@property (assign) CGFloat animationDuration;
@property (assign) CGFloat animationDelay;
@property (assign) UIViewAnimationOptions animationOptions;
@property (assign) Float32 prePointX;
@property (assign, readwrite) BOOL isVisible;
@property (nonatomic, strong) UIImageView* tagPointView;
@property (nonatomic, strong) UIImageView* tagBtnView;
@property (nonatomic, strong) UILabel* tagLabel;
@property (nonatomic, strong) UITextField* tagNameTextField;
@property (nonatomic, strong) UIButton* startButton;
@property (nonatomic, strong) UIButton* endButton;
@property (nonatomic, strong) UILabel* averageLabel;

@property (nonatomic, copy) NSArray* tagObjectArray;

@end

@implementation MAViewTagDetail{
    UIView* _contentView;
    MABlurView *_blurView;
    tagDetailCompletion _completion;
}

-(id)initWithTagObject:(NSArray*)tagArray index:(int16_t)index{
    self = [super initWithFrame:(CGRect){CGPointZero, SysDelegate.viewController.view.frame.size}];
    if (self) {
        // Initialization code
        _tagObjectArray = [tagArray copy];
        _currentIndex = index;
        
        [self initContentView];
        [self setDetailWithObject:[self getCurrentTagObject]];
    }
    return self;
}

#pragma mark - text field
- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_tagNameTextField isExclusiveTouch]) {
        [_tagNameTextField resignFirstResponder];
    }
}

#pragma mark - hide view
- (void)hide {
    [self hideWithDuration:KDefaultDuration delay:0 options:kNilOptions completion:NULL];
}

- (void)hideWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    if (self.isVisible) {
        [UIView animateWithDuration:duration
                              delay:delay
                            options:options
                         animations:^{
                             self.alpha = 0.f;
                             _blurView.alpha = 0.f;
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [_blurView removeFromSuperview];
                                 _blurView = nil;
                                 [self removeFromSuperview];
                                 
                                 [[NSNotificationCenter defaultCenter] postNotificationName:KHideNotification object:nil];
                                 self.isVisible = NO;
                                 if (completion) {
                                     completion();
                                 }
                             }
                         }];
    }
}

#pragma mark - show view
- (void)show {
    [self showWithDuration:KDefaultDuration delay:0 options:kNilOptions completion:NULL];
}

- (void)showWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    self.animationDuration = duration;
    self.animationDelay = delay;
    self.animationOptions = options;
    _completion = [completion copy];
    
    // delay so we dont get button states
    [self performSelector:@selector(delayedShow) withObject:nil afterDelay:KDefaultDelay];
}

- (void)delayedShow {
    if (!self.isVisible) {
        if (!self.superview) {
            [SysDelegate.viewController.view addSubview:self];
        }
        
        _blurView = [[MABlurView alloc] initWithCoverView:SysDelegate.viewController.view];
        _blurView.alpha = 0.f;
        [SysDelegate.viewController.view insertSubview:_blurView belowSubview:self];
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
        [UIView animateWithDuration:self.animationDuration animations:^{
            _blurView.alpha = 1.f;
            self.alpha = 1.f;
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f);
        } completion:^(BOOL finished) {
            if (finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KShowNotification object:nil];
                self.isVisible = YES;
                if (_completion) {
                    _completion();
                }
            }
        }];
    }
}

#pragma mark - init view
-(void)initContentView{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KContentViewWidth, KContentViewHeight)];
    _contentView.center = SysDelegate.viewController.view.center;
    [_contentView setBackgroundColor:[UIColor grayColor]];
    _contentView.clipsToBounds = YES;
    _contentView.layer.masksToBounds = YES;
    [self addSubview:_contentView];
    
    //add border and corner radius
    UIColor* whiteColor = [UIColor colorWithRed:0.816 green:0.788 blue:0.788 alpha:1.000];
    _contentView.layer.borderColor = whiteColor.CGColor;
    _contentView.layer.borderWidth = 2.f;       //设置边沿宽度
    _contentView.layer.cornerRadius = 6.f;      //设置圆角
    
    //add hide button
    UIButton* hideBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                         image:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                      imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                        target:self
                                        action:@selector(hideBtnClicked:)];
    hideBtn.center = _contentView.frame.origin;
    [self addSubview:hideBtn];
    
    //add pan gesture
    UIPanGestureRecognizer* panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [_contentView addGestureRecognizer:panGesture];

    //输入
    _tagNameTextField = [MAUtils textFieldInit:CGRectMake(20, 10, KContentViewWidth - 40, 30)
                                         color:[UIColor blueColor]
                                       bgcolor:[UIColor grayColor]
                                          secu:NO
                                          font:[[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize14]
                                          text:nil];
    _tagNameTextField.delegate = self;
    _tagNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tagNameTextField.textAlignment = KTextAlignmentCenter;
    _tagNameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor; // set color as you want.
    _tagNameTextField.layer.borderWidth = 1.0;
    _tagNameTextField.layer.cornerRadius = 4.f;
    [_contentView addSubview:_tagNameTextField];
    
    //progress
    UIImageView* imgBack = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberRight default:NO]];
    imgBack.frame = CGRectMake(0, CGRectGetMaxY(_tagNameTextField.frame) + KContentViewOffset * 3, _contentView.frame.size.width, 10);
    [_contentView addSubview:imgBack];
    
    //pre next btn
    UIButton* preBtn = [MAUtils buttonWithImg:@"pre" off:0 zoomIn:NO
                                        image:nil
                                     imagesec:nil
                                       target:self action:@selector(preBtnClicked:)];
    preBtn.frame = CGRectMake(KContentViewOffset, 110, 130, 30);
    preBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    preBtn.layer.borderWidth = 1.0;
    preBtn.layer.cornerRadius = 4.f;
    [_contentView addSubview:preBtn];
    
    UIButton* nextBtn = [MAUtils buttonWithImg:@"next" off:0 zoomIn:NO
                                         image:nil
                                      imagesec:nil
                                        target:self action:@selector(nextBtnClicked:)];
    nextBtn.frame = CGRectMake(CGRectGetMaxX(preBtn.frame) + KContentViewOffset, 110, 130, 30);
    nextBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nextBtn.layer.borderWidth = 1.0;
    nextBtn.layer.cornerRadius = 4.f;
    [_contentView addSubview:nextBtn];
}

-(void)setDetailWithObject:(MATagObject*)object{
    //输入
    if (_tagNameTextField) {
        _tagNameTextField.text = [self getCurrentTagObject].tagName;
    }
    
    [self setTagPointX:[self getX:MATagDetailStartX pointX:0]];
    
    //tag btn
    if (_startButton) {
        _startButton.center = CGPointMake([self getX:MATagDetailStartX pointX:0], CGRectGetMaxY(_tagPointView.frame) + KContentViewOffset);
    } else {
        _startButton = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                        image:[UIImage imageNamed:@"slider_tag.png"]
                                     imagesec:[UIImage imageNamed:@"slider_tag.png"]
                                       target:self action:@selector(startBtnClicked:)];
        _startButton.center = CGPointMake([self getX:MATagDetailStartX pointX:0], CGRectGetMaxY(_tagPointView.frame) + KContentViewOffset);
        [_contentView addSubview:_startButton];
    }
    
    if (_endButton) {
        _endButton.center = CGPointMake([self getX:MATagDetailEndX pointX:0], CGRectGetMaxY(_tagPointView.frame) + KContentViewOffset);
    } else {
        _endButton = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                      image:[UIImage imageNamed:@"slider_tag.png"]
                                   imagesec:[UIImage imageNamed:@"slider_tag.png"]
                                     target:self action:@selector(endBtnClicked:)];
        _endButton.center = CGPointMake([self getX:MATagDetailEndX pointX:0], CGRectGetMaxY(_tagPointView.frame) + KContentViewOffset);
        [_contentView addSubview:_endButton];
    }
    
    //average
    if (_averageLabel) {
        _averageLabel.text = [NSString stringWithFormat:@"%@DB-(%d/%d)",
                              [MAUtils getStringByFloat:[self getCurrentTagObject].averageVoice decimal:1],
                              _currentIndex + 1, [_tagObjectArray count]];
    } else {
        _averageLabel = [MAUtils labelWithTxt:[NSString stringWithFormat:@"%@DB-(%d/%d)",
                                               [MAUtils getStringByFloat:[self getCurrentTagObject].averageVoice decimal:1],
                                               _currentIndex + 1, [_tagObjectArray count]]
                                        frame:CGRectMake(0, CGRectGetMaxY(_tagPointView.frame) + KContentViewOffset,
                                                         _contentView.frame.size.width, 20)
                                         font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                        color:[[MAModel shareModel] getColorByType:MATypeColorDefBlue default:NO]];
        [_contentView addSubview:_averageLabel];
    }
}

-(void)setTagPointX:(float)pointX{
    if (!_tagPointView) {
        _tagPointView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberLeft default:NO]];
        _tagPointView.frame = CGRectMake(0, CGRectGetMaxY(_tagNameTextField.frame) + KContentViewOffset * 3, pointX, 10);
        [_contentView addSubview:_tagPointView];
    } else {
        _tagPointView.frame = CGRectMake(0, _tagPointView.frame.origin.y, pointX, 10);
    }
    
    if (!_tagBtnView) {
        _prePointX = pointX;
        
        _tagBtnView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberKnob default:NO]];
        _tagBtnView.frame = CGRectOffset(_tagBtnView.frame, pointX, CGRectGetMaxY(_tagNameTextField.frame) + KContentViewOffset * 3);
        [_contentView addSubview:_tagBtnView];
    } else {
        [self getCurrentTagObject].pointX = [self getX:MATagDetailTimeX pointX:pointX];
        
        _tagBtnView.center = CGPointMake(pointX, _tagBtnView.center.y);
    }
    
    if (!_tagLabel) {
        _tagLabel = [MAUtils labelWithTxt:[MAUtils getStringByFloat:[self getX:MATagDetailTimeX pointX:pointX] decimal:1]
                                        frame:CGRectMake(pointX, CGRectGetMaxY(_tagNameTextField.frame) + KContentViewOffset, 40, 20)
                                         font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                        color:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];;
        _tagLabel.textAlignment = KTextAlignmentLeft;
        [_contentView addSubview:_tagLabel];
    } else {
        _tagLabel.text = [MAUtils getStringByFloat:[self getCurrentTagObject].pointX decimal:1];
        _tagLabel.center = CGPointMake(pointX, _tagLabel.center.y);
    }
}

#pragma mark - pan gesture
-(void)handlePanGesture:(UIPanGestureRecognizer*)sender{
    //得到拖的过程中的xy坐标
    CGPoint translation=[sender translationInView:_contentView];
    DebugLog(@"handleSwipeGesture point = (%f, %f)", translation.x, translation.y);
    //平移图片CGAffineTransformMakeTranslation
    [self setTagPointX:_prePointX + translation.x];
    
    //状态结束，保存数据
    if(sender.state==UIGestureRecognizerStateEnded){
        _prePointX += translation.x;
    }
}

#pragma mark - btn clicked
-(void)preBtnClicked:(id)sender{
    if (_currentIndex > 0) {
        [self saveCurrentTagObject];
        _currentIndex--;
        [self setDetailWithObject:[self getCurrentTagObject]];
    }
}

-(void)nextBtnClicked:(id)sender{
    if (_currentIndex < [_tagObjectArray count] - 1) {
        [self saveCurrentTagObject];
        _currentIndex++;
        [self setDetailWithObject:[self getCurrentTagObject]];
    }
}

-(void)hideBtnClicked:(id)sender{
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobEventEnd eventName:KTagDetail label:nil];

    if (self.tagDetailBlock) {
        [self saveCurrentTagObject];
        self.tagDetailBlock([self getCurrentTagObject]);
    }
    
    [self hide];
}

-(void)startBtnClicked:(id)sender{
    _prePointX = [self getX:MATagDetailStartX pointX:0];
    [self setTagPointX:_prePointX];
}

-(void)endBtnClicked:(id)sender{
    _prePointX = [self getX:MATagDetailEndX pointX:0];
    [self setTagPointX:_prePointX];
}

#pragma mark - other
-(void)saveCurrentTagObject{
    MATagObject* object = [self getCurrentTagObject];
    object.tagName = _tagNameTextField.text;
    
    NSArray* array = [[MACoreDataManager sharedCoreDataManager] getMAVoiceFile:object.name];
    if (array && [array count] > 0) {
        MAVoiceFiles* file = [array objectAtIndex:0];
        
        NSMutableString* mark = nil;
        for (int i = 0; i < [_tagObjectArray count]; i++) {
            if (i == 0) {
                mark = [[NSMutableString alloc] init];
                [mark appendFormat:@"%.1f-%.1f-%.1f-%@", object.startTime, object.endTime, object.averageVoice, object.tagName];
            } else {
                [mark appendFormat:@";%.1f-%.1f-%.1f-%@", object.startTime, object.endTime,object.averageVoice, object.tagName];
            }
        }
        file.tag = mark;
        
        [[MACoreDataManager sharedCoreDataManager] saveEntry];
    }
}

-(MATagObject*)getCurrentTagObject{
    if (_tagObjectArray && [_tagObjectArray count] > _currentIndex && _currentIndex >= 0) {
        return [_tagObjectArray objectAtIndex:_currentIndex];
    }
    return nil;
}

-(Float32)getX:(MATagDetailType)type pointX:(Float32)pointX{
    MATagObject* object = [self getCurrentTagObject];
    Float32 offset = (object.endTime - object.startTime) * KPercentOffset;
    Float32 start = object.startTime > offset ? object.startTime - offset : 0;
    Float32 end = object.endTime + offset < object.totalTime ? object.endTime + offset : object.totalTime;
    
    switch (type) {
        case MATagDetailStartX:
            return ((object.startTime - start) / (end - start)) * _contentView.frame.size.width;
            break;
        case MATagDetailEndX:
            return ((object.endTime - start) / (end - start)) * _contentView.frame.size.width;
            break;
        case MATagDetailTimeX:
            return (pointX / _contentView.frame.size.width) * (end - start);
            break;
        default:
            break;
    }
}
@end
