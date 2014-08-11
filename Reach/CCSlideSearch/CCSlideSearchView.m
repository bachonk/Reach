//
//  CCSlideSearchView.m
//  
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import "CCSlideSearchView.h"

#define BACKGROUND_COLOR [UIColor clearColor];

#define LETTER_FONT [UIFont boldSystemFontOfSize:10]
#define LETTER_COLOR [UIColor colorWithWhite:0.2f alpha: 1.0f];

#define HIGHLIGHTER_FONT [UIFont fontWithName:@"Helvetica-Light" size:28.0f]

// Padding above and below the letters of the main search view
static const CGFloat paddingSearchView = 4.0f;

// Height of highlight view
static const CGFloat heightHighlightView = 60.0f;

// How far the highlighter is offset to the left of the main view
static const CGFloat movementSelectionThreshold = 72.0f;

// Inner padding for text with respect to highlight view bounds
static const CGFloat paddingHighlightView = 22.0f;

@interface CCSlideSearchView ()

@property (nonatomic, assign) CGFloat initialTouchPositionX;
@property (nonatomic, assign) CGFloat initialTouchPositionY;
@property (nonatomic, assign) CGFloat currentTouchPositionX;
@property (nonatomic, assign) CGFloat currentTouchPositionY;
@property (nonatomic, assign) CGFloat movementX;

@property (nonatomic, strong) UIView *letterView;

- (void)addLetterToSearchTerm:(NSString *)letter atIndex:(NSInteger)index;
- (void)hoverOverLetter:(NSString *)letter atIndex:(NSInteger)index;

- (void)updateHighlighterForLetter:(NSString *)letter;
- (void)flashStartGuideInidicator;
- (void)flashReturnGuideIndicator;

- (void)startSearch;
- (void)endSearch;

- (NSInteger)getIndexForYTouchCoord:(CGFloat)yPoint;

@end

@implementation CCSlideSearchView

@synthesize delegate;

