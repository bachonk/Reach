//
//  RCNavHeaderView.h
//  Reach
//
//  Created by Tom Bachant on 2/23/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCNavHeaderView : UIView

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UIImageView *accessoryImage;
@property (nonatomic, strong) UILabel *mainLabel;

- (void)setTopLabel:(NSString *)top mainLabel:(NSString *)main accessory:(UIImage *)img;

@end
