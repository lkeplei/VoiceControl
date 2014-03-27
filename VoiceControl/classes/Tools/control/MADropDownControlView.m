//
//  MADropDownControlView.m
//  VoiceControl
//
//  Created by ken on 13-4-15.
//  Copyright (c) 2013年 ken. All rights reserved.
//


#import "MADropDownControlView.h"
#import "MAModel.h"
#import "MAViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kOptionHeight 20
#define kOptionSpacing 1
#define kAnimationDuration 0.2

#define KRectInsetOff       (8)

@interface MADropDownControlView (){
    CGRect mBaseFrame;
    
    // Configuration
    NSArray* mSelectionOptions;
    
    // Subviews
    UILabel* mTitleLabel;
    UILabel* mSelectedLabel;
    UIImage* mBgImage;
    NSMutableArray* mSelectionCells;
    
    // Control state
    NSInteger mSelectionIndex;
    NSInteger mPreviousSelectionIndex;
}
@end

@implementation MADropDownControlView

#pragma mark - Object Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mBaseFrame = frame;
        
        // Background
        mBgImage = [[UIImage imageNamed:@"dropdown_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        UIImageView *backGroundView = [[UIImageView alloc] initWithImage:mBgImage];
        backGroundView.frame = self.bounds;
        [backGroundView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDropBG default:NO]];
        [self addSubview:backGroundView];
        
        // Title
        mTitleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 0)];
        mTitleLabel.textAlignment = NSTextAlignmentLeft;
        mTitleLabel.textColor = [[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO];
        mTitleLabel.backgroundColor = [[MAModel shareModel] getColorByType:MATypeColorDefault default:NO];
        mTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:mTitleLabel];
        
        // selected
        mSelectedLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 0)];
        mSelectedLabel.textAlignment = NSTextAlignmentRight;
        mSelectedLabel.textColor = [[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO];
        mSelectedLabel.backgroundColor = [[MAModel shareModel] getColorByType:MATypeColorDefault default:NO];
        mSelectedLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:mSelectedLabel];
    }
    return self;
}

#pragma mark - Accessors
- (void)setTitle:(NSString *)title {
    mTitleLabel.text = title;
}

-(void)setSelectedContent:(NSString *)selectedContent{
    if (selectedContent) {
        mSelectedLabel.text = selectedContent;
    } else {
        mSelectedLabel.text = @"-";
    }
}

-(id)selectedContent{
    if (mSelectionOptions && mSelectionIndex >= 0 && [mSelectionOptions count] > mSelectionIndex) {
        return [mSelectionOptions objectAtIndex:mSelectionIndex];
    } else {
        return nil;
    }
}

#pragma mark - Configuration
- (void)setSelectionOptions:(NSArray *)selectionOptions {
    if (selectionOptions) {
        mSelectionOptions = selectionOptions;
        mSelectionCells = nil;
    }
}

#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1)
        return;
    
    UITouch* touch = [touches anyObject];
    if (_controlIsActive) {
        CGPoint location = [touch locationInView:self];
        if ((CGRectContainsPoint(self.bounds, location)) && (location.y > mBaseFrame.size.height)) {
            mSelectionIndex = (location.y - mBaseFrame.size.height - kOptionSpacing) / (kOptionHeight + kOptionSpacing);
            mPreviousSelectionIndex = mSelectionIndex;  
            
            UIView *cell = [mSelectionCells objectAtIndex:mSelectionIndex];
            [UIView animateWithDuration:kAnimationDuration animations:^{
                cell.frame = CGRectInset(cell.frame, -KRectInsetOff, 0);
            }];
        } else {
            mSelectionIndex = NSNotFound;
        }
    }        
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1)
        return;
    
    UITouch *touch = [touches anyObject];
    
    // Calculate the selection index
    CGPoint location = [touch locationInView:self];
    if ((CGRectContainsPoint(self.bounds, location)) && (location.y > mBaseFrame.size.height)) {
        mSelectionIndex = (location.y - mBaseFrame.size.height - kOptionSpacing) / (kOptionHeight + kOptionSpacing);
    } else {
        mSelectionIndex = NSNotFound;
    }
    
    if (mSelectionIndex == mPreviousSelectionIndex)
        return;
    
    // Selection animation
    if (mSelectionIndex != NSNotFound) {
        UIView *cell = [mSelectionCells objectAtIndex:mSelectionIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            cell.frame = CGRectInset(cell.frame, -KRectInsetOff, 0);
        }];
    }
    if (mPreviousSelectionIndex != NSNotFound) {
        UIView *cell = [mSelectionCells objectAtIndex:mPreviousSelectionIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            cell.frame = CGRectInset(cell.frame, KRectInsetOff, 0);
        }];
    }
    mPreviousSelectionIndex = mSelectionIndex;        
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1)
        return;

    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        if (_controlIsActive) {
            [self inactivateControl];
            
            if (mSelectionIndex < [mSelectionOptions count]) {
                [self.delegate dropDownControlView:self didFinishWithSelection:[NSNumber numberWithInt:(int)mSelectionIndex]];
            } else {
                [self.delegate dropDownControlView:self didFinishWithSelection:nil];
            }
        } else {
            [self activateControl];
        }
    } else {
        [self inactivateControl];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_controlIsActive) {
        [self inactivateControl];
    }
}

