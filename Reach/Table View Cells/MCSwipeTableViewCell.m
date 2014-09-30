//
//  MCSwipeTableViewCell.m
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

static CGFloat const kMCStop1 = 0.20; // Percentage limit to trigger the first action
static CGFloat const kMCStop2 = 0.52; // Percentage limit to trigger the second action
static CGFloat const kMCBounceAmplitude = 20.0; // Maximum bounce amplitude when using the MCSwipeTableViewCellModeSwitch mode
static NSTimeInterval const kMCBounceDuration1 = 0.2; // Duration of the first part of the bounce animation
static NSTimeInterval const kMCBounceDuration2 = 0.1; // Duration of the second part of the bounce animation
static NSTimeInterval const kMCDurationLowLimit = 0.25; // Lowest duration when swipping the cell because we try to simulate velocity
static NSTimeInterval const kMCDurationHightLimit = 0.1; // Highest duration when swipping the cell because we try to simulate velocity

@interface MCSwipeTableViewCell () <UIGestureRecognizerDelegate>

// Init
- (void)initializer;

// Handle Gestures
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture;

// Utils
- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width;

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width;

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity;

- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage;

- (NSString *)imageNameWithPercentage:(CGFloat)percentage;

- (UIColor *)colorWithPercentage:(CGFloat)percentage;

- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage;

- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage;

- (BOOL)validateState:(MCSwipeTableViewCellState)state;

// Movement
- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging;

- (void)animateWithOffset:(CGFloat)offset;

- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction;

- (void)bounceToOrigin;

// Delegate
- (void)notifyDelegate;

@property(nonatomic, assign) MCSwipeTableViewCellDirection direction;
@property(nonatomic, assign) CGFloat currentPercentage;

@property(nonatomic, strong) UIImageView *slidingImageView;
@property(nonatomic, strong) NSString *currentImageName;
@property(nonatomic, strong) UIView *colorIndicatorView;

@end

@implementation MCSwipeTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self initializer];
    }
    return self;
}

- (id)init {
    self = [super init];

    if (self) {
        [self initializer];
    }

    return self;
}

#pragma mark Custom Initializer

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
 firstStateIconName:(NSString *)firstIconName
         firstColor:(UIColor *)firstColor
secondStateIconName:(NSString *)secondIconName
        secondColor:(UIColor *)secondColor
      thirdIconName:(NSString *)thirdIconName
         thirdColor:(UIColor *)thirdColor
     fourthIconName:(NSString *)fourthIconName
        fourthColor:(UIColor *)fourthColor {
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self setFirstStateIconName:firstIconName
                         firstColor:firstColor
                secondStateIconName:secondIconName
                        secondColor:secondColor
                      thirdIconName:thirdIconName
                         thirdColor:thirdColor
                     fourthIconName:fourthIconName
                        fourthColor:fourthColor];
    }

    return self;
}

- (void)initializer {
    _mode = MCSwipeTableViewCellModeSwitch;
    _state = MCSwipeTableViewCellStateNone;

    _colorIndicatorView = [[UIView alloc] initWithFrame:self.bounds];
    [_colorIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_colorIndicatorView setBackgroundColor:COLOR_TABLE_CELL];
    [self insertSubview:_colorIndicatorView belowSubview:self.contentView];

    _slidingImageView = [[UIImageView alloc] init];
    [_slidingImageView setContentMode:UIViewContentModeCenter];
    [_colorIndicatorView addSubview:_slidingImageView];
    
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCellHeightDefault, kCellHeightDefault)];
    _iconImageView.clipsToBounds = YES;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_iconImageView];
    
    _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconImageView.frame) + 9, 2, CGRectGetWidth(self.frame) - CGRectGetMaxX(_iconImageView.frame) - 16, 44)];
    _mainLabel.textColor = [UIColor colorWithWhite:0.02f alpha:1.0f];
    _mainLabel.font = [UIFont fontWithName:kFontName size:19.0f];
    _mainLabel.backgroundColor = COLOR_TABLE_CELL;
    [self.contentView addSubview:_mainLabel];
    
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(-370, 8, 320, 38)];
    _phoneLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    _phoneLabel.font = [UIFont fontWithName:kBoldFontName size:14.0f];
    _phoneLabel.backgroundColor = [UIColor clearColor];
    _phoneLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_phoneLabel];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:self];
    
    [self sendSubviewToBack:_colorIndicatorView];
    
    self.backgroundColor = COLOR_TABLE_CELL;
}

