//
//  RCNavHeaderView.m
//  Reach
//
//  Created by Tom Bachant on 2/23/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCNavHeaderView.h"
#import "Definitions.h"

static const CGFloat kPaddingImageToText = 5.0f;

@implementation RCNavHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 200.0f, 44.0f)];
    if (self)
    {
        // Initialization code
        
        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 30, 2, 60, 18)];
        _topLabel.font = [UIFont fontWithName:kBoldFontName size:10.0f];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textColor = [UIColor colorWithWhite:0.22f alpha:1.0f];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topLabel];
        
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _mainLabel.font = [UIFont fontWithName:kFontName size:16.0f];
        _mainLabel.backgroundColor = [UIColor clearColor];
        _mainLabel.textColor = [UIColor colorWithWhite:0.22f alpha:1.0f];
        _mainLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_mainLabel];
        
        _accessoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _accessoryImage.image = [UIImage imageNamed:@""];
        [self addSubview:_accessoryImage];
        
    }
    return self;
}

- (void)setTopLabel:(NSString *)top mainLabel:(NSString *)main accessory:(UIImage *)img
{
    _topLabel.text = top;
    _mainLabel.text = main;
    _accessoryImage.image = img;
    
    [_mainLabel sizeToFit];
    _mainLabel.center = CGPointMake(CGRectGetMidX(_topLabel.frame) + kPaddingImageToText + 10, 27);
    
    _accessoryImage.center = CGPointMake(CGRectGetMinX(_mainLabel.frame) - kPaddingImageToText - 20, CGRectGetMidY(_mainLabel.frame));
    
}

@end
