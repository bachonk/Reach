//
//  CCSlideSearchView.h
//  
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CCSlideSearchStateInactive = 0,
	CCSlideSearchStateHovering,
	CCSlideSearchStateSelecting,
} CCSlideSearchState;

@protocol CCSlideSearchDelegate;

//-----------------------------------------------------------------//
// View Elements                                                   //
//-----------------------------------------------------------------//

@interface CCSlideSearchView : UIView {
    
    NSArray *           availableSearchStrings;
    CGRect              startFrame;
    CGFloat             letterHeight;
    CGFloat             letterWidth;
    UIView *            highlighterView;
    UIImageView *       highlighterBackgroundView;
    UIImageView *       highlighterSelectedBackgroundView;
    UILabel *           highlighterLabel;
    UIImageView *       guideIndicatorView;
    
}

/**
 @description The search term
 */
@property (nonatomic, strong) NSString *term;

/**
 @description The currently highlighted letter
 */
@property (nonatomic, strong) NSString *highlightedLetter;

/**
 @description The limit on the number of characters in the search. Set to 1 to disable multiple letter selection and horizontal movement of the view
 */
@property (nonatomic) int characterLimit;

/**
 @description Whether there is a view that indicates the current phrase while searching. Default is YES.
 */
@property (nonatomic) BOOL highlightsWhileSearching;

/**
 @description The current state of the search view
 */
@property (nonatomic, assign) CCSlideSearchState state;

/**
 @description The delegate that can receive the actions of the search view
 */
@property (nonatomic, assign) id <CCSlideSearchDelegate> delegate;


@end


//-----------------------------------------------------------------//
// Delegate methods                                                //
//-----------------------------------------------------------------//

@protocol CCSlideSearchDelegate

//---------------  Basic start notitication  ----------------------//
/**
 @param searchView The CCSlideSearchView that calls the delegate
 @description Called when user first touches view
*/
- (void)slideSearchDidBegin:(CCSlideSearchView *)searchView;

//---------------  Selecting a letter while swiping  --------------//
/**
 @param searchView The CCSlideSearchView that calls the delegate
 @param letter The letter which is being hovered over / touched by the user's finger
 @param index The index of the hovered letter in the available letters array
 @param term The current search term
 @description This is called when the user is swiping up and down across the selection of letters
*/
- (void)slideSearch:(CCSlideSearchView *)searchView didHoverLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term;

//---------------  Confirming selection of letter  ----------------//
//
// This is called when the user swipes left to select a letter
//
- (void)slideSearch:(CCSlideSearchView *)searchView didConfirmLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term;

//---------------  Finishing selection of a search term  ----------//
//
// This is called when searching is complete
//
- (void)slideSearch:(CCSlideSearchView *)searchView didFinishSearchWithTerm:(NSString *)term;

@end
