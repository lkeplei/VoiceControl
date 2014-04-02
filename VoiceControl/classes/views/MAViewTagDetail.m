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

#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

#define KContentViewHeight      (150)
#define KContentViewWidth       (290)
#define KContentViewOffset      (10)

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

@property (assign) CGFloat animationDuration;
@property (assign) CGFloat animationDelay;
@property (assign) UIViewAnimationOptions animationOptions;
@property (assign, readwrite) BOOL isVisible;

@property (assign) MATagObject* tagObject;

@end

@implementation MAViewTagDetail{
    UIView* _contentView;
    MABlurView *_blurView;
    tagDetailCompletion _completion;
}

-(id)initWithTagObject:(MATagObject*)object{
    self = [super initWithFrame:(CGRect){CGPointZero, SysDelegate.viewController.view.frame.size}];
    if (self) {
        // Initialization code
        _tagObject = object;
        
        [self initContentView];
        [self initDetail];
    }
    return self;
}

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
                                        action:@selector(hide)];
    hideBtn.center = _contentView.frame.origin;
    [self addSubview:hideBtn];
}

-(void)initDetail{
    //输入
    UITextField* textName = [MAUtils textFieldInit:CGRectMake(20, 110, KContentViewWidth - 40, 30)
                                            color:[UIColor blueColor]
                                          bgcolor:[UIColor grayColor]
                                             secu:NO
                                             font:[[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize14]
                                             text:nil];
    textName.delegate = self;
    textName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textName.text = _tagObject.tagName;
    textName.layer.borderColor = [UIColor lightGrayColor].CGColor; // set color as you want.
    textName.layer.borderWidth = 1.0;
    textName.layer.cornerRadius = 4.f;
    [_contentView addSubview:textName];
}

#pragma mark - text field
- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
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
@end
