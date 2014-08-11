//
//  UIView+FrameResizing.m
//  Reach
//
//  Created by Tom Bachant on 6/13/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "UIView+FrameResizing.h"

@implementation UIView (FrameResizing)

#pragma mark -
#pragma mark - Frame

#pragma mark - Init

- (void)setFrameX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(x, y, width, height);
}

#pragma mark - Size

#pragma mark Getter

- (CGFloat)getFrameSizeWidth {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)getFrameSizeHeight {
    return CGRectGetHeight(self.frame);
}

#pragma mark Setter

- (void)setFrameSizeWidth:(CGFloat)sizeWidth {
    CGRect frame = self.frame;
    frame.size.width = sizeWidth;
    self.frame = frame;
}

- (void)setFrameSizeHeight:(CGFloat)sizeHeight {
    CGRect frame = self.frame;
    frame.size.height = sizeHeight;
    self.frame = frame;
}

#pragma mark -
#pragma mark - Origin

#pragma mark Getter

- (CGFloat)getFrameOriginX {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)getFrameOriginY {
    return CGRectGetMinY(self.frame);
}

#pragma mark Setter

- (void)setFrameOriginX:(CGFloat)xOrigin {
    CGRect frame = self.frame;
    frame.origin.x = xOrigin;
    self.frame = frame;
}

- (void)setFrameOriginY:(CGFloat)yOrigin {
    CGRect frame = self.frame;
    frame.origin.y = yOrigin;
    self.frame = frame;
}

#pragma mark -
#pragma mark - Center

#pragma mark - Init

- (void)setCenterX:(CGFloat)x y:(CGFloat)y {
    self.center = CGPointMake(x, y);
}

#pragma mark - Points

#pragma mark Getter

- (CGFloat)getCenterX {
    return CGRectGetMidX(self.frame);
}

- (CGFloat)getCenterY {
    return CGRectGetMidY(self.frame);
}

#pragma mark Setter

- (void)setCenterX:(CGFloat)xCenter {
    CGPoint center = self.center;
    center.x = xCenter;
    self.center = center;
}

- (void)setCenterY:(CGFloat)yCenter {
    CGPoint center = self.center;
    center.y = yCenter;
    self.center = center;
}

@end
