//
//  RCContactDetailTableViewCell.m
//  Reach
//
//  Created by Tom Bachant on 5/26/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCContactDetailTableViewCell.h"
#import "Definitions.h"

@implementation RCContactDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 18, 200, 27)];
        _secondaryLabel.backgroundColor = [UIColor clearColor];
        _secondaryLabel.font = [UIFont fontWithName:kBoldFontName size:13.0f];
        _secondaryLabel.textColor = COLOR_DEFAULT_RED;
        _secondaryLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_secondaryLabel];
        
        _buttonLeft = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.contentView addSubview:_buttonLeft];
        
        _buttonRight = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.contentView addSubview:_buttonRight];
        
        _notesTextView = [[UITextView alloc] initWithFrame:CGRectMake(12, 18, 200, 27)];
        _notesTextView.editable = YES;
        _notesTextView.returnKeyType = UIReturnKeyDone;
        _notesTextView.font = [UIFont fontWithName:kLightFontName size:15.0f];
        _notesTextView.backgroundColor = [UIColor clearColor];
        _notesTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_notesTextView];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didHighlightCellForPhone:(NSNumber *)isForPhone {
    
    UIColor *textColor = [UIColor whiteColor];
    UIColor *bgColor = [isForPhone boolValue] ? COLOR_CALL_GREEN : COLOR_EMAIL_RED;
    
    [UIView transitionWithView:self
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        self.backgroundColor = bgColor;
                        self.mainLabel.textColor = textColor;
                        self.secondaryLabel.textColor = textColor;
                        
                        self.buttonLeft.tintColor = [UIColor whiteColor];
                        self.buttonRight.tintColor = [isForPhone boolValue] ? COLOR_TEXT_BLUE : [UIColor whiteColor];
                        
                    } completion:nil];
    
}

- (void)didUnhighlightCellForPhone:(NSNumber *)isForPhone {
    
    UIColor *textColor = [UIColor blackColor];
    UIColor *tintColor = [isForPhone boolValue] ? COLOR_TEXT_BLUE : COLOR_EMAIL_RED;
    
    [UIView transitionWithView:self
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        self.backgroundColor = COLOR_TABLE_CELL;
                        self.mainLabel.textColor = textColor;
                        self.secondaryLabel.textColor = COLOR_DEFAULT_RED;
                        
                        self.buttonRight.tintColor = tintColor;
                        self.buttonLeft.tintColor = COLOR_CALL_GREEN;
                        
                    } completion:nil];
    
}

@end
