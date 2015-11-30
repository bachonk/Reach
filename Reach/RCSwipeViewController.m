//
//  RCSwipeViewController.m
//  Reach
//
//  Created by Tom Bachant on 12/18/12.
//  Copyright (c) 2012 Thomas Bachant. All rights reserved.
//

#import "RCSwipeViewController.h"
#import "AppDelegate.h"

#import "RCContactManager.h"

#import "RCSettingsTableViewController.h"
#import "RCSocialDetailViewController.h"

#import "RCRemindListTableViewController.h"

#import "LinkedInManager.h"
#import "BBBadgeBarButtonItem.h"

#import "UIImageView+WebCache.h"

// Frame sizes
#define SLIDE_SEARCH_WIDTH 18
#define TOP_BAR_HEIGHT 44

// Search view definitions
#define SEARCH_BACKGROUND_OPACITY 0.7f
#define SEARCH_FRAME_PADDING 0.0f

// Tags for action sheet
static const NSInteger kTagActionSheetMergeOptions = 10;
static const NSInteger kTagActionSheetCancelContact = 11;

// Panning constants
static const CGFloat percentagePanThresholdLeftReveal = 0.25f;
static const CGFloat percentagePanThresholdRightReveal = 0.25f;

// Cell heights
static const CGFloat headerHeight = 34.0f;

@interface RCSwipeViewController ()

// Helper for swapping out nav bar / headers with other tables / content views
- (void)swapInHeaderView:(UIView *)view contentView:(UIView *)contentView animated:(BOOL)animated;
- (void)swapOutHeaderView:(UIView *)view contentView:(UIView *)contentView animated:(BOOL)animated downward:(BOOL)goDownward completion:(void(^)(void))completion;

/////////////////////
//
// Contact Details
/////////////////////

@property (nonatomic, strong) RCContactDetailViewController *contactDetailViewController;
- (void)showContactDetails:(Contact *)contact;

/////////////////////
//
// Reminders
/////////////////////

- (void)showRemindersList;

/////////////////////
//
// New Contact
/////////////////////

// The table that shows new users and existing users
@property (nonatomic, strong) RCNewContactTableViewController *addContactTableViewController;


@end