#pragma mark - Handle Gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    UIGestureRecognizerState state = [gesture state];
    CGPoint translation = [gesture translationInView:self];
    CGPoint velocity = [gesture velocityInView:self];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.contentView.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
    NSTimeInterval animationDuration = [self animationDurationWithVelocity:velocity];
    _direction = [self directionWithPercentage:percentage];

    if (state == UIGestureRecognizerStateBegan) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(swipeTableViewCellDidStartSwiping:)]) {
            [_delegate swipeTableViewCellDidStartSwiping:self];
        }
    }
    else if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        CGPoint center = {self.contentView.center.x + translation.x, self.contentView.center.y};
        [self.contentView setCenter:center];
        [self animateWithOffset:CGRectGetMinX(self.contentView.frame)];
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(swipeTableViewCellDidEndSwiping:)]) {
            [_delegate swipeTableViewCellDidEndSwiping:self];
        }
        
        _currentImageName = [self imageNameWithPercentage:percentage];
        _currentPercentage = percentage;
        
        _state = [self stateWithPercentage:percentage];

        if (_mode == MCSwipeTableViewCellModeExit && _direction != MCSwipeTableViewCellDirectionCenter && [self validateState:_state])
            [self moveWithDuration:animationDuration andDirection:_direction];
        else
            [self bounceToOrigin];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGestureRecognizer) {
        UIScrollView *superview = (UIScrollView *) self.superview;
        CGPoint translation = [(UIPanGestureRecognizer *) gestureRecognizer translationInView:superview];

        // Make sure it is scrolling horizontally
        return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO && (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
    }
    return NO;
}

