//
//  MCSwipeTableViewCell.h
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//
//  Modified by Tom Bachant
//

#import "Definitions.h"

@class MCSwipeTableViewCell;

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellState){
    MCSwipeTableViewCellStateNone = 0,
    MCSwipeTableViewCellState1,
    MCSwipeTableViewCellState2,
    MCSwipeTableViewCellState3,
    MCSwipeTableViewCellState4
};

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellDirection){
    MCSwipeTableViewCellDirectionLeft = 0,
    MCSwipeTableViewCellDirectionCenter,
    MCSwipeTableViewCellDirectionRight
};

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellMode){
    MCSwipeTableViewCellModeExit = 0,
    MCSwipeTableViewCellModeSwitch
};

@protocol MCSwipeTableViewCellDelegate <NSObject>

@optional
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didChangeState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode; // state changed

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode; // state confirmed

- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell;
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell;

@end

@interface MCSwipeTableViewCell : UITableViewCell

@property(nonatomic, assign) id <MCSwipeTableViewCellDelegate> delegate;

@property(nonatomic, copy) NSString *firstIconName;
@property(nonatomic, copy) NSString *secondIconName;
@property(nonatomic, copy) NSString *thirdIconName;
@property(nonatomic, copy) NSString *fourthIconName;

@property(nonatomic, strong) UIColor *firstColor;
@property(nonatomic, strong) UIColor *secondColor;
@property(nonatomic, strong) UIColor *thirdColor;
@property(nonatomic, strong) UIColor *fourthColor;

@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIColor *defaultCellBackgroundColor;

@property(nonatomic, strong) UIImageView *slidingImageView;
@property(nonatomic, strong) NSString *currentImageName;
@property(nonatomic, strong) UIView *colorIndicatorView;

@property(nonatomic, assign) MCSwipeTableViewCellMode mode;
@property(nonatomic, assign) MCSwipeTableViewCellState state;

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
 firstStateIconName:(NSString *)firstIconName
         firstColor:(UIColor *)firstColor
secondStateIconName:(NSString *)secondIconName
        secondColor:(UIColor *)secondColor
      thirdIconName:(NSString *)thirdIconName
         thirdColor:(UIColor *)thirdColor
     fourthIconName:(NSString *)fourthIconName
        fourthColor:(UIColor *)fourthColor;

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor;

@end