@implementation RCSwipeViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewContactView)];
    
    self.title = NSLocalizedString(@"Contacts", nil);
    
    self.view.backgroundColor = COLOR_TABLE_CELL;

    _filteredContactListFirstName = [[NSMutableArray alloc] init];
    _filteredContactListLastName = [[NSMutableArray alloc] init];
    _filteredContactListTags = [[NSMutableArray alloc] init];
    _filteredContactListTagNames = [[NSMutableArray alloc] init];
    
    _listType = RCContactTypePhoneContact;
    
    theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    theTableView.rowHeight = 48.0f;
    theTableView.separatorInset = UIEdgeInsetsMake(0, kCellHeightDefault, 0, 0);
    theTableView.separatorColor = COLOR_NAVIGATION_BAR;
    theTableView.delegate = self;
    theTableView.dataSource = self;
    theTableView.backgroundColor = COLOR_TABLE_CELL;
    theTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    theTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, SLIDE_SEARCH_WIDTH - 2);
    
    [self.view addSubview:theTableView];
    
    CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    
    /**
     *
     *      Search header view
     *
     */
    
    searchHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]), CGRectGetWidth(self.view.frame), TOP_BAR_HEIGHT + statusBarHeight)];
    searchHeaderView.backgroundColor = [UIColor whiteColor];
    searchHeaderView.alpha = 0.0f;
    
    searchClearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    searchClearButton.frame = CGRectMake(5, statusBarHeight + ((TOP_BAR_HEIGHT - 40) / 2), 40, 40);
    [searchClearButton setBackgroundImage:[[UIImage imageNamed:@"search-icon.png"] imageWithTintColor:COLOR_DEFAULT_RED] forState:UIControlStateNormal];
    [searchClearButton addTarget:self action:@selector(didTapSearchButton) forControlEvents:UIControlEventTouchUpInside];
    [searchHeaderView addSubview:searchClearButton];
    
    UIButton *searchCloseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    searchCloseButton.frame = CGRectMake(CGRectGetWidth(searchHeaderView.bounds) - 45, statusBarHeight + ((TOP_BAR_HEIGHT - 40) / 2), 40, 40);
    [searchCloseButton addTarget:self action:@selector(didTapSearchCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [searchCloseButton setBackgroundImage:[UIImage imageNamed:@"close-icon.png"] forState:UIControlStateNormal];
    [searchHeaderView addSubview:searchCloseButton];
    
    CGRect searchTextFrame = CGRectMake(46, statusBarHeight + ((TOP_BAR_HEIGHT - 22) / 2), 200, 22);
    searchTextField = [[UITextField alloc] initWithFrame:searchTextFrame
                       ];
    searchTextField.delegate = self;
    searchTextField.placeholder = NSLocalizedString(@"Search for contacts", nil);
    searchTextField.returnKeyType = UIReturnKeySearch;
    searchTextField.font = [UIFont systemFontOfSize:18.0f];
    searchTextField.textColor = [UIColor blackColor];
    searchTextField.tintColor = COLOR_DEFAULT_RED;
    [searchHeaderView addSubview:searchTextField];

    _searchTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _searchTableView.separatorColor = COLOR_NAVIGATION_BAR;
    _searchTableView.rowHeight = 54.0f;
    _searchTableView.delegate = self;
    _searchTableView.backgroundColor = [UIColor clearColor];
    _searchTableView.dataSource = self;
    _searchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    _searchTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(searchHeaderView.frame), 0, CGRectGetMaxY(searchHeaderView.frame), 0);
    _searchTableView.alpha = 0.0f;
    
    [self.view addSubview:_searchTableView];
    
    /**
     *
     *      Slide search view
     *
     */
    
    CGFloat heightOfStatusBarAndNavBar = CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    CGRect searchViewContainerRect = CGRectMake(CGRectGetWidth(self.view.frame) - SLIDE_SEARCH_WIDTH, heightOfStatusBarAndNavBar, SLIDE_SEARCH_WIDTH, CGRectGetHeight([[UIScreen mainScreen] bounds]) - heightOfStatusBarAndNavBar);
    searchView = [[CCSlideSearchView alloc] initWithFrame:CGRectInset(searchViewContainerRect, 0, 15)];
    searchView.delegate = self;
    searchView.characterLimit = 6;
    searchView.layer.cornerRadius = SLIDE_SEARCH_WIDTH / 2;
    [self.view addSubview:searchView];
    [self.view addSubview:searchHeaderView];
    
    /**
     *
     *      New Contact View
     *
     */
    
    _addContactTableViewController = [[RCNewContactTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _addContactTableViewController.tableView.frame = self.view.frame;
    _addContactTableViewController.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(searchHeaderView.frame) - 10, 0, CGRectGetMaxY(searchHeaderView.frame), 0);
    _addContactTableViewController.tableView.backgroundColor = [UIColor clearColor];
    _addContactTableViewController.tableView.alpha = 0.0f;
    
    [self.view addSubview:_addContactTableViewController.tableView];
    
    /*
     * Add this back in for swiping nav bar
     *
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureTriggered:)];
    panGesture.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:panGesture];
     */
    
    /**
     *
     *      Set initial state
     *
     */
    [self configureView];
    [self hideNewContactViewAnimated:NO];
    [self hideSearchViewAnimated:NO dismissDownward:YES];
    
    self.currentSwipeState = RCSwipeViewControllerSwipeStateNone;
    
    // Pull the contact list
    [[RCContactManager shared] getContactListAuthorizationWithCompletion:^(ABAuthorizationStatus status) {
        // Could do something here
        [theTableView reloadData];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:COLOR_DEFAULT_RED];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName: [UIColor blackColor]
                                                                      }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (_currentState == RCSwipeViewControllerStateSearching) {

        [self showSearchViewAnimated:NO];
        
    } else if (_currentState == RCSwipeViewControllerStateAddingContact) {
        
        [self showNewContactView];
        
    } else {
        
        [self configureView];
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (shouldHideNavBarOnPush)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    shouldHideNavBarOnPush = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)setNeedsStatusBarAppearanceUpdate {
    [super setNeedsStatusBarAppearanceUpdate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle] animated:YES];
    
}

#pragma mark - Local Notification

- (void)applicationDidReceiveRemoteNotification:(UILocalNotification *)notif
                                     actionType:(NSString *)action
                               applicationState:(UIApplicationState)state {
    
    NSDictionary *deets = notif.userInfo;
    NSString *contactId = [deets objectForKey:kLocalNotificationUserInfoUserID];
    NSString *actionString = [deets objectForKey:kLocalNotificationUserInfoActionString];
    NSString *reminderMessage = [deets objectForKey:kLocalNotificationAlertActionName];
    NSInteger actionType = [[deets objectForKey:kLocalNotificationUserInfoActionType] integerValue];
    
    __weak Contact *contact = nil;
    
    for (NSArray *sections in [self contacts]) {
        for (Contact *person in sections) {
            if ([person.contactId isEqualToString:contactId]) {
                contact = person;
                break;
            }
        }
        if (contact) {
            break;
        }
    }
    
    if (contact) {
        
        if ([action length]) {
            NSLog(@"ACTION: %@", action);
        }
        
        NSString *toastText = [NSString stringWithFormat:@"%@: %@ %@%@", NSLocalizedString(@"Reminder", nil), actionString, contact.fullName, [reminderMessage length] ? [NSString stringWithFormat:@" - %@", reminderMessage] : @""];
                               
        if (state == UIApplicationStateActive) {
            // Show banner with action
            
            __weak RCSwipeViewController *weakSelf = self;
            
            [MNMToast showWithText:toastText autoHidding:YES priority:MNMToastPriorityHigh completionHandler:nil tapHandler:^(MNMToastValue *toast) {
                
                switch (actionType) {
                    case RCReminderTypeCall:
                    {
                        if ([contact.mobile length]) {
                            [weakSelf call:contact.mobile];
                        }
                        else if ([contact.home length]) {
                            [weakSelf call:contact.home];
                        }
                        else {
                            [weakSelf showContactDetails:contact];
                        }
                        
                        break;
                    }
                    case RCReminderTypeEmail:
                    {
                        if ([contact.email length]) {
                            [weakSelf email:contact.email];
                        }
                        else {
                            [weakSelf showContactDetails:contact];
                        }
                        
                        break;
                    }
                    case RCReminderTypeText:
                    {
                        if ([contact.mobile length]) {
                            [weakSelf text:contact.mobile];
                        }
                        else {
                            [weakSelf showContactDetails:contact];
                        }
                        
                        break;
                    }
                    default:
                        break;
                }
                
            }];
            
        }
        else {
            // Bring them to the contact
            
            [self showContactDetails:contact];
            
            __weak RCContactDetailViewController *weakDetail = _contactDetailViewController;
            
            [MNMToast showWithText:toastText autoHidding:YES priority:MNMToastPriorityHigh completionHandler:nil tapHandler:^(MNMToastValue *val) {
                
                switch (actionType) {
                    case RCReminderTypeCall:
                    {
                        if ([contact.mobile length]) {
                            [weakDetail call:contact.mobile];
                        }
                        else if ([contact.home length]) {
                            [weakDetail call:contact.home];
                        }
                        
                        break;
                    }
                    case RCReminderTypeEmail:
                    {
                        if ([contact.email length]) {
                            [weakDetail email:contact.email];
                        }
                        
                        break;
                    }
                    case RCReminderTypeText:
                    {
                        if ([contact.mobile length]) {
                            [weakDetail text:contact.mobile];
                        }
                        
                        break;
                    }
                    default:
                        break;
                }
                
            }];
            
        }
        
    }
    
}

#pragma mark - Application Status

- (void)applicationDidBecomeActiveSinceDate:(NSDate *)lastOpen {
    
    NSTimeInterval hoursSinceOpen = [[NSDate date] timeIntervalSinceDate:lastOpen] / (60 * 60);
    if (hoursSinceOpen > 1) {
        
        if (_currentState == RCSwipeViewControllerStateSearching) {
            [self hideSearchViewAnimated:YES dismissDownward:YES];
        }
        else if (_currentState == RCSwipeViewControllerStateAddingContact) {
            [_addContactTableViewController clearData];
            [self hideNewContactViewAnimated:NO];
        }
        else if (_currentState == RCSwipeViewControllerStateViewingContact) {
            [self dismissViewControllerAnimated:YES completion:^{
                
                //[_contactDetailViewController hideDownward:YES];

            }];
        }
        
        if (![RCContactManager shared].accessRevoked) {
            [[RCContactManager shared] fetchContacts]; // lazy refresh
            [theTableView reloadData];
        }
        
    }
    
    // Retry for contact access if it's been restricted
    if ([RCContactManager shared].accessRevoked) {
        [[RCContactManager shared] getContactListAuthorizationWithCompletion:^(ABAuthorizationStatus status) {
            [theTableView reloadData];
        }];
    }
    
}

#pragma mark - Layouts

- (void)configureView {
    [theTableView reloadData];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (_currentState == RCSwipeViewControllerStateAddingContact) {
        self.title = NSLocalizedString(@"New Contact", nil);
        
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(hideNewContactViewAnimated:)] animated:YES];
        [self.navigationItem setRightBarButtonItems:@[
                                                    [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveNewContact)]
                                                    ]
                                           animated:YES];
        
    }
    else {
        self.title = NSLocalizedString(@"Contacts", nil);
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction)];

        NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        if ([notifications count]) {
            UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
            but.frame = CGRectMake(0, 0, 38, 38);
            but.tintColor = COLOR_DEFAULT_RED;
            [but setImage:[UIImage imageNamed:@"reminder-icon"] forState:UIControlStateNormal];
            [but addTarget:self action:@selector(showRemindersList) forControlEvents:UIControlEventTouchUpInside];
            
            // Create and add our custom BBBadgeBarButtonItem
            BBBadgeBarButtonItem *notifButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:but];
            // Set a value for the badge
            notifButton.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[notifications count]];
            notifButton.badgeOriginX = 24.0f;
            notifButton.badgeOriginY = -2.0f;
            
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewContactView)];
            
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
            spacer.width = 16.0f;
            
            [self.navigationItem setRightBarButtonItems:@[
                                                        addButton,
                                                        spacer,
                                                        notifButton
                                                        ]
                                               animated:YES];
        }
        else {
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewContactView)] animated:YES];
        }
        
    }
    
    /***
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    titleButton.frame = CGRectMake(0, 0, 140, 44);
    [titleButton addTarget:self action:@selector(presentListSelector) forControlEvents:UIControlEventTouchUpInside];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [titleButton setBackgroundImage:[[UIImage imageNamed:@"button-dropdown.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] forState:UIControlStateNormal];
    
    if (_listType == RCContactTypeLinkenIn) {
        [searchClearButton setBackgroundImage:[[UIImage imageNamed:@"search-icon.png"] imageWithTintColor:COLOR_LINKEDIN_BLUE] forState:UIControlStateNormal];
        searchTextField.tintColor = COLOR_LINKEDIN_BLUE;
        
        [titleButton setTitle:@"LinkedIn" forState:UIControlStateNormal];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMergeOptions)];
        
    } else {
        [searchClearButton setBackgroundImage:[[UIImage imageNamed:@"search-icon.png"] imageWithTintColor:COLOR_DEFAULT_RED] forState:UIControlStateNormal];
        searchTextField.tintColor = COLOR_DEFAULT_RED;
        
        [titleButton setTitle:NSLocalizedString(@"Contacts", nil) forState:UIControlStateNormal];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewContactView)];
        
    }
    
    [self.navigationItem setTitleView:titleButton];
    ***/
}

