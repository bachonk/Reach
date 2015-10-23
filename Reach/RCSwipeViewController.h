//
//  RCSwipeViewController.h
//  Reach
//
//  Created by Tom Bachant on 12/18/12.
//  Copyright (c) 2012 Thomas Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

#import "Definitions.h"

#import "MCSwipeTableViewCell.h"

#import "RCNewContactTableViewController.h"
#import "RCContactDetailViewController.h"
#import "RCListSelectorTableViewController.h"

#import "CCSlideSearchView.h"

#import "MNMToast.h"

#import "RCReminderViewController.h"

#import "Contact.h"

typedef enum {
    RCSwipeViewControllerSwipeStateNone = 0,
    RCSwipeViewControllerSwipeStateLeftReveal,
    RCSwipeViewControllerSwipeStateRightReveal
} RCSwipeViewControllerSwipeState;

typedef enum {
    RCSwipeViewControllerStateNormal = 0,
    RCSwipeViewControllerStateSearching,
    RCSwipeViewControllerStateViewingContact,
    RCSwipeViewControllerStateAddingContact
} RCSwipeViewControllerState;

@interface RCSwipeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MCSwipeTableViewCellDelegate, CCSlideSearchDelegate, RCReminderViewControllerDelegate, RCContactDetailViewControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, RCListSelectorDelegate> {
    
    // Main table view
    
    UITableView *       theTableView;
    
    // Search view
    
    UIView *            searchHeaderView;
    UIButton *          searchClearButton;
    UITextField *       searchTextField;
    NSInteger           searchFirstIndex;
    
    // Other classes
    
    CCSlideSearchView *searchView;
    
    // Flag for hiding the nav bar upon nav bar push
    BOOL shouldHideNavBarOnPush;
    
}


/***************************************************************
 *
 * Properties
 *
 ***************************************************************/

/////////////////////
//
// Contact arrays
/////////////////////

@property (nonatomic, strong) NSMutableArray *    contactList;
@property (nonatomic, strong) NSMutableArray *    filteredContactListFirstName;
@property (nonatomic, strong) NSMutableArray *    filteredContactListLastName;
@property (nonatomic, strong) NSMutableArray *    filteredContactListTags;
@property (nonatomic, strong) NSMutableArray *    filteredContactListTagNames;

- (NSMutableArray *)contacts;

@property (nonatomic, assign) RCContactType listType;

/////////////////////
//
// View state
/////////////////////

// The current state of the nav bar pan gesture
@property (nonatomic, assign) RCSwipeViewControllerSwipeState currentSwipeState;

// The current state of the view
@property (nonatomic, assign) RCSwipeViewControllerState currentState;

- (RCSwipeViewControllerState)swipeStateFromOffsetPercentage:(CGFloat)percentage;

/////////////////////
//
// Address book
/////////////////////

// Keep the address book
@property (nonatomic, assign) ABAddressBookRef addressBook;

// Track if access has been granted for contact access
@property (nonatomic, getter = isAccessRevoked) BOOL accessRevoked;

/////////////////////
//
// Searching
/////////////////////

// Search views
@property (nonatomic, strong) UITableView *searchTableView;


/***************************************************************
 *
 * Methods
 *
 ***************************************************************/

// Handling cell appearance
- (void)updateCell:(MCSwipeTableViewCell *)cell table:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

// Layouts
- (void)configureView;

// Actions for contacts
- (void)getContactListAuthentication;
- (void)getContacts;
- (void)saveAddressBook;
- (void)deleteContact:(Contact *)contact;

// Gesture handling
- (void)panGestureTriggered:(id)sender;
- (void)resetViewStateAnimated:(BOOL)animated;
- (void)animateViewOutForState:(RCSwipeViewControllerState)state velocity:(CGPoint)velocity completion:(void (^)(void))completion;
- (void)tapGestureTriggered:(id)sender;

// Searching
- (void)searchForTerm:(NSString *)searchTerm;

// Handling search view
- (void)showSearchViewAnimated:(BOOL)animated;
- (void)hideSearchViewAnimated:(BOOL)animated dismissDownward:(BOOL)shouldGoDownward;
@property (nonatomic, strong) UITapGestureRecognizer *searchCloseTagGestureRecognizer;

// Handling new contacts
- (void)showNewContactView;
- (void)hideNewContactViewAnimated:(BOOL)animated;
- (void)saveNewContact;

// Bar button items
- (void)didTapSearchButton;
- (void)didTapSearchCloseButton;

// Some important actions
- (void)call:(NSString *)number;
- (void)text:(NSString *)number;
- (void)email:(NSString *)address;
- (void)remind:(Contact *)contact;

// Swiping navigation bar
- (void)showPhoneDialerWithCompletion:(void (^)(void))completion;
- (void)showTextComposerWithCompletion:(void (^)(void))completion;
- (void)showEmailComposerWithCompletion:(void (^)(void))completion;

// Nav item actions
- (void)searchAction;
- (void)showMergeOptions;
- (void)presentListSelector;

// App opened from background
- (void)applicationDidBecomeActiveSinceDate:(NSDate *)lastOpen;

// App received notification
- (void)applicationDidReceiveRemoteNotification:(UILocalNotification *)notif applicationState:(UIApplicationState)state;

@end
