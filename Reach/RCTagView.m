//
//  RCTagView.m
//  Reach
//
//  Created by Tom Bachant on 7/12/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCTagView.h"
#import "Definitions.h"

#define TAG_FONT [UIFont boldSystemFontOfSize:14]

@interface RCTagView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageBackgroundView;

@end

@implementation RCTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id)initWithTagText:(NSString *)tagText {
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 0, 24);
    titleLabelFrame.size.width = [tagText boundingRectWithSize:CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] bounds]), CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:TAG_FONT,NSFontAttributeName, nil]context:nil].size.width + 36;
    
    self = [super initWithFrame:titleLabelFrame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageBackgroundView.image = [[[UIImage imageNamed:@"tag-background"] imageWithTintColor:COLOR_TAG_BLUE] stretchableImageWithLeftCapWidth:20 topCapHeight:12];
        
        [self addSubview:_imageBackgroundView];
        
        titleLabelFrame.origin.x += 24;
        titleLabelFrame.size.width -= 26;
        titleLabelFrame.origin.y += 4;
        titleLabelFrame.size.height -= 8;
        
        _titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        _titleLabel.backgroundColor = COLOR_TAG_BLUE;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = TAG_FONT;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = tagText;
        
        [self addSubview:_titleLabel];
        
    }
    return self;
}

@end