#pragma mark - Show/hide animations

- (void)swapInHeaderView:(UIView *)view contentView:(UIView *)contentView animated:(BOOL)animated {
    
    [UIView animateWithDuration:animated ? 0.38 : 0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        // Header
        
        if (view) {
            [view setFrameOriginY:0];
            view.alpha = 1.0f;
            
            [self.navigationController.navigationBar setFrameOriginY:- CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) - CGRectGetHeight(self.navigationController.navigationBar.frame)];
        }
        
        // Content
        
        contentView.alpha = 1.0f;
        contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - SEARCH_FRAME_PADDING);
        
        theTableView.transform = CGAffineTransformMakeScale(0.78, 0.78);
        theTableView.alpha = 0.06f;
        
        self.view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    } completion:^(BOOL completed) {
        
        // Set navigation bar as hidden so it doesn't reappear on app open
        if (view) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
        
    }];
    
}

- (void)swapOutHeaderView:(UIView *)view contentView:(UIView *)contentView animated:(BOOL)animated downward:(BOOL)goDownward completion:(void (^)(void))completion {
    
    // Treat the nav bar as "unhidden" while maintaining the frame change
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.frame = navBarFrame;
    
    [UIView animateWithDuration:animated ? 0.49 : 0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        // Header
        
        if (view) {
            view.alpha = 0.0f;
            [view setFrameOriginY:-CGRectGetHeight(view.frame)];
            
            [self.navigationController.navigationBar setFrameOriginY:CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])];
        }
        
        // Content
        
        theTableView.transform = CGAffineTransformMakeScale(0.78, 0.78);
        
        contentView.alpha = 0.0f;
        
        if (goDownward) {
            contentView.center = CGPointMake(contentView.center.x, CGRectGetHeight(self.view.frame) + CGRectGetHeight(contentView.frame));
        } else {
            contentView.center = CGPointMake(contentView.center.x, 0 - CGRectGetHeight(contentView.frame));
        }
        
        theTableView.transform = CGAffineTransformIdentity;
        theTableView.alpha = 1.0f;
        
        self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        
    } completion:^(BOOL finished) {
        
        if (completion)
            completion();
        
    }];
    
}

#pragma mark - CCSlideSearchDelegate

- (void)slideSearchDidBegin:(CCSlideSearchView *)slideSearchView {
    [self.view endEditing:YES];
    
    if ([searchTextField.text length]) {
        [slideSearchView setTerm:[searchTextField.text uppercaseString]];
    }
}

