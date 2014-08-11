//
//  RCContactDetailTableViewCell.h
//  Reach
//
//  Created by Tom Bachant on 5/26/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@interface RCContactDetailTableViewCell : MCSwipeTableViewCell

@property (nonatomic, strong) UILabel *secondaryLabel;

@property (nonatomic, strong) UIButton *buttonLeft;
@property (nonatomic, strong) UIButton *buttonRight;

@property (nonatomic, strong) UITextView *notesTextView;

- (void)didHighlightCellForPhone:(NSNumber *)isForPhone;
- (void)didUnhighlightCellForPhone:(NSNumber *)isForPhone;

@end