#pragma mark - View Transformation
- (CATransform3D)contractedTransorm {
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DRotate(t, M_PI / 2, 1, 0, 0);
    t.m34 = -1.0/50;
    return t;
}

#pragma mark - Control Activation / Deactivation
- (void)activateControl {
    if (_controlIsActive) {
        return;
    }
    _controlIsActive = YES;
    
    mSelectionIndex = NSNotFound;
    mPreviousSelectionIndex = NSNotFound;
    
    if ([self.delegate respondsToSelector:@selector(dropDownControlViewWillBecomeActive:)]) {
        [self.delegate dropDownControlViewWillBecomeActive:self];
    }
    
    // Prepare the selection cells
    if (mSelectionCells == nil) {
        mSelectionCells = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [mSelectionOptions count]; i++) {
            UIImageView *newCell = [[UIImageView alloc] initWithImage:mBgImage];
            newCell.frame = CGRectMake(0, mBaseFrame.size.height + (i * kOptionHeight + kOptionSpacing) + kOptionSpacing, mBaseFrame.size.width, kOptionHeight);
            newCell.layer.anchorPoint = CGPointMake(0.5, 0.0);
            newCell.layer.transform = [self contractedTransorm];
            [newCell setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDropCellBG default:NO]];
            //newCell.alpha = 0;
            
            UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectInset(newCell.bounds, 10, 0)];
            newLabel.font = [UIFont systemFontOfSize:14];
            newLabel.backgroundColor = [[MAModel shareModel] getColorByType:MATypeColorDefault default:NO];
            newLabel.textColor = [[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO];
            newLabel.text = [mSelectionOptions objectAtIndex:i];
            [newCell addSubview:newLabel];
            
            [self addSubview:newCell];
            [mSelectionCells addObject:newCell];
        }
    }
    
    // Expand our frame
    CGRect newFrame = mBaseFrame;
    newFrame.size.height += [mSelectionOptions count] * (kOptionHeight + kOptionSpacing);
    self.frame = newFrame;

    // Show selection cells animated
    int count = (int)[mSelectionCells count];
    for (int i = 0; i < count; i++) {
        UIView *cell = [mSelectionCells objectAtIndex:i];
        cell.alpha = 1.0;
        [UIView animateWithDuration:kAnimationDuration delay:(i * kAnimationDuration / count) options:0 animations:^{
            CGRect destinationFrame = CGRectMake(0, mBaseFrame.size.height + i * (kOptionHeight + kOptionSpacing) + kOptionSpacing, mBaseFrame.size.width, kOptionHeight);
            cell.frame = destinationFrame;
            cell.layer.transform = CATransform3DIdentity;
        } completion:nil];
    }
}

- (void)inactivateControl {
    if (!_controlIsActive) {
        return;
    }
    _controlIsActive = NO;
    
    if ([self.delegate respondsToSelector:@selector(dropDownControlViewWillBecomeInactive:)]) {
        [self.delegate dropDownControlViewWillBecomeInactive:self];
    }
    
    int count = (int)[mSelectionCells count];
    for (int i = count - 1; i >= 0; i--) {
        UIView *cell = [mSelectionCells objectAtIndex:i];
        [UIView animateWithDuration:kAnimationDuration delay:((count - 1 - i) * kAnimationDuration / count) options:0 animations:^{
            cell.frame = CGRectMake(0, mBaseFrame.size.height + (i * kOptionHeight + kOptionSpacing) + kOptionSpacing, mBaseFrame.size.width, mBaseFrame.size.height);
            cell.layer.transform = [self contractedTransorm];
        } completion:^(BOOL completed){
            cell.alpha = 0;
            if (i == 0) {
                self.frame = mBaseFrame;
            }
    }];
    }
}

@end