#pragma mark - Utils

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width {
    CGFloat offset = percentage * width;

    if (offset < -width) offset = -width;
    else if (offset > width) offset = 1.0;

    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;

    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;

    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff = kMCDurationHightLimit - kMCDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;

    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;

    return (kMCDurationHightLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}

- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage {
    if (percentage < -kMCStop1)
        return MCSwipeTableViewCellDirectionLeft;
    else if (percentage > kMCStop1)
        return MCSwipeTableViewCellDirectionRight;
    else
        return MCSwipeTableViewCellDirectionCenter;
}

- (NSString *)imageNameWithPercentage:(CGFloat)percentage {
    NSString *imageName;

    // Image
    if (percentage >= 0 && percentage < kMCStop2)
        imageName = _firstIconName;
    else if (percentage >= kMCStop2)
        imageName = _secondIconName;
    else if (percentage < 0 && percentage > -kMCStop2)
        imageName = _thirdIconName;
    else if (percentage <= -kMCStop2)
        imageName = _fourthIconName;

    return imageName;
}

- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage {
    CGFloat alpha;

    if (percentage >= 0 && percentage < kMCStop1)
        alpha = percentage / kMCStop1;
    else if (percentage < 0 && percentage > -kMCStop1)
        alpha = fabsf(percentage / kMCStop1);
    else alpha = 1.0;

    return alpha;
}

- (UIColor *)colorWithPercentage:(CGFloat)percentage {
    UIColor *color;

    // Background Color
    if (percentage >= kMCStop1 && percentage < kMCStop2)
        color = _firstColor;
    else if (percentage >= kMCStop2)
        color = _secondColor;
    else if (percentage < -kMCStop1 && percentage > -kMCStop2)
        color = _thirdColor;
    else if (percentage <= -kMCStop2)
        color = _fourthColor;
    else
        color = COLOR_TABLE_CELL;

    return color;
}

- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage {
    MCSwipeTableViewCellState state = MCSwipeTableViewCellStateNone;

    if (percentage >= kMCStop1 && [self validateState:MCSwipeTableViewCellState1])
        state = MCSwipeTableViewCellState1;

    if (percentage >= kMCStop2 && [self validateState:MCSwipeTableViewCellState2])
        state = MCSwipeTableViewCellState2;

    if (percentage <= -kMCStop1 && [self validateState:MCSwipeTableViewCellState3])
        state = MCSwipeTableViewCellState3;

    if (percentage <= -kMCStop2 && [self validateState:MCSwipeTableViewCellState4])
        state = MCSwipeTableViewCellState4;

    return state;
}

- (BOOL)validateState:(MCSwipeTableViewCellState)state {
    BOOL isValid = YES;

    switch (state) {
        case MCSwipeTableViewCellStateNone: {
            isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState1: {
            if (!_firstColor && !_firstIconName)
                isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState2: {
            if (!_secondColor && !_secondIconName)
                isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState3: {
            if (!_thirdColor && !_thirdIconName)
                isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState4: {
            if (!_fourthColor && !_fourthIconName)
                isValid = NO;
        }
            break;

        default:
            break;
    }

    return isValid;
}

#pragma mark - Movement

- (void)animateWithOffset:(CGFloat)offset {
    CGFloat percentage = [self percentageWithOffset:offset relativeToWidth:CGRectGetWidth(self.bounds)];

    // State & Color
    MCSwipeTableViewCellState newState = [self stateWithPercentage:percentage];
    if (_state != newState) {
        _state =  newState;
        if (_delegate != nil && [_delegate respondsToSelector:@selector(swipeTableViewCell:didChangeState:withMode:)]) {
            [_delegate swipeTableViewCell:self didChangeState:[self stateWithPercentage:percentage] withMode:_mode];
        }
        
        // Color with animation
        [UIView animateWithDuration:0.2 animations:^{
            UIColor *color = [self colorWithPercentage:percentage];
            if (color != nil) {
                [_colorIndicatorView setBackgroundColor:color];
            }
        }];
    } else {
        // Color withoutanimation
        UIColor *color = [self colorWithPercentage:percentage];
        if (color != nil) {
            [_colorIndicatorView setBackgroundColor:color];
        }
    }
    
    
    // Image Name
    NSString *imageName = [self imageNameWithPercentage:percentage];

    // Image Position
    if (imageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:imageName]];
        [_slidingImageView setAlpha:[self imageAlphaWithPercentage:percentage]];
    }
    [self slideImageWithPercentage:percentage imageName:imageName isDragging:YES];
    
    //self.backgroundColor = color;
}


- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging {
    UIImage *slidingImage = [UIImage imageNamed:imageName];
    CGSize slidingImageSize = slidingImage.size;
    CGRect slidingImageRect;

    CGPoint position = CGPointZero;

    position.y = CGRectGetHeight(self.bounds) / 2.0;

    if (isDragging) {
        if (percentage >= 0 && percentage < kMCStop1) {
            position.x = [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }

        else if (percentage >= kMCStop1) {
            position.x = [self offsetWithPercentage:percentage - (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else if (percentage < 0 && percentage >= -kMCStop1) {
            position.x = CGRectGetWidth(self.bounds) - [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }

        else if (percentage < -kMCStop1) {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
    }
    else {
        if (_direction == MCSwipeTableViewCellDirectionRight) {
            position.x = [self offsetWithPercentage:percentage - (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else if (_direction == MCSwipeTableViewCellDirectionLeft) {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else {
            return;
        }
    }
    
    slidingImageRect = CGRectMake(position.x - slidingImageSize.width / 2.0,
            position.y - slidingImageSize.height / 2.0,
            slidingImageSize.width,
            slidingImageSize.height);

    slidingImageRect = CGRectIntegral(slidingImageRect);
    [_slidingImageView setFrame:slidingImageRect];
    
    CGRect phoneFrame = _phoneLabel.frame;
    if (_direction == MCSwipeTableViewCellDirectionLeft) {
        _phoneLabel.textAlignment = NSTextAlignmentLeft;
        phoneFrame.origin.x = CGRectGetWidth(self.frame) + 50 - percentage;
    } else {
        _phoneLabel.textAlignment = NSTextAlignmentRight;
        phoneFrame.origin.x = -370.0 + percentage;
    }
    phoneFrame.origin.y = 0;
    phoneFrame.size.height = CGRectGetHeight(self.frame);
    [_phoneLabel setFrame:phoneFrame];
    
}


- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction {
    CGFloat origin;

    if (direction == MCSwipeTableViewCellDirectionLeft)
        origin = -CGRectGetWidth(self.bounds);
    else
        origin = CGRectGetWidth(self.bounds);

    CGFloat percentage = [self percentageWithOffset:origin relativeToWidth:CGRectGetWidth(self.bounds)];
    CGRect rect = self.contentView.frame;
    rect.origin.x = origin;

    // Color
    UIColor *color = [self colorWithPercentage:_currentPercentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }

    // Image
    if (_currentImageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:_currentImageName]];
    }

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.contentView setFrame:rect];
                         [_slidingImageView setAlpha:0];
                         [self slideImageWithPercentage:percentage imageName:_currentImageName isDragging:NO];
                     }
                     completion:^(BOOL finished) {
                         [self notifyDelegate];
                     }];
}

- (void)bounceToOrigin {
    CGFloat bounceDistance = kMCBounceAmplitude * _currentPercentage;

    [UIView animateWithDuration:kMCBounceDuration1
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         CGRect frame = self.contentView.frame;
                         frame.origin.x = -bounceDistance;
                         [self.contentView setFrame:frame];
                         [_slidingImageView setAlpha:0.0];
                         [self slideImageWithPercentage:0 imageName:_currentImageName isDragging:NO];
                     }
                     completion:^(BOOL finished1) {

                         [UIView animateWithDuration:kMCBounceDuration2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              CGRect frame = self.contentView.frame;
                                              frame.origin.x = 0;
                                              [self.contentView setFrame:frame];
                                          }
                                          completion:^(BOOL finished2) {
                                              [self notifyDelegate];
                                          }];
                     }];
}

#pragma mark - Delegate Notification

- (void)notifyDelegate {
    _state = [self stateWithPercentage:_currentPercentage];
    
    if (_state != MCSwipeTableViewCellStateNone) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(swipeTableViewCell:didTriggerState:withMode:)]) {
            [_delegate swipeTableViewCell:self didTriggerState:_state withMode:_mode];
            [_delegate swipeTableViewCell:self didChangeState:_state withMode:_mode];
            [_colorIndicatorView setBackgroundColor:COLOR_TABLE_CELL];
        }
    }
}

#pragma mark - Setter

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor {
    [self setFirstIconName:firstIconName];
    [self setSecondIconName:secondIconName];
    [self setThirdIconName:thirdIconName];
    [self setFourthIconName:fourthIconName];

    [self setFirstColor:firstColor];
    [self setSecondColor:secondColor];
    [self setThirdColor:thirdColor];
    [self setFourthColor:fourthColor];
}

@end