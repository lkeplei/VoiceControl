//
//  MAAnimatedLabel.m
//  
//
//  Created by michael on 8/3/12.
//  Copyright (c) 2012 Michael Turner. All rights reserved.
//

#import "MAAnimatedLabel.h"
#import <objc/runtime.h>

#define kGradientSize       0.45f
#define kAnimationDuration  2.25f
#define kGradientTint       [UIColor whiteColor]

#define kAnimationKey       @"gradientAnimation"

@interface MAAnimatedLabel () {
    CATextLayer* _textLayer;
}
@end


@implementation MAAnimatedLabel
@synthesize animationDuration   = _animationDuration;
@synthesize gradientWidth       = _gradientWidth;
@synthesize tint                = _tint;

#pragma mark - Initialization

- (void)initializeLayers
{
    /* set Defaults */
    self.tint               = kGradientTint;
    self.animationDuration  = kAnimationDuration;
    self.gradientWidth      = kGradientSize;
    
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.backgroundColor   = [super.textColor CGColor];
    gradientLayer.startPoint        = CGPointMake(-self.gradientWidth, 0.);
    gradientLayer.endPoint          = CGPointMake(0., 0.);
    gradientLayer.colors            = [NSArray arrayWithObjects:(id)[self.textColor CGColor],(id)[self.tint CGColor], (id)[self.textColor CGColor], nil];

    _textLayer                      = [CATextLayer layer];
    _textLayer.backgroundColor      = [[UIColor clearColor] CGColor];
    _textLayer.contentsScale        = [[UIScreen mainScreen] scale];
    _textLayer.rasterizationScale   = [[UIScreen mainScreen] scale];
    _textLayer.bounds               = self.bounds;
    _textLayer.anchorPoint          = CGPointZero;
    
    /* set initial values for the textLayer because they may have been loaded from a nib */
    [self setFont:          super.font];
    [self setTextAlignment: super.textAlignment];
    [self setText:          super.text];
    [self setTextColor:     super.textColor];

    /*
        finally set the textLayer as the mask of the gradientLayer, this requires offscreen rendering
        and therefore this label subclass should ONLY BE USED if animation is required
     */
    gradientLayer.mask = _textLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeLayers];
    }
    return self;
}

#pragma mark - UILabel Accessor overrides

-(UIColor *)textColor
{
    return [UIColor colorWithCGColor:self.layer.backgroundColor];
}

-(void) setTextColor:(UIColor *)textColor
{
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.backgroundColor   = [textColor CGColor];
    gradientLayer.colors            = [NSArray arrayWithObjects:(id)[textColor CGColor],(id)[self.tint CGColor], (id)[textColor CGColor], nil];
    
    [self setNeedsDisplay];
}

-(NSString *)text
{
    return _textLayer.string;
}

- (void)setText:(NSString *)text
{
    _textLayer.string = text;
    [self setNeedsDisplay];
}

-(UIFont *)font
{
    CTFontRef ctFont    = _textLayer.font;
    NSString *fontName  = (__bridge NSString *)CTFontCopyName(ctFont, kCTFontPostScriptNameKey);
    CGFloat fontSize    = CTFontGetSize(ctFont);
    return [UIFont fontWithName:fontName size:fontSize];
}

-(void) setFont:(UIFont *)font
{
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize, &CGAffineTransformIdentity);
    _textLayer.font = fontRef;
    _textLayer.fontSize = font.pointSize;
    CFRelease(fontRef);
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame
{
    //_textLayer.frame = frame;
    [super setFrame:frame];
    [self setNeedsDisplay];
}


/*
 //Shadows don't work with a masked layer

-(UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:_textLayer.shadowColor];
}

-(void)setShadowColor:(UIColor *)shadowColor
{
    _textLayer.shadowColor = shadowColor.CGColor;
    [self setNeedsDisplay];
}

-(CGSize)shadowOffset
{
    return _textLayer.shadowOffset;
}

-(void)setShadowOffset:(CGSize)shadowOffset
{
    _textLayer.shadowOffset = shadowOffset;
    [self setNeedsDisplay];
}
*/
#ifdef __IPHONE_6_0
- (NSTextAlignment)textAlignment{
#else
- (UITextAlignment)textAlignment{
#endif
    return [MAAnimatedLabel UITextAlignmentFromCAAlignment:_textLayer.alignmentMode];
}

#ifdef __IPHONE_6_0
- (void)setTextAlignment:(NSTextAlignment)textAlignment{
#else
- (void)setTextAlignment:(UITextAlignment)textAlignment{
#endif
    _textLayer.alignmentMode = [MAAnimatedLabel CAAlignmentFromUITextAlignment:textAlignment];
}

#pragma mark - UILabel Layer override
+ (Class)layerClass{
    return [CAGradientLayer class];
}

/* Stop UILabel from drawing because we are using a CATextLayer for that! */
- (void)drawRect:(CGRect)rect {}

#pragma mark - Utility Methods
#ifdef __IPHONE_6_0
+ (NSString *)CAAlignmentFromUITextAlignment:(NSTextAlignment)textAlignment{
#else
+ (NSString *)CAAlignmentFromUITextAlignment:(UITextAlignment)textAlignment{
#endif
    switch (textAlignment) {
        case KTextAlignmentLeft:
            return kCAAlignmentLeft;
        case KTextAlignmentCenter:
            return kCAAlignmentCenter;
        case KTextAlignmentRight:
            return kCAAlignmentRight;
        default:
            return kCAAlignmentNatural;
    }
}

#ifdef __IPHONE_6_0
+ (NSTextAlignment)UITextAlignmentFromCAAlignment:(NSString *)alignment{
#else
+ (UITextAlignment)UITextAlignmentFromCAAlignment:(NSString *)alignment{
#endif
    if ([alignment isEqualToString:kCAAlignmentLeft])
        return KTextAlignmentLeft;
    if ([alignment isEqualToString:kCAAlignmentCenter])
        return KTextAlignmentCenter;
    if ([alignment isEqualToString:kCAAlignmentRight])
        return KTextAlignmentRight;
    if ([alignment isEqualToString:kCAAlignmentNatural])
        return KTextAlignmentLeft;
    return KTextAlignmentLeft;
}

#pragma mark - LayoutSublayers
- (void)layoutSublayersOfLayer:(CALayer *)layer{
    _textLayer.frame = self.layer.bounds;
}

#pragma mark - MTAnimated Label Public Methods
- (void)setTint:(UIColor *)tint{
    _tint = tint;
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.textColor CGColor],(id)[_tint CGColor], (id)[self.textColor CGColor], nil];
    [self setNeedsDisplay];
}

- (void)startAnimating{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    if([gradientLayer animationForKey:kAnimationKey] == nil) {
        CABasicAnimation *startPointAnimation = [CABasicAnimation animationWithKeyPath:@"startPoint"];
        startPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 0)];
        startPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *endPointAnimation = [CABasicAnimation animationWithKeyPath:@"endPoint"];
        endPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1+self.gradientWidth, 0)];
        endPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = [NSArray arrayWithObjects:startPointAnimation, endPointAnimation, nil];
        group.duration = self.animationDuration;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group.repeatCount = FLT_MAX;
        
        [gradientLayer addAnimation:group forKey:kAnimationKey];
    }
}

- (void)stopAnimating{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    if([gradientLayer animationForKey:kAnimationKey]) {
        [gradientLayer removeAnimationForKey:kAnimationKey];
    }
}

@end
