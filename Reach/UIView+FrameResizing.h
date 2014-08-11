//
//  UIView+FrameResizing.h
//  Reach
//
//  Created by Tom Bachant on 6/13/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameResizing)

/************************/
/*       Frame          */
/************************/

// Init
- (void)setFrameX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

// Size
- (void)setFrameSizeWidth:(CGFloat)sizeWidth;
- (CGFloat)getFrameSizeWidth;

- (void)setFrameSizeHeight:(CGFloat)sizeHeight;
- (CGFloat)getFrameSizeHeight;

// Origin
- (void)setFrameOriginX:(CGFloat)xOrigin;
- (CGFloat)getFrameOriginX;

- (void)setFrameOriginY:(CGFloat)yOrigin;
- (CGFloat)getFrameOriginY;

/************************/
/*       Center         */
/************************/

// Init
- (void)setCenterX:(CGFloat)x y:(CGFloat)y;

// Points
- (void)setCenterX:(CGFloat)xCenter;
- (CGFloat)getCenterX;

- (void)setCenterY:(CGFloat)yCenter;
- (CGFloat)getCenterY;

@end