/*
- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"CCSlideSearchView: Invalid initializer. Please use -(id)initWithFrame:");
    }
    return self;
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        self.highlightsWhileSearching = YES;
        
        self.term = @"";
        self.backgroundColor = [UIColor clearColor];

        availableSearchStrings = [[UILocalizedIndexedCollation currentCollation] sectionTitles];

        // Set up the properties
        startFrame = frame;
        letterHeight = (frame.size.height - (paddingSearchView * 2)) / [availableSearchStrings count];
        letterWidth = frame.size.width;

        // Set up the highlight view for future use
        highlighterView = [[UIView alloc] initWithFrame:CGRectMake(0, -movementSelectionThreshold, heightHighlightView, heightHighlightView)];
        highlighterView.clipsToBounds = NO;
        
        guideIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, heightHighlightView, heightHighlightView)];
        guideIndicatorView.alpha = 0.0f;
        [highlighterView addSubview:guideIndicatorView];
        
        highlighterBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, heightHighlightView, heightHighlightView)];
        highlighterBackgroundView.image = [[UIImage imageNamed:@"highlighter.png"] stretchableImageWithLeftCapWidth:heightHighlightView/2 topCapHeight:heightHighlightView/2];
        
        highlighterSelectedBackgroundView = [[UIImageView alloc] initWithFrame:highlighterBackgroundView.frame];
        highlighterSelectedBackgroundView.image = [[UIImage imageNamed:@"highlighter-selected.png"] stretchableImageWithLeftCapWidth:heightHighlightView/2 topCapHeight:heightHighlightView/2];
        highlighterSelectedBackgroundView.alpha = 0.0f;
        
        [highlighterView addSubview:highlighterBackgroundView];
        [highlighterView addSubview:highlighterSelectedBackgroundView];
        
        highlighterLabel = [[UILabel  alloc] initWithFrame:highlighterBackgroundView.frame];
        highlighterLabel.textColor = [UIColor whiteColor];
        highlighterLabel.backgroundColor = [UIColor clearColor];
        highlighterLabel.textAlignment = UITextAlignmentLeft;
        highlighterLabel.font = HIGHLIGHTER_FONT;
        [highlighterView addSubview:highlighterLabel];
        
        highlighterView.alpha = 0.0f;
        [self addSubview:highlighterView];
        
        // Set up the letter view
        _letterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _letterView.backgroundColor = BACKGROUND_COLOR;
        for (int i = 0; i < [availableSearchStrings count]; i++) {
            UILabel *containerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingSearchView + (letterHeight * i), letterWidth, letterHeight)];
            containerLabel.textAlignment = UITextAlignmentCenter;
            containerLabel.backgroundColor = [UIColor clearColor];
            containerLabel.font = LETTER_FONT;
            containerLabel.textColor = LETTER_COLOR;
            containerLabel.text = (NSString *)[availableSearchStrings objectAtIndex:i];
            [_letterView addSubview:containerLabel];
        }
        
        [self addSubview:_letterView];

    }
    
    return self;
}

#pragma mark - Handing Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchCoord = [touch locationInView:self];
    
    _initialTouchPositionX = touchCoord.x;
    _initialTouchPositionY = touchCoord.y;
    
    _currentTouchPositionX = touchCoord.x;
    _currentTouchPositionY = touchCoord.y;
    
    _movementX = 0;
    
    [self startSearch];
    
    [self hoverOverLetter:[availableSearchStrings objectAtIndex:[self getIndexForYTouchCoord:touchCoord.y]] atIndex:[self getIndexForYTouchCoord:touchCoord.y]];
        
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchCoord = [touch locationInView:self];
    
    _movementX = _initialTouchPositionX - touchCoord.x;
    
    if (self.state == CCSlideSearchStateHovering) {
        
        NSInteger indexOfLetter = [self getIndexForYTouchCoord:touchCoord.y];
        
        CGFloat halfOfHeight = (CGRectGetHeight(startFrame) / 2);
        CGFloat distanceFromCenter = (CGFloat)abs(halfOfHeight - touchCoord.y);
        CGFloat movementLimitationThreshold = 2 * movementSelectionThreshold / 3; // when hovering letters doesn't change based on vertical motion
        movementLimitationThreshold -= (distanceFromCenter / halfOfHeight) * (movementSelectionThreshold / 3);
        
        if (_movementX < movementLimitationThreshold) {
            [self hoverOverLetter:[availableSearchStrings objectAtIndex:indexOfLetter] atIndex:indexOfLetter];
        }

        // If searched beyond the limit, enable hovering but do not allow selection or horizontal motion
        if ([self.term length] < self.characterLimit - 1) {
            
            if (touchCoord.x < -movementSelectionThreshold) {
                // Selection
                [self addLetterToSearchTerm:self.highlightedLetter atIndex:0];
                
            }
            
        }
        
    } else if (self.state == CCSlideSearchStateSelecting) {
        
        if (_movementX > movementSelectionThreshold) {
            // Dampen or stop if necessary
            
            if (touchCoord.x > _currentTouchPositionX) {
                // Moving right after movement is beyond frame should not change position
                
            }
            else {
                // If the view has been pulled farther than one width of the view, it should be damped
                
            }
            
        }
        else if (touchCoord.x > -letterWidth) {
            _initialTouchPositionX = touchCoord.x;
            
            self.state = CCSlideSearchStateHovering;
            
            [UIView animateWithDuration:0.3f animations:^{
                guideIndicatorView.alpha = 0.0f;
            }];
        }

     }

    _currentTouchPositionX = touchCoord.x;
    _currentTouchPositionY = touchCoord.y;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endSearch];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endSearch];
}

#pragma mark - Actions

- (void)startSearch {
    
    self.state = CCSlideSearchStateHovering;
    
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    
    [delegate slideSearchDidBegin:self];
}

- (void)hoverOverLetter:(NSString *)letter atIndex:(NSInteger)index {
    
    self.state = CCSlideSearchStateHovering;
    
    [self updateHighlighterForLetter:letter];
    
    [delegate slideSearch:self didHoverLetter:letter atIndex:index withSearchTerm:self.term];
}

- (void)addLetterToSearchTerm:(NSString *)letter atIndex:(NSInteger)index {
    
    if ([letter isEqualToString:@"#"]) return;
    
    self.state = CCSlideSearchStateSelecting;
    
    if ([self.term length]) letter = [letter lowercaseString];
    
    self.term = [NSString stringWithFormat:@"%@%@", self.term, letter];
    
    if ([self.term length] == 1) [self flashReturnGuideIndicator];
    
    [self updateHighlighterForLetter:@""];
    
    [delegate slideSearch:self didConfirmLetter:letter atIndex:index withSearchTerm:self.term];
}

- (void)endSearch {
    
    self.state = CCSlideSearchStateInactive;
    
    [delegate slideSearch:self didFinishSearchWithTerm:self.term];
    
    self.term = @"";
    self.highlightedLetter = @"";
    
    self.backgroundColor = [UIColor clearColor];

    [UIView animateWithDuration:0.2 animations:^{
        
        highlighterView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Highlighter

- (void)updateHighlighterForLetter:(NSString *)letter {
    
    if (!self.highlightsWhileSearching) return;
    
    BOOL animated;
    if (![self.highlightedLetter length]) {
        [self flashStartGuideInidicator];
        animated = NO;
    } else {
        animated = YES;
    }
    
    if ([letter length]) self.highlightedLetter = letter;
    
    highlighterView.alpha = 1.0f;
    
    // Set alignment based on length. If only one letter shown in the higlighter, center it. Otherwise, align left to make more legible
    if ([self.term length] && [letter length]) {
        highlighterLabel.textAlignment = NSTextAlignmentLeft; // iOS7
    } else {
        highlighterLabel.textAlignment = NSTextAlignmentCenter; // iOS7
    }
    
    highlighterLabel.text = [[NSString stringWithFormat:@"%@%@", self.term, letter] uppercaseString];
    
    // Get size of text before new letter added
    CGSize sizeOfHighlightedText = [[highlighterLabel.text uppercaseString] sizeWithFont:HIGHLIGHTER_FONT constrainedToSize:CGSizeMake(CGFLOAT_MAX, heightHighlightView) lineBreakMode:NSLineBreakByTruncatingTail];
    if ([letter length]) {
        //sizeOfHighlightedText.width += 18.0f; // Add space for new character regardless of its size
        if ([self.term length]) {
            sizeOfHighlightedText.width += 3.0f;
        }
    }
    else {
        //sizeOfHighlightedText.width += 8.0f; // Add regular spacing
    }
    
    CGFloat yCenterCoord = _currentTouchPositionY;
    
    // If the value would put the highlighter frame out of screen, keep fully in view
    if (yCenterCoord < CGRectGetHeight(highlighterView.frame) / 2) {
        yCenterCoord = CGRectGetHeight(highlighterView.frame) / 2;
    }
    if (yCenterCoord > CGRectGetHeight(startFrame) - (CGRectGetHeight(highlighterView.frame) / 2)) {
        yCenterCoord = CGRectGetHeight(startFrame) - (CGRectGetHeight(highlighterView.frame) / 2);
    }
    
    // Removed animations because it caused some weird centering issues
    //
    //if (animated) {
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:0.25];
    //}
    
    CGFloat width = sizeOfHighlightedText.width + paddingHighlightView*2;
    if (width < heightHighlightView || ![self.term length]) {
        width = heightHighlightView;
        sizeOfHighlightedText.width = width;
    }
    CGFloat height = heightHighlightView;
    
    CGFloat xCoord = -movementSelectionThreshold - heightHighlightView;
    CGFloat yCoord = yCenterCoord - (CGRectGetHeight(highlighterView.frame) / 2);
    
    highlighterView.frame = CGRectMake(xCoord, yCoord, width, height);
    highlighterBackgroundView.frame = CGRectMake(0, 0, width, height);
    highlighterSelectedBackgroundView.frame = highlighterBackgroundView.frame;
    highlighterLabel.frame = CGRectMake([self.term length] ? paddingHighlightView : 0, 0, sizeOfHighlightedText.width, height);
    
    //if (animated) {
    //    [UIView commitAnimations];
    //}
    
    CGFloat accentAlpha = -_currentTouchPositionX / movementSelectionThreshold;
    if (accentAlpha > 1.0f) { accentAlpha = 1.0f; }
    if (accentAlpha < 0.0f) { accentAlpha = 0.0f; }
    highlighterSelectedBackgroundView.alpha = accentAlpha;
    
    if (![letter length]) {
        // Pop animation for letter view
        [UIView animateWithDuration:0.3 animations:^{
            
            highlighterView.transform = CGAffineTransformMakeScale(2.2, 2.2);
            
        } completion:^(BOOL completed) {
            
            [UIView animateWithDuration:0.12 animations:^{
                
                highlighterView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                
            }];
            
        }];
    }
    
}

- (void)flashStartGuideInidicator {
    
    guideIndicatorView.center = CGPointMake(movementSelectionThreshold, heightHighlightView / 2);
    guideIndicatorView.image = [UIImage imageNamed:@"guide-indicator-left.png"];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        guideIndicatorView.alpha = 0.4f;
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            guideIndicatorView.center = CGPointMake(0, heightHighlightView / 2);
            guideIndicatorView.alpha = 0.0f;

        }completion:^(BOOL completed) {
        
        }];
        
    }];
    
}

- (void)flashReturnGuideIndicator {
    
    CGFloat yCenter;
    if (_currentTouchPositionY > 80) {
        // Show above
        yCenter = -heightHighlightView / 2 - 10;
    } else {
        // Can't show above; show below
        yCenter = heightHighlightView + heightHighlightView;
    }
    guideIndicatorView.center = CGPointMake(heightHighlightView, yCenter);
    guideIndicatorView.image = [UIImage imageNamed:@"guide-indicator-right.png"];
    
    [UIView animateWithDuration:0.3f delay:0.6f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        guideIndicatorView.alpha = 0.4f;
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            guideIndicatorView.center = CGPointMake(movementSelectionThreshold + heightHighlightView, yCenter);
            guideIndicatorView.alpha = 0.0f;
            
        }completion:^(BOOL completed) {
            
        }];
        
    }];
    
}

#pragma mark - Helpers

- (NSInteger)getIndexForYTouchCoord:(CGFloat)yPoint {
    if (yPoint < 0) {
        return 0;
    }
    else if (yPoint >= startFrame.size.height) {
        return [availableSearchStrings count] - 1;
    }
    
    return (NSInteger)floor((yPoint / self.frame.size.height) * [availableSearchStrings count]);
}

@end