- (void)slideSearch:(CCSlideSearchView *)searchView didHoverLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term {
    
    if (![term length]) {
        searchFirstIndex = index;
    }
    
    if ([searchTextField.text length]) {
        term = [searchTextField.text uppercaseString];
    }
    
    NSString *termToSearch = [NSString stringWithFormat:@"%@%@", term, letter];
    if ([termToSearch length] && ([_filteredContactListFirstName count] || [_filteredContactListLastName count])) {
        
        // Is searching, scroll to nearest point
        
        NSInteger indexPathRowForLetter = -1;
        Contact *contact;
        
        if ([_filteredContactListFirstName count]) {
            for (int i = 0; i < [_filteredContactListFirstName count]; i++) {
                contact = [_filteredContactListFirstName objectAtIndex:i];
                
                if ([[contact.fullName lowercaseString] hasPrefix:[termToSearch lowercaseString]]) {
                    
                    // We've got a hit in the first name
                    indexPathRowForLetter = i;
                    
                    break;
                }
            }
        }
        else if ([_filteredContactListLastName count]) {
            
            for (int i = 0; i < [_filteredContactListLastName count]; i++) {
                contact = [_filteredContactListLastName objectAtIndex:i];
                
                if ([[contact.fullName lowercaseString] rangeOfString:[NSString stringWithFormat:@" %@", [termToSearch lowercaseString]]].location != NSNotFound) {
                    
                    // Hit in the last name
                    indexPathRowForLetter = i;
                    
                    break;
                }
            }
        }
        
        if (indexPathRowForLetter >= 0) {
            [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPathRowForLetter inSection:[_filteredContactListFirstName count] ? 0 : 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    } else if ([[[self contacts] objectAtIndex:index] count]) {
        
        [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }
    
}

- (void)slideSearch:(CCSlideSearchView *)searchView didConfirmLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term {
    
    if (searchFirstIndex >= 0 && searchFirstIndex < 26) {
        
        if (![searchTextField.text length]) {
            // Starting search, show table
            [self showSearchViewAnimated:YES];
            [self searchForTerm:term];

        } else {
            // Continuing existing search
            [self searchForTerm:[NSString stringWithFormat:@"%@%@", searchTextField.text, [letter lowercaseString]]];
            
        }
        
    }
    
}

- (void)slideSearch:(CCSlideSearchView *)searchView didFinishSearchWithTerm:(NSString *)term {
    NSLog(@"Did finish with term %@", term);
}

#pragma mark - Search View

#pragma Search

- (void)searchForTerm:(NSString *)sTerm {
    
    // Clear out old data
    [_filteredContactListFirstName removeAllObjects];
    [_filteredContactListLastName removeAllObjects];
    [_filteredContactListTags removeAllObjects];
    [_filteredContactListTagNames removeAllObjects];
    
    NSString *caseInsensitiveSearchTerm = [sTerm lowercaseString];
    
    if ([caseInsensitiveSearchTerm length]) {

        for (NSArray *alphabeticalList in [self contacts]) {
            for (Contact *contact in alphabeticalList) {
                
                if ([[contact.fullName lowercaseString] hasPrefix:caseInsensitiveSearchTerm]) {
                    
                    // We've got a hit in the first name
                    [_filteredContactListFirstName addObject:contact];
                    
                } else if ([[contact.fullName lowercaseString] rangeOfString:[NSString stringWithFormat:@" %@", caseInsensitiveSearchTerm]].location != NSNotFound) {
                    
                    // Hit in the last name
                    [_filteredContactListLastName addObject:contact];
                    
                }
                else {
                    
                    // Check for tags
                    for (NSString *tag in contact.tags) {
                        if ([[tag lowercaseString] hasPrefix:caseInsensitiveSearchTerm]) {
                            // Hit a tag
                            contact.highlightedTag = tag;

                            // Check if we've hit a tag already matched in our results
                            BOOL foundExistingTag = NO;
                            for (NSInteger i = 0; i < [_filteredContactListTagNames count]; i++) {
                                if ([(NSString *)_filteredContactListTagNames[0] isEqualToString:tag]) {
                                    [_filteredContactListTags[i] addObject:contact];
                                    foundExistingTag = YES;
                                }
                            }
                            if (!foundExistingTag) {
                                [_filteredContactListTags addObject:[NSMutableArray arrayWithObject:contact]];
                                [_filteredContactListTagNames addObject:tag];
                            }
                            break;
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    // Reload table
    // Animate if different count
    //[_searchTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                   //withRowAnimation:previousSearchResultCount == [_filteredContactList count] ? UITableViewRowAnimationNone : UITableViewRowAnimationAutomatic];
                   //withRowAnimation:UITableViewRowAnimationNone];
    
    [_searchTableView reloadData];
    if ([_filteredContactListFirstName count]) {
        [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        _searchCloseTagGestureRecognizer.enabled = NO;
    } else if ([_filteredContactListLastName count]) {
        [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        _searchCloseTagGestureRecognizer.enabled = NO;
    } else if ([_filteredContactListTags count]) {
        [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        _searchCloseTagGestureRecognizer.enabled = NO;
    } else {
        _searchCloseTagGestureRecognizer.enabled = YES;
    }
     
    searchTextField.text = sTerm;
    
}

#pragma mark Show/hide

- (void)showSearchViewAnimated:(BOOL)animated {
    
    self.currentState = RCSwipeViewControllerStateSearching;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [_searchTableView reloadData];
    if ([_filteredContactListFirstName count]) {
        [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else if ([_filteredContactListLastName count]) {
        [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else if ([_filteredContactListTags count]) {
        [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        _searchCloseTagGestureRecognizer.enabled = YES;
    }
    
    if (_searchCloseTagGestureRecognizer == nil) {
        _searchCloseTagGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTriggered:)];
        [_searchTableView addGestureRecognizer:_searchCloseTagGestureRecognizer];
    }
    
    // Do the main animation for moving header and table
    [self swapInHeaderView:searchHeaderView contentView:_searchTableView animated:animated];
    
}

- (void)hideSearchViewAnimated:(BOOL)animated dismissDownward:(BOOL)shouldGoDownward {
    
    self.currentState = RCSwipeViewControllerStateNormal;

    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view endEditing:YES];
    
    [self swapOutHeaderView:searchHeaderView contentView:_searchTableView animated:animated downward:shouldGoDownward completion:^{
        
        searchTextField.text = @"";
        [_filteredContactListFirstName removeAllObjects];
        [_filteredContactListLastName removeAllObjects];
        [_filteredContactListTags removeAllObjects];
        [_filteredContactListTagNames removeAllObjects];
        
        [_searchTableView reloadData]; // Just to be sure
        
    }];
    
    _searchCloseTagGestureRecognizer.enabled = NO;
    
}

#pragma mark - New Contact

#pragma mark Save

- (void)saveNewContact {
    // Save a new contact
    
    if (![_addContactTableViewController hasData]) {
        [self hideNewContactViewAnimated:YES];
        return;
    }
    
    // Get the contact entry
    ABRecordRef newEntry = [_addContactTableViewController getContactRef];
    
    // Get a contact copy
    Contact *contact = [Contact contactFromAddressBook:newEntry];
    
    // Add to address book
    [[RCContactManager shared] fetchContacts];
    
    // Show contact details
    [_addContactTableViewController clearData];
    [self hideNewContactViewAnimated:YES];
    [self showContactDetails:contact];
}

#pragma mark Show/hide

- (void)showNewContactView {
    
    self.currentState = RCSwipeViewControllerStateAddingContact;
    
    [self configureView];
    
    // Show the contact
    
    [self swapInHeaderView:nil contentView:_addContactTableViewController.tableView animated:YES];
    
    [_addContactTableViewController prepareForNewContact];
        
}

- (void)hideNewContactViewAnimated:(BOOL)animated {
    
    if ([_addContactTableViewController hasData]) {
        [self.view endEditing:YES];
        
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Don't Save" otherButtonTitles: nil];
        ac.destructiveButtonIndex = 0;
        ac.tag = kTagActionSheetCancelContact;
        [ac showInView:self.view];
        return;
    }
        
    [self.view endEditing:YES];
    
    self.currentState = RCSwipeViewControllerStateNormal;

    [self configureView];
    
    // Hide the contact view
    
    [self swapOutHeaderView:nil contentView:_addContactTableViewController.tableView animated:YES downward:YES completion:nil];
    
}

#pragma mark - Pan Gesture Handling

- (void)panGestureTriggered:(UIPanGestureRecognizer *)gesture {
    UIGestureRecognizerState state = [gesture state];
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.view.frame) relativeToWidth:CGRectGetWidth(self.view.bounds)];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    RCSwipeViewControllerState swipeState = [self swipeStateFromOffsetPercentage:percentage];

    if (state == UIGestureRecognizerStateBegan) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }
    else if (state == UIGestureRecognizerStateChanged) {
        CGPoint center = {self.view.center.x + translation.x, self.view.center.y};
        CGPoint navCenter = {self.navigationController.navigationBar.center.x + translation.x, self.navigationController.navigationBar.center.y};
        
        [self.view setCenter:center];
        [self.navigationController.navigationBar setCenter:navCenter];
        
        [gesture setTranslation:CGPointZero inView:self.view];
        
        if (self.currentSwipeState != swipeState) {
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (swipeState == RCSwipeViewControllerSwipeStateLeftReveal) {
                
                delegate.windowBackgroundView.backgroundColor = [UIColor greenColor];
                
            } else if (swipeState == RCSwipeViewControllerSwipeStateRightReveal) {
                
                delegate.windowBackgroundView.backgroundColor = [UIColor blueColor];
                
            } else {
                
                delegate.windowBackgroundView.backgroundColor = COLOR_WINDOW_BACKGROUND;
                
            }
            
        }
        
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

        if (swipeState == RCSwipeViewControllerSwipeStateLeftReveal) {
            
            // Text
            
            [self animateViewOutForState:swipeState velocity:velocity completion:^{ // Move view out
                [self showTextComposerWithCompletion:^{ // Show texter
                    [self resetViewStateAnimated:NO]; // Move view back in
                }];
            }];
            
        }
        else if (swipeState == RCSwipeViewControllerSwipeStateRightReveal) {
            
            // Phone
            
            [self animateViewOutForState:swipeState velocity:velocity completion:^{ // Move view out
                [self showPhoneDialerWithCompletion:^{ // Show dialer
                    [self resetViewStateAnimated:NO]; // Move view back in
                }];
            }];
            
        }
        else {
            
            // Nada
            
            [self resetViewStateAnimated:YES];
        
        }
        
    }
    
    self.currentSwipeState = swipeState;

}

- (void)resetViewStateAnimated:(BOOL)animated {
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.15];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    CGRect frame = self.view.frame;
    CGRect navFrame = self.navigationController.navigationBar.frame;
    
    frame.origin.x = 0;
    navFrame.origin.x = 0;
    
    self.view.frame = frame;
    self.navigationController.navigationBar.frame = navFrame;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.windowBackgroundView.backgroundColor = COLOR_WINDOW_BACKGROUND;
    
    if (animated) {
        [UIView commitAnimations];
    }
    
}

- (void)animateViewOutForState:(RCSwipeViewControllerState)state velocity:(CGPoint)velocity completion:(void (^)(void))completion {
    
    [UIView animateWithDuration:[self animationDurationWithVelocity:velocity] delay:0.0f options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        CGRect frame = self.view.frame;
        CGRect navFrame = self.navigationController.navigationBar.frame;
    
        if (state == RCSwipeViewControllerSwipeStateLeftReveal) {
            frame.origin.x = CGRectGetWidth(frame);
            navFrame.origin.x = CGRectGetWidth(navFrame);
        } else {
            frame.origin.x = -CGRectGetWidth(frame);
            navFrame.origin.x = -CGRectGetWidth(navFrame);
        }
        
        self.view.frame = frame;
        self.navigationController.navigationBar.frame = navFrame;
        
    } completion:^(BOOL completed) {
        completion();
    }];
    
}

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width {
    CGFloat offset = percentage * width;
    
    if (offset < -width) offset = -width;
    else if (offset > width) offset = 1.0;
    
    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    NSTimeInterval animationDurationDiff = 1 - 0.1;
    CGFloat horizontalVelocity = velocity.x;
    
    if      (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;
    
    return (1 + 0.1) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}

- (RCSwipeViewControllerState)swipeStateFromOffsetPercentage:(CGFloat)percentage {
    
    RCSwipeViewControllerState state = RCSwipeViewControllerSwipeStateNone;
    
    if (percentage > percentagePanThresholdLeftReveal) {
        state = RCSwipeViewControllerSwipeStateLeftReveal;
    }
    else if (percentage < -percentagePanThresholdRightReveal) {
        state = RCSwipeViewControllerSwipeStateRightReveal;
    }
    
    return state;
    
}

#pragma mark - Tap Gesture Handling

- (void)tapGestureTriggered:(id)sender {
    [self hideSearchViewAnimated:YES dismissDownward:YES];
}

#pragma mark - Getting Contacts

- (NSMutableArray *)contacts {
    if (_listType == RCContactTypeLinkenIn) {
        return [LinkedInManager shared].contacts;
    }
    return [RCContactManager shared].contacts;
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newTerm = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self searchForTerm:newTerm];
    
    return NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:YES];
    return YES;
    
}

#pragma mark - MCSwipeTableViewCellDelegate

- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    [UIView animateWithDuration:0.25f animations:^{
        searchView.alpha = 0.0f;
        
        UITableView *table = self.currentState == RCSwipeViewControllerStateSearching ? _searchTableView : theTableView;
        for (MCSwipeTableViewCell *cell_ in table.visibleCells) {
            if (cell_ != cell) {
                cell_.contentView.alpha = 0.2f;
            }
            
        }
        
    }];
}

- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    [UIView animateWithDuration:0.4f animations:^{
        searchView.alpha = 1.0f;
        
        UITableView *table = self.currentState == RCSwipeViewControllerStateSearching ? _searchTableView : theTableView;
        for (MCSwipeTableViewCell *cell_ in table.visibleCells) {
            cell_.contentView.alpha = 1.0f;
        }
        
    }];
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didChangeState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    cell.contentView.backgroundColor = COLOR_TABLE_CELL;
    
    NSIndexPath *indexPath;
    Contact *addressBook;
    
    if ([_filteredContactListFirstName count] || [_filteredContactListLastName count] || [_filteredContactListTags count]) {
        
        indexPath = [_searchTableView indexPathForCell:cell];
        
        if (indexPath.section == 0) {
            addressBook = (Contact *)[_filteredContactListFirstName objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 1) {
            addressBook = (Contact *)[_filteredContactListLastName objectAtIndex:indexPath.row];
        }
        else {
            addressBook = (Contact *)[[_filteredContactListTags objectAtIndex:indexPath.section - 2] objectAtIndex:indexPath.row];
        }
        
    } else {
        
        indexPath = [theTableView indexPathForCell:cell];
        addressBook = (Contact *)[[[self contacts] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
    }
    
    NSString *mainString;
    NSString *accessoryImage;
    
    switch (state) {
        case MCSwipeTableViewCellStateNone:
        {
            // No header view
            // Should default to regular title
            break;
        }
        case MCSwipeTableViewCellState1: // Text
        {
            
            if ([addressBook.mobile length]) {
                mainString = addressBook.mobile;
            } else {
                mainString = NSLocalizedString(@"No number found", nil);
            }
            accessoryImage = @"phone.png";
            
            break;
        }
        case MCSwipeTableViewCellState3: // Email
        {
            
            if ([addressBook.email length]) {
                mainString = addressBook.email;
            } else {
                mainString = NSLocalizedString(@"No email found", nil);
            }
            accessoryImage = @"email.png";
            
            break;
        }
        case MCSwipeTableViewCellState2: // Call
        {
            
            if ([addressBook.mobile length]) {
                mainString = addressBook.mobile;
            } else if ([addressBook.home length]) {
                mainString = addressBook.home;
            } else {
                mainString = NSLocalizedString(@"No number found", nil);
            }
            
            break;
        }
        case MCSwipeTableViewCellState4: // Reminder
        {
            
            mainString = NSLocalizedString(@"Set reminder", nil);
            
            break;
        }
        default:
            break;
    }

    cell.phoneLabel.text = mainString;

}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    [self.view endEditing:YES];

    UITableView *table; // weak ref
    
    // Determine the table
    if ([_filteredContactListFirstName count] || [_filteredContactListLastName count] || [_filteredContactListTags count]) {
        table = _searchTableView;
    } else {
        table = theTableView;
    }
    
    NSIndexPath *path = [table indexPathForCell:cell];
    
    cell.state = MCSwipeTableViewCellStateNone;
    [self updateCell:cell table:table atIndexPath:path];
    
    Contact *contact;
    if (table == _searchTableView) {
        
        if (path.section == 0) {
            contact = (Contact *)[_filteredContactListFirstName objectAtIndex:path.row];
        }
        else if (path.section == 1) {
            contact = (Contact *)[_filteredContactListLastName objectAtIndex:path.row];
        }
        else {
            contact = (Contact *)[[_filteredContactListTags objectAtIndex:path.section - 2] objectAtIndex:path.row];
        }
        
    } else {
        
        contact = (Contact *)[[[self contacts] objectAtIndex:path.section] objectAtIndex:path.row];
        
    }
    
    BOOL hasMobilePhone =   [contact.mobile length] ? YES : NO;
    BOOL hasEmail =         [contact.email length]  ? YES : NO;
    BOOL hasHomePhone =     [contact.home length]   ? YES : NO;
    
    if (state == MCSwipeTableViewCellState1) {
        // TEXT
        
        if (hasMobilePhone) {
            
            [self text:contact.mobile];
            
        } else {
            // No phone
            
            [MNMToast showWithText:@"No mobile number" autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
            
        }
        
    } else if (state == MCSwipeTableViewCellState3) {
        // EMAIL
        
        if (hasEmail) {
            
            [self email:contact.email];
            
        } else {
            // No email
            
            [MNMToast showWithText:NSLocalizedString(@"No email address", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];

        }
        
    } else if (state == MCSwipeTableViewCellState2) {
        // HOME
        
        if (hasHomePhone) {
            
            [self call:contact.home];
            
        } else if (hasMobilePhone) {
            
            [self call:contact.mobile];
            
        } else {
            // No number to call
            
            [MNMToast showWithText:NSLocalizedString(@"No phone number", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
            
        }
        
    } else if (state == MCSwipeTableViewCellState4) {
        // REMINDER
        
        [self remind:contact];
        
    }
    
}

#pragma mark - Table view data source

/****
 **** Data source
 ****
 
 *** New Contact
 ***    Section 0:
 ***        Row 0: Name & image
 ***        Row 1: Phone
 ***        Row 2: Email
 ***        Row 3: Tag
 ***        Row 4: Notes
 ***
 
 ** Search
 **     Section 0:
 **         First name matches
 **     Section 1:
 **         Last name matches
 **     Section 2:
 **         Tag matches
 **
 
 * Contacts
 *      Section is organized by first letter
 *
 
 */

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (tableView == _searchTableView) {
        return 2 + [_filteredContactListTags count];
    }
    
    return [RCContactManager shared].accessRevoked ? 1 : [[self contacts] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([RCContactManager shared].accessRevoked && tableView == theTableView) return 0;
    
	if (tableView == _searchTableView) {
        if (section == 0) {
            return [_filteredContactListFirstName count];
        }
        if (section == 1) {
            return [_filteredContactListLastName count];
        }
        return [_filteredContactListTags[section - 2] count];
    }
    
    return [[[self contacts] objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _addContactTableViewController.tableView) {
        if (indexPath.row == 0) {
            return 70.0f;
        }
        return 44.0f;
    }
    
    return kCellHeightDefault;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == _addContactTableViewController.tableView) {
        return nil;
    }
    
    if ([RCContactManager shared].accessRevoked && tableView == theTableView) {
        
        UIView *v = [[UIView alloc] initWithFrame:theTableView.frame];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 82, CGRectGetWidth(theTableView.frame)-60, 60)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:23];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = COLOR_DEFAULT_RED;
        titleLabel.text = NSLocalizedString(@"Access to Contacts has been Denied :(", @"");
        [v addSubview:titleLabel];
        
        UIImageView *privacyImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 42, 320, 240)];
        privacyImage.image = [UIImage imageNamed:@"privacy-warning"];
        [v addSubview:privacyImage];
        
        return v;
        
    }
    
    if (tableView == _searchTableView && section == 0 && [_filteredContactListFirstName count] == 0) return nil;
    if (tableView == _searchTableView && section == 1 && [_filteredContactListLastName count] == 0) return nil;
    if (tableView == _searchTableView && section == 2 && [_filteredContactListTags count] == 0) return nil;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 34.0f)];
    
    if (tableView == _searchTableView && section >= 2) {
        // Tags
        
        backgroundView.backgroundColor = COLOR_TABLE_CELL;

        RCTagView *tag = [[RCTagView alloc] initWithTagText:[_filteredContactListTagNames objectAtIndex:section - 2]];
        tag.frame = CGRectMake(13, 5, CGRectGetWidth(tag.frame), CGRectGetHeight(tag.frame));
        [backgroundView addSubview:tag];
        return backgroundView;
    }
    
    // Other sections
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = _listType == RCContactTypeLinkenIn ? COLOR_LINKEDIN_BLUE : COLOR_DEFAULT_RED;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.layer.cornerRadius = 12.0f;
    titleLabel.clipsToBounds = YES;
    
    CGRect titleLabelFrame = CGRectMake(13, 5, 24, 24);
    
    if (tableView == _searchTableView) {
        
        titleLabel.text = section == 0 ? NSLocalizedString(@"First name", nil) : NSLocalizedString(@"Last name", nil);
        
        titleLabelFrame.size.width = [titleLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(_searchTableView.frame), CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                attributes:[NSDictionary dictionaryWithObjectsAndKeys:titleLabel.font,NSFontAttributeName, nil]context:nil].size.width + 24;
        
        backgroundView.backgroundColor = COLOR_TABLE_CELL;
        
    } else {
        
        titleLabel.text = [[[self contacts] objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
        
        backgroundView.backgroundColor = [UIColor clearColor];
        
    }
    
    titleLabel.frame = titleLabelFrame;
    
    [backgroundView addSubview:titleLabel];
    
    return backgroundView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (tableView == _addContactTableViewController.tableView) {
        return 0.0f;
    }
    
    if (tableView == _searchTableView) {
        if (section == 0 && [_filteredContactListFirstName count] == 0) return 0;
        if (section == 1 && [_filteredContactListLastName count] == 0) return 0;
        if (section == 2 && [_filteredContactListTags count] == 0) return 0;
        
        return headerHeight;
    }
    
    if ([RCContactManager shared].accessRevoked) {
        return theTableView.frame.size.height;
    }
    
    return [[[self contacts] objectAtIndex:section] count] ? headerHeight : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (tableView == _searchTableView && section == 1 + [_filteredContactListTags count]) {
        return [[UIView alloc] init];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (tableView == _searchTableView && section == 1 + [_filteredContactListTags count]) {
        return 0.2f;
    }
    
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = COLOR_TABLE_CELL;
    cell.contentView.backgroundColor = COLOR_TABLE_CELL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // For the delegate callback
        [cell setDelegate:self];
        
        // Default background color
        cell.defaultCellBackgroundColor = COLOR_TABLE_CELL;
        
        cell.mainLabel.backgroundColor = COLOR_TABLE_CELL;
    }

    // Setting the type of the cell
    [cell setMode:MCSwipeTableViewCellModeSwitch];
	
    // Update cell content
    [self updateCell:cell table:tableView atIndexPath:indexPath];
    
	return cell;
}

- (void)updateCell:(MCSwipeTableViewCell *)cell table:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    
    Contact *addressBook;
    if (tableView == _searchTableView) {
        if (indexPath.section == 0) {
            addressBook = (Contact *)[_filteredContactListFirstName objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 1) {
            addressBook = (Contact *)[_filteredContactListLastName objectAtIndex:indexPath.row];
        }
        else {
            addressBook = (Contact *)[[_filteredContactListTags objectAtIndex:indexPath.section - 2] objectAtIndex:indexPath.row];
        }
    } else {
        addressBook = (Contact *)[[[self contacts] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
    }
    
    //
    // Set images and background color based on contact info available
    //
    
    // Prof pic
    if (addressBook.thumbnail) {
        cell.iconImageView.image = addressBook.thumbnail;
    }
    else {
        
        // LinkedIn
        if (_listType == RCContactTypeLinkenIn) {
            
            LinkedInContact *contact = (LinkedInContact *)addressBook;
            [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:contact.profilePicURL]
                                  placeholderImage:[[UIImage imageNamed:@"user-blank.png"] imageWithTintColor:COLOR_LINKEDIN_BLUE]];
        }
        
        // Contact
        else {
            
            if (addressBook.temporaryImagePlaceholder) {
                cell.iconImageView.image = addressBook.temporaryImagePlaceholder;
            } else {
                [cell.iconImageView setImageWithString:addressBook.fullName color:[UIColor colorWithWhite:0.78f alpha:1.0f] circular:YES];
                addressBook.temporaryImagePlaceholder = cell.iconImageView.image;
            }
            
        }
        
    }
    
    // We need to provide the icon names and the desired colors
    BOOL hasMobilePhone =   [addressBook.mobile length] ? YES : NO;
    BOOL hasEmail =         [addressBook.email length] ? YES : NO;
    BOOL hasHomePhone =     [addressBook.home length] ? YES : NO;
    
    NSString *fourthImage = nil;
    if (hasMobilePhone) {
        if (hasHomePhone) {
            fourthImage = @"phone-home-active.png";
        } else {
            fourthImage = @"phone-home-inactive.png";
        }
    } else if (hasHomePhone) {
        fourthImage = @"phone-home-inactive.png";
    }
    
    [cell setFirstStateIconName:hasMobilePhone ? @"text-active.png" : @"text-inactive.png"
                     firstColor:[COLOR_TEXT_BLUE colorWithAlphaComponent:hasMobilePhone ? 1.0f : 0.2f]
            secondStateIconName:hasMobilePhone || hasHomePhone ? @"phone-home-active.png" : @"phone-home-inactive.png"
                    secondColor:[COLOR_CALL_GREEN colorWithAlphaComponent:hasMobilePhone || hasHomePhone ? 1.0f : 0.2f]
                  thirdIconName:hasEmail ? @"email-active.png" : @"email-inactive.png"
                     thirdColor:[COLOR_EMAIL_RED colorWithAlphaComponent:hasEmail ? 1.0f : 0.2f]
                 fourthIconName:@"remind-active.png"
                    fourthColor:COLOR_REMIND_YELLOW];
    
    //
    // Set the label depending on the swipe mode
    //
    
    if ([[addressBook.fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        cell.mainLabel.text = addressBook.fullName;
        cell.mainLabel.font = CELL_TEXT_FONT_DEFAULT;
    } else {
        cell.mainLabel.font = CELL_TEXT_FONT_DISABLED;
        cell.mainLabel.text = NSLocalizedString(@"No Name", nil);
    }
    
    cell.panGestureRecognizer.enabled = _listType == RCContactTypeLinkenIn ? NO : YES;
    
    cell.textLabel.backgroundColor = COLOR_TABLE_CELL;
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (tableView == _addContactTableViewController.tableView) {
        return;
    }
    
    [self.view endEditing:YES];
    
    Contact *addressBook;
    
    if ([_filteredContactListFirstName count] || [_filteredContactListLastName count] || [_filteredContactListTags count]) {
        if (indexPath.section == 0) {
            addressBook = (Contact *)[_filteredContactListFirstName objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 1) {
            addressBook = (Contact *)[_filteredContactListLastName objectAtIndex:indexPath.row];
        }
        else {
            addressBook = (Contact *)[[_filteredContactListTags objectAtIndex:indexPath.section - 2] objectAtIndex:indexPath.row];
        }
    } else {
        addressBook = (Contact *)[[[self contacts] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    if (addressBook) {
        [self showContactDetails:addressBook];
    }
    
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    /*
     * Scroll main table to show search view
     */
    
    if (scrollView == theTableView && scrollView.isTracking && scrollView.contentOffset.y < 0 && _currentState == RCSwipeViewControllerStateNormal) {
        
        // Start pulling down the search view
        
        searchHeaderView.alpha = 1.0f;
                
        CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
        CGFloat heightOfSearchView = CGRectGetHeight(searchHeaderView.frame);
        CGFloat maximumSearchMovement = TOP_BAR_HEIGHT + statusBarHeight + heightOfSearchView;
        
        CGFloat yOriginSearchView = -scrollView.contentOffset.y - maximumSearchMovement;
        [searchHeaderView setFrameOriginY:yOriginSearchView];

        if (yOriginSearchView > 0) {
            yOriginSearchView = 0;
            [self showSearchViewAnimated:NO];
            [searchTextField becomeFirstResponder];
        }
        
        CGFloat yOriginNavBar = statusBarHeight + statusBarHeight + scrollView.contentOffset.y + TOP_BAR_HEIGHT;
        if (yOriginNavBar > statusBarHeight) { yOriginNavBar = statusBarHeight; }
        
        [self.navigationController.navigationBar setFrameOriginY:yOriginNavBar];
        
    }
    
    /*
     * Scrolling on search view
     */
    
    else if (scrollView == _searchTableView && self.currentState == RCSwipeViewControllerStateSearching) {
        
        // Get the distance the view has dragged
        // Make damn sure that shit is positive, yo.
        CGFloat scrollDistance = scrollView.contentOffset.y + TOP_BAR_HEIGHT + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);

        // Figure out the opacity of that search background
        CGFloat opacity;
        
        NSInteger footerIndex = scrollView == _searchTableView ? 1 + [_filteredContactListTags count] : 0;
        CGFloat thresholdToRelease = [_searchTableView rectForFooterInSection:footerIndex].origin.y - [scrollView bounds].size.height + scrollView.contentInset.top + scrollView.contentInset.bottom;
        CGFloat thresholdToLoad = thresholdToRelease + SCROLL_DRAG_DISTANCE;

        if (scrollDistance < 1) {
            // Scrolling up (dragging finger down)
            if (scrollDistance < -SCROLL_DRAG_DISTANCE) {
                opacity = 0.0f;
            } else {
                opacity = SEARCH_BACKGROUND_OPACITY - ((SEARCH_BACKGROUND_OPACITY / SCROLL_DRAG_DISTANCE) * -scrollDistance);
            }
            
            if (scrollDistance > 0) {
                scrollDistance = scrollDistance * -1;
            }
            
            if (scrollView == _searchTableView) {
                CGRect headerFrame = searchHeaderView.frame;
                headerFrame.origin.y = scrollDistance / 1.75;
                searchHeaderView.frame = headerFrame;
            }
            
        } else if (scrollDistance > 1) {
            // Scrolling down (dragging finger up)
            if (thresholdToRelease < 0) {
                // Use determined distance
                
                if (scrollDistance < 0) {
                    opacity = SEARCH_BACKGROUND_OPACITY;
                } else {
                    opacity = SEARCH_BACKGROUND_OPACITY - ((SEARCH_BACKGROUND_OPACITY / SCROLL_DRAG_DISTANCE) * scrollDistance);
                }
            } else if (scrollDistance > thresholdToLoad) {
                opacity = 0.0f;
            } else {
                opacity = SEARCH_BACKGROUND_OPACITY - ((SEARCH_BACKGROUND_OPACITY / SCROLL_DRAG_DISTANCE) * (scrollDistance - thresholdToRelease));
            }
            
        } else {
            opacity = SEARCH_BACKGROUND_OPACITY;

        }
        
        if (opacity > SEARCH_BACKGROUND_OPACITY) {
            opacity = SEARCH_BACKGROUND_OPACITY;
        }
        
        if (opacity < 0.02f) {
            opacity = 0.02f;
            
            // Trying this out... Let's hide it when it reaches this point
            // Hide automatically rather than when user releases
            if (scrollView.tracking) {
                [self hideSearchViewAnimated:YES dismissDownward:scrollDistance > 1 ? NO : YES];
            }
            
        }
        
        scrollView.alpha = opacity / SEARCH_BACKGROUND_OPACITY;
        
        if (scrollView == _searchTableView) {
            searchHeaderView.alpha = opacity / SEARCH_BACKGROUND_OPACITY;
        }
        
    }
        
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView == _searchTableView) {
        [self.view endEditing:YES];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView == theTableView && _currentState == RCSwipeViewControllerStateNormal) {
        
        // Reset
        
        CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
        if (CGRectGetMinY(self.navigationController.navigationBar.frame) < statusBarHeight) {
            [UIView animateWithDuration:0.27 animations:^{
                
                searchHeaderView.alpha = 1.0f;
                
                CGFloat heightOfSearchView = CGRectGetHeight(searchHeaderView.frame);
                [searchHeaderView setFrameOriginY:-heightOfSearchView];
                
                [self.navigationController.navigationBar setFrameOriginY:statusBarHeight];
            
            }];
        }
        
    }
    else if (scrollView == _searchTableView) {
        
        CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;
        
        if (offset > 1) {
            
            CGFloat thresholdToRelease = [_searchTableView rectForFooterInSection:1 + [_filteredContactListTags count]].origin.y - [scrollView bounds].size.height + _searchTableView.contentInset.top + _searchTableView.contentInset.bottom;
            CGFloat thresholdToLoad = thresholdToRelease + SCROLL_DRAG_DISTANCE;
            
            if (thresholdToRelease < 0) {
                // Use determined distance
                if (offset > SCROLL_DRAG_DISTANCE) {
                    [self hideSearchViewAnimated:YES dismissDownward:NO];
                }
                
            } else if (offset > thresholdToLoad) {
                [self hideSearchViewAnimated:YES dismissDownward:NO];
            }
            
        } else if (offset < 0 && offset < -SCROLL_DRAG_DISTANCE) {
            [self hideSearchViewAnimated:YES dismissDownward:YES];
        }
        
    }
    
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case kTagActionSheetMergeOptions:
        {
            
            if (buttonIndex == 0) {
                
                [[LinkedInManager shared] revokeAuthorization];
                
                // Reset to contact list
                _listType = RCContactTypePhoneContact;
                [self configureView];
                
                [self presentListSelector];
                
                [MNMToast showWithText:NSLocalizedString(@"LinkedIn account successfully removed", nil) autoHidding:YES priority:MNMToastPriorityHigh completionHandler:nil tapHandler:nil];
                
            }
            
            break;
        }
        case kTagActionSheetCancelContact:
        {
            // 0 is close, 1 is to dismiss without action
            
            if (buttonIndex == 0) {
                [_addContactTableViewController clearData];
                [self hideNewContactViewAnimated:YES];
            }
            
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Keyboard listening

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /**
    NSDictionary *options = [notification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    keyboardEndFrame = [[options objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:self.view.window];
     */
    
    [UIView animateWithDuration:0.2f animations:^{
        searchView.alpha = 0.0f;
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    /**
    NSDictionary *options = [notification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
     */
    
    [UIView animateWithDuration:0.2f animations:^{
        searchView.alpha = 1.0f;
    }];
    
}

#pragma mark - Bar button item actions

- (void)searchAction {
    [self showSearchViewAnimated:YES];
    [searchTextField becomeFirstResponder];
}

- (void)showMergeOptions {
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unlink Account" otherButtonTitles: nil];
    ac.destructiveButtonIndex = 0;
    ac.tag = kTagActionSheetMergeOptions;
    [ac showInView:self.view];
}

- (void)presentListSelector {
    
    RCListSelectorTableViewController *settings = [[RCListSelectorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settings.delegate = self;
    settings.selectedType = _listType;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
    nav.navigationBar.translucent = YES;
    nav.navigationBar.barStyle = UIBarStyleBlack;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
    
}

- (void)showRemindersList {
    
    RCRemindListTableViewController *list = [[RCRemindListTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:list];
    
    [self presentViewController:navController animated:YES completion:nil];
    
}

#pragma mark - Top Button Secondary Actions

- (void)didTapSearchButton {
    [self searchForTerm:@""];
    [searchTextField becomeFirstResponder];
}

- (void)didTapSearchCloseButton {
    [self hideSearchViewAnimated:YES dismissDownward:YES];
}

#pragma mark - Communication Dawg

- (void)text:(NSString *)number {
    
    [RCExternalRequestHandler text:[number unformattedPhoneString] delegate:self presentationHandler:nil completionHandler:nil];
    
}

- (void)call:(NSString *)number {
    
    [RCExternalRequestHandler call:[number unformattedPhoneString] completionHandler:nil];

}

- (void)email:(NSString *)address {
    
    [RCExternalRequestHandler email:address delegate:self presentationHandler:nil completionHandler:nil];
    
}

- (void)remind:(Contact *)contact {
    
    [RCExternalRequestHandler remind:contact delegate:self presentationHandler:nil completionHandler:nil];
    
}

#pragma mark - Contact Detail

#pragma mark Viewing

- (void)showContactDetails:(Contact *)contact {
    
    switch (contact.type) {
        case RCContactTypeLinkenIn:
        {
            
            RCSocialDetailViewController *controller = [[RCSocialDetailViewController alloc] initWithContact:contact];
            [self.navigationController pushViewController:controller animated:YES];
            
            break;
        }
        default:
        {
            if (_contactDetailViewController == nil) {
                _contactDetailViewController = [[RCContactDetailViewController alloc] initWithNibName:nil bundle:nil];
                _contactDetailViewController.delegate = self;
            }
            
            shouldHideNavBarOnPush = YES;
            
            [_contactDetailViewController configureViewForContact:contact];
            [self.navigationController pushViewController:_contactDetailViewController animated:YES];
            
            break;
        }
        
    }
    
}

#pragma mark Delegate

- (void)contactDetailViewControllerDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Communication Delegates

#pragma mark Text
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MessageComposeResultFailed: {
            
            break;
        }
        case MessageComposeResultSent: {
            
            break;
        }
        default:
            break;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

#pragma mark Email
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MFMailComposeResultSaved: {
            
            break;
        }
        case MFMailComposeResultFailed: {
            
            break;
        }
        case MFMailComposeResultSent: {
            
            break;
        }
        default:
            break;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

#pragma mark Reminder
- (void)reminderView:(RCReminderViewController *)controller didSetReminderForContact:(Contact *)contact {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reminderViewDidCancel:(RCReminderViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - List Selector

- (void)listSelectorDidChooseType:(RCContactType)type {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (type == _listType) return;
    
    _listType = type;
    
    [self configureView];
    
}

#pragma mark - Showing Phone/Texting Views for Navbar Swipe

- (void)showPhoneDialerWithCompletion:(void (^)(void))completion {
    RCPhoneController *controller = [[RCPhoneController alloc] init];
    [self presentViewController:controller animated:YES completion:completion];
}

- (void)showTextComposerWithCompletion:(void (^)(void))completion {
    if ([MFMessageComposeViewControllerTextMessageAvailabilityKey boolValue]) {
        MFMessageComposeViewController *composer = [[MFMessageComposeViewController alloc] init];
        composer.messageComposeDelegate = self;
        [self presentViewController:composer animated:YES completion:completion];
    } else {
        // Can't send texts :(
        [MNMToast showWithText:NSLocalizedString(@"Texting not available on this device :(", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
    }
}

- (void)showEmailComposerWithCompletion:(void (^)(void))completion {
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    composer.mailComposeDelegate = self;
    [self presentViewController:composer animated:YES completion:nil];
}

@end
