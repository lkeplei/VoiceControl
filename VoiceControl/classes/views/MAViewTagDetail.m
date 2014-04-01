//
//  MAViewTagDetail.m
//  VoiceControl
//
//  Created by apple on 14-4-1.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewTagDetail.h"
#import "MAViewController.h"
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>


CGFloat const KDefaultDelay = 0.125f;
CGFloat const KDefaultDuration = 0.2f;
CGFloat const KDefaultBlurScale = 0.2f;
NSString * const KShowNotification = @"tagDetailShow";

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
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        [_contentView setBackgroundColor:[UIColor grayColor]];
        [self addSubview:_contentView];
        _contentView.clipsToBounds = YES;
        _contentView.layer.masksToBounds = YES;
        
        _tagObject = object;
    }
    return self;
}

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
//            self.top = 0;
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
