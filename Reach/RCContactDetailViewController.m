//
//  RCContactDetailViewController.m
//  Reach
//
//  Created by Tom Bachant on 7/7/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCContactDetailViewController.h"

#import "Definitions.h"
#import "AppDelegate.h"
#import "UIImageView+LBBlurredImage.h"
#import "RCSocialDetailViewController.h"
#import "LinkedInManager.h"

CGFloat const kMGOffsetEffects = 40.0;
CGFloat const kMGOffsetBlurEffect = 2.0;

#define BACKGROUND_COLOR_TRANSLUCENT [UIColor colorWithWhite:0.05f alpha:0.4f]
#define BACKGROUND_WHITE_TRANSLUCENT [UIColor colorWithWhite:0.88f alpha:0.2f]

#define TAG_BUTTON_OFFSET 10

#define TAG_ACTION_EDIT 20
#define TAG_ACTION_PHOTO 21

#define TAG_ALERT_DELETE 30

typedef enum {
    RCContactSectionPhone = 0,
    RCContactSectionEmail,
    RCContactSectionTags,
    RCContactSectionLinkedIn,
    RCContactSectionNotes,
    RCContactSectionMeta
} RCContactSection;

static const CGFloat kUserImageHeight = 92.0f;
static const CGFloat kHeaderHeight = kUserImageHeight + 156.0f;

static const CGFloat kButtonWidth = 54.0f;
static const CGFloat kButtonPadding = 9.0f;

static const CGFloat kMainLabelHeight = kButtonWidth;
static const CGFloat kCellHeight = kButtonPadding + kButtonWidth + kButtonPadding;

static const CGFloat kNotesTextViewHeight = 142.0f;

@interface RCContactDetailViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIImagePickerController *imgPicker;

@property (nonatomic, strong) UIButton *remindButtonOverlay;

@property (nonatomic) BOOL shouldUpdateOnAppear;

@end

@implementation RCContactDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        
        self.view.backgroundColor = COLOR_TABLE_CELL;
        
        _contactHeaderBackgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight([[UIScreen mainScreen] bounds]))];
        _contactHeaderBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _contactHeaderBackgroundImage.clipsToBounds = YES;
        [self.view addSubview:_contactHeaderBackgroundImage];
        
        _contactHeaderView = [[UIView alloc] initWithFrame:_contactHeaderBackgroundImage.frame];
        _contactHeaderView.backgroundColor = [UIColor clearColor];
        //_contactHeaderView.layer.shadowOffset = CGSizeMake(0, 0);
        //_contactHeaderView.layer.shadowRadius = 1.5;
        //_contactHeaderView.layer.shadowOpacity = 0.3;
        
        _userImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(_contactHeaderView.frame) - (kUserImageHeight / 2), 50, kUserImageHeight, kUserImageHeight)];
        _userImage.layer.cornerRadius = CGRectGetWidth(_userImage.frame) / 2;
        _userImage.contentMode = UIViewContentModeScaleAspectFill;
        _userImage.clipsToBounds = YES;
        _userImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        _userImage.layer.borderWidth = 1.0f;
        [_contactHeaderView addSubview:_userImage];
        
        _userName = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_userImage.frame) + 9, CGRectGetWidth(frame) - 40, 34)];
        _userName.backgroundColor = [UIColor clearColor];
        _userName.font = [UIFont fontWithName:kBoldFontName size:22.0f];
        _userName.textColor = [UIColor whiteColor];
        _userName.textAlignment = NSTextAlignmentCenter;
        [_contactHeaderView addSubview:_userName];
        
        _remindButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(frame) - 58, CGRectGetMaxY(_userName.frame) + 7, 116, 26)];
        [_remindButton setImage:[[UIImage imageNamed:@"remind-small"] imageWithTintColor:COLOR_REMIND_YELLOW] forState:UIControlStateNormal];
        [_remindButton setTitle:NSLocalizedString(@"Set reminder", nil) forState:UIControlStateNormal];
        [_remindButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.000] forState:UIControlStateNormal];
        [_remindButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        [_remindButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 13)];
        _remindButton.tintColor = COLOR_REMIND_YELLOW;
        _remindButton.titleLabel.font = [UIFont fontWithName:kBoldFontName size:12.0f];
        [_remindButton addTarget:self action:@selector(remind:) forControlEvents:UIControlStateNormal];
        _remindButton.layer.cornerRadius = CGRectGetHeight(_remindButton.frame) / 2;
        _remindButton.layer.borderColor = [COLOR_REMIND_YELLOW CGColor];
        _remindButton.layer.borderWidth = 0.6f;
        [_contactHeaderView addSubview:_remindButton];
        
        [self.view addSubview:_contactHeaderView];
        
        // Tag view
        _tagField = [[JSTokenField alloc] initWithFrame:CGRectMake(37, 0 + 4, CGRectGetWidth(frame) - 44, 27)];
        _tagField.textField.font = [UIFont fontWithName:kLightFontName size:15.0f];
        _tagField.textField.placeholder = NSLocalizedString(@"Add tag...", nil);
        _tagField.textField.tintColor = COLOR_TAG_BLUE;
        _tagField.delegate = self;
        
        // Set up the main table view container
        _theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _theTableView.dataSource = self;
        _theTableView.delegate = self;
        _theTableView.backgroundColor = [UIColor clearColor];
        _theTableView.showsVerticalScrollIndicator = NO;
        _theTableView.contentInset = UIEdgeInsetsMake(kHeaderHeight - 64, 0, 0, 0);
        _theTableView.separatorColor = BACKGROUND_WHITE_TRANSLUCENT;
        [self.view addSubview:_theTableView];
        
        _remindButtonOverlay = [[UIButton alloc] initWithFrame:_remindButton.frame];
        [_remindButtonOverlay addTarget:self action:@selector(remind:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_remindButtonOverlay];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *barBut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit-icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(editContact)];
    self.navigationItem.rightBarButtonItem = barBut;
    
    // Formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    // Add semi-transparency below the table
    
    NSLog(@"Content size is: %f", _theTableView.contentSize.height);
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _theTableView.contentSize.height, CGRectGetWidth(_theTableView.frame), 400.0f)];
    footerView.backgroundColor = [UIColor colorWithWhite:0.05f alpha:0.4f];
    [_theTableView addSubview:footerView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if (_shouldUpdateOnAppear) {
        // Update in the event of an edit
        AppDelegate *deleg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        ABAddressBookRef addressBook = deleg.viewController.addressBook;
        
        ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, ABRecordGetRecordID(_contact.originAddressBookRef));
        _contact = [Contact contactFromAddressBook:record];
        [self configureViewForContact:_contact];
        
        [deleg.viewController getContacts];
        
        _shouldUpdateOnAppear = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    _contactHeaderView.transform = CGAffineTransformMakeScale(1.16, 1.16);
    
    _contactHeaderBackgroundImage.alpha = 0.0f;
    _contactHeaderView.alpha = 0.0f;
    
    CGRect tableFrame = _theTableView.frame;
    tableFrame.origin.y = CGRectGetWidth(self.view.frame);
    _theTableView.frame = tableFrame;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    [UIView animateWithDuration:animated ? 0.82 : 0 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:0  animations:^{
        
        _contactHeaderView.transform = CGAffineTransformMakeScale(0.97f, 0.97f);
        
        _contactHeaderBackgroundImage.alpha = 1.0f;
        _contactHeaderView.alpha = 1.0f;
        
        _theTableView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(tableFrame), CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetMaxY(self.navigationController.navigationBar.frame));
        
    } completion:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI Config

- (void)configureViewForContact:(Contact *)contct {
    _contact = contct;
    
    _userName.text = _contact.fullName;
    
    if (_contact.thumbnail) {
        _userImage.image = _contact.thumbnail;
    }
    else {
        [_userImage setImageWithString:_contact.fullName color:nil];
    }
        
    // Update the blur view
    CGFloat newBlur = kLBBlurredImageDefaultBlurRadius;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Blur effects
        [_contactHeaderBackgroundImage setImageToBlur:_userImage.image ? _userImage.image : [UIImage imageNamed:@"user-blank"]
                                           blurRadius:newBlur
                                            tintColor:_contact.thumbnail ? nil : [UIColor colorWithRed:0.400 green:0.469 blue:0.498 alpha:0.7]
                                      completionBlock:nil];
        
    });
    
    // Temporarily disable delegate
    _tagField.delegate = nil;
    
    [_tagField removeAllTokens];
    for (NSString *tag in _contact.tags) {
        [_tagField addTokenWithTitle:tag representedObject:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _tagField.delegate = self;
        
        [_theTableView reloadData];
        
        NSInteger minSection = RCContactSectionPhone;
        if (![_contact.phoneArray count]) {
            if ([_contact.emailArray count]) {
                minSection = RCContactSectionEmail;
            }
            else {
                minSection = RCContactSectionTags;
            }
        }
        [_theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:minSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        if (!_footerView) {
            _footerView = [UIView new];
            _footerView.backgroundColor = BACKGROUND_COLOR_TRANSLUCENT;
            [_theTableView addSubview:_footerView];
        }
        _footerView.frame = CGRectMake(0.0f, _theTableView.contentSize.height, CGRectGetWidth(_theTableView.frame), CGRectGetHeight([[UIScreen mainScreen] bounds]));
        
    });
    
}

#pragma mark - Show/hide

- (void)hide {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RCSwipeViewController *rootVC = delegate.viewController;
    [rootVC setNeedsStatusBarAppearanceUpdate];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         _theTableView.center = CGPointMake(self.view.center.x, self.view.center.y - 6);
                         
                     }
                     completion:^(BOOL finished){
                         
                         // Wait one second and then fade in the view
                         [UIView animateWithDuration:0.6
                                          animations:^{
                                              
                                              _theTableView.center = CGPointMake(_theTableView.center.x, CGRectGetHeight(_theTableView.frame) * 2);
                                              
                                              _contactHeaderView.alpha = 0.0f;
                                              _contactHeaderView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                              
                                          }
                                          completion:^(BOOL finished){
                                              // Finished.
                                              [self finishedHiding];
                                          }];
                     }];
    
}

- (void)hideDownward:(BOOL)shouldGoDownward {
    
    // Remove the delegate for the scrolling options we have in place
    _theTableView.delegate = nil;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RCSwipeViewController *rootVC = delegate.viewController;
    [rootVC setNeedsStatusBarAppearanceUpdate];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         _theTableView.center = CGPointMake(_theTableView.center.x, shouldGoDownward ? CGRectGetHeight(_theTableView.frame) * 2 : -CGRectGetHeight(_theTableView.frame));
                         
                         _contactHeaderView.alpha = 0.0f;
                         _contactHeaderView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         
                     }
                     completion:^(BOOL finished){
                         // Finished.
                         [self finishedHiding];
                     }];
    
}

- (void)finishedHiding {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_delegate contactDetailViewControllerDidCancel];
    
}

- (void)editContact {
    
    [self.view endEditing:YES];
    
    UIActionSheet *editActions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Set Contact Photo" otherButtonTitles:@"Edit Contact", @"Delete Contact", nil];
    editActions.destructiveButtonIndex = 2;
    editActions.tag = TAG_ACTION_EDIT;
    [editActions showInView:self.view];
    
}

#pragma mark - Actions

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
    
    [RCExternalRequestHandler remind:_contact delegate:self presentationHandler:nil completionHandler:nil];
    
}

#pragma mark Cell Actions

- (void)leftButtonTapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    NSInteger tag = button.tag;
    
    if (tag > 0) {
        // Call
        
        NSInteger index = tag - TAG_BUTTON_OFFSET;
        
        NSDictionary *phone = _contact.phoneArray[index];
        NSString *label = [phone allKeys][0];
        NSString *value = [phone objectForKey:label];
        [self call:value];
        
    }
    else if (tag < 0) {
        // Email
        
        NSInteger index = tag + TAG_BUTTON_OFFSET;
        
        [self email:_contact.emailArray[index]];
        
    }
    
}

- (void)rightButtonTapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    NSInteger tag = button.tag;
    
    if (tag > 0) {
        // Text
        
        NSInteger index = tag - TAG_BUTTON_OFFSET;
        
        NSDictionary *phone = _contact.phoneArray[index];
        NSString *label = [phone allKeys][0];
        NSString *value = [phone objectForKey:label];
        [self text:value];
        
    }
    else if (tag < 0) {
        // Email
        
        NSInteger index = (tag * -1) + TAG_BUTTON_OFFSET;
        
        [self email:_contact.emailArray[index]];
        
    }
}

#pragma mark - MCSwipeTableViewCellDelegate

- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    [UIView animateWithDuration:0.25f animations:^{
        
        RCContactDetailTableViewCell *detailCell = (RCContactDetailTableViewCell *)cell;
        detailCell.buttonLeft.alpha = 0.0f;
        detailCell.buttonRight.alpha = 0.0f;
        
    }];
}

- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    [UIView animateWithDuration:0.4f animations:^{
        
        RCContactDetailTableViewCell *detailCell = (RCContactDetailTableViewCell *)cell;
        
        NSIndexPath *path = [_theTableView indexPathForCell:detailCell];
        if (path.section == RCContactSectionPhone) {
            detailCell.buttonLeft.alpha = 1.0f;
            detailCell.buttonRight.alpha = 1.0f;
        }
        else if (path.section == RCContactSectionEmail ||
                 path.section == RCContactSectionLinkedIn) {
            detailCell.buttonLeft.alpha = 1.0f;
        }
        
    }];
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didChangeState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    /*
     Not implemented because we don't need the label on the swipe view
     The text in the cells already indicate the action
     */
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    [self.view endEditing:YES];

    BOOL hasMobilePhone =   [_contact.mobile length] ? YES : NO;
    BOOL hasEmail =         [_contact.email length]  ? YES : NO;
    BOOL hasHomePhone =     [_contact.home length]   ? YES : NO;
    
    if (state == MCSwipeTableViewCellState1) {
        // TEXT
        
        if (hasMobilePhone) {
            
            [self text:_contact.mobile];
            
        } else {
            // No phone
            
            [MNMToast showWithText:@"No mobile number" autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
            
        }
        
    } else if (state == MCSwipeTableViewCellState3) {
        // EMAIL
        
        if (hasEmail) {
            
            [self email:_contact.email];
            
        } else {
            // No email
            
            [MNMToast showWithText:NSLocalizedString(@"No email address", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
            
        }
        
    } else if (state == MCSwipeTableViewCellState2) {
        // HOME
        
        if (hasHomePhone) {
            
            [self call:_contact.home];
            
        } else if (hasMobilePhone) {
            
            [self call:_contact.mobile];
            
        } else {
            // No number to call
            
            [MNMToast showWithText:NSLocalizedString(@"No phone number", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
            
        }
        
    } else if (state == MCSwipeTableViewCellState4) {
        // REMINDER
        
        [self remind:_contact];
        
    }
    
}

#pragma mark - Table view data source

/******
 * Section 0
 *      Phone
 *
 * Section 1:
 *      Emails
 *
 * Section 2:
 *      LinkedIn
 *
 * Section 3:
 *      Tags
 *
 * Section 4:
 *      Notes
 *
 * Section 5:
 *      Meta
 *
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case RCContactSectionPhone:
            return [_contact.phoneArray count];
            
            break;
        case RCContactSectionEmail:
            return [_contact.emailArray count];
            
            break;
        case RCContactSectionLinkedIn:
            return [_contact.linkedInId length] ? 1 : 0;
            
            break;
        case RCContactSectionTags:
            return 1;
            
            break;
        case RCContactSectionNotes:
            return 1;
            
            break;
        case RCContactSectionMeta:
            return 1;
            
            break;
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == RCContactSectionNotes) {
        return kNotesTextViewHeight;
    }
    if (indexPath.section == RCContactSectionEmail ||
        indexPath.section == RCContactSectionLinkedIn) {
        return kMainLabelHeight;
    }
    return kCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == RCContactSectionMeta) {
        return [[UIView alloc] init];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == RCContactSectionMeta) {
        return 0.4;
    }
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = BACKGROUND_COLOR_TRANSLUCENT;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:0.05f alpha:0.2f];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = BACKGROUND_COLOR_TRANSLUCENT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"CellID";
    static NSString *TagCellID = @"TagCellID";
    
    if (indexPath.section == RCContactSectionTags) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TagCellID];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TagCellID];
            
            UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 12, 200, 18)];
            secondaryLabel.backgroundColor = [UIColor clearColor];
            secondaryLabel.font = [UIFont fontWithName:kBoldFontName size:13.0f];
            secondaryLabel.textColor = [UIColor whiteColor];
            secondaryLabel.textAlignment = NSTextAlignmentLeft;
            secondaryLabel.text = NSLocalizedString(@"Tags", nil);
            [cell.contentView addSubview:secondaryLabel];
            
            UIImageView *tagImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 35, 22, 22)];
            tagImage.image = [[UIImage imageNamed:@"tag-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
            [cell.contentView addSubview:tagImage];
            
            [_tagField setFrameOriginY:CGRectGetMaxY(secondaryLabel.frame) + 4];
            [cell.contentView addSubview:_tagField];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }
    
    RCContactDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[RCContactDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        
        cell.defaultCellBackgroundColor = [UIColor clearColor];
        
        cell.buttonRight.layer.cornerRadius = kButtonWidth / 2;
        cell.buttonRight.clipsToBounds = YES;
        cell.buttonRight.layer.borderColor = [BACKGROUND_WHITE_TRANSLUCENT CGColor];
        cell.buttonRight.layer.borderWidth = 1.0f;
        [cell.buttonRight addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.buttonLeft.layer.cornerRadius = kButtonWidth / 2;
        cell.buttonLeft.clipsToBounds = YES;
        [cell.buttonLeft addTarget:self action:@selector(leftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.mainLabel.frame = CGRectMake(12, 18, 200, 27);
        cell.mainLabel.backgroundColor = [UIColor clearColor];
        cell.mainLabel.font = [UIFont fontWithName:kFontName size:20.0f];
        cell.mainLabel.textColor = [UIColor blackColor];
        cell.mainLabel.textAlignment = NSTextAlignmentLeft;
        cell.mainLabel.adjustsFontSizeToFitWidth = YES;
        cell.mainLabel.minimumScaleFactor = 14.0f/21.0f;
        
        cell.notesTextView.delegate = self;
        cell.notesTextView.textColor = [UIColor whiteColor];
        cell.notesTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
        case RCContactSectionPhone:
        {
            NSDictionary *phone = _contact.phoneArray[indexPath.row];
            NSString *label = [phone allKeys][0];
            NSString *value = [phone objectForKey:label];
            
            cell.secondaryLabel.frame = CGRectMake(13, 12, CGRectGetWidth(cell.mainLabel.frame), 18);
            cell.secondaryLabel.text = label;
            
            cell.mainLabel.frame = CGRectMake(13, CGRectGetMaxY(cell.secondaryLabel.frame) + 1, CGRectGetWidth(_theTableView.frame) - 34, 27);
            cell.mainLabel.text = value;
            cell.mainLabel.font = [UIFont fontWithName:kFontName size:20.0f];
            cell.mainLabel.alpha = 1.0f;
            
            cell.buttonRight.frame = CGRectMake(CGRectGetWidth(_theTableView.frame) - kButtonWidth - kButtonPadding, kButtonPadding, kButtonWidth, kButtonWidth);
            cell.buttonRight.alpha = 1.0f;
            [cell.buttonRight setImage:[UIImage imageNamed:@"text-active"] forState:UIControlStateNormal];
            [cell.buttonRight setTintColor:COLOR_TEXT_BLUE];
            cell.buttonRight.tag = indexPath.row + TAG_BUTTON_OFFSET;
            
            cell.buttonLeft.frame = CGRectMake(CGRectGetWidth(_theTableView.frame) - (kButtonWidth * 2) - (kButtonPadding * 2), CGRectGetMinY(cell.buttonRight.frame), kButtonWidth, kButtonWidth);
            cell.buttonLeft.alpha = 1.0f;
            [cell.buttonLeft setImage:[UIImage imageNamed:@"phone-home-active"] forState:UIControlStateNormal];
            [cell.buttonLeft setTintColor:COLOR_CALL_GREEN];
            cell.buttonLeft.tag = indexPath.row + TAG_BUTTON_OFFSET;
            cell.buttonLeft.userInteractionEnabled = YES;
            
            cell.notesTextView.hidden = YES;
            
            [cell setFirstColor:COLOR_TEXT_BLUE];
            [cell setFirstIconName:@"text-active"];
            
            [cell setSecondColor:COLOR_CALL_GREEN];
            [cell setSecondIconName:@"phone-home-active"];
            
            [cell setThirdColor:nil];
            [cell setThirdIconName:nil];
            
            [cell setFourthColor:nil];
            [cell setFourthColor:nil];
            
            cell.delegate = self;
            cell.panGestureRecognizer.enabled = YES;
            
            break;
        }
        case RCContactSectionEmail:
        {
            NSString *email = _contact.emailArray[indexPath.row];
            
            cell.mainLabel.frame = CGRectMake(kButtonWidth, 0, CGRectGetWidth(_theTableView.frame) - kButtonWidth - (kButtonPadding * 2), kMainLabelHeight);
            cell.mainLabel.text = email;
            cell.mainLabel.font = [UIFont fontWithName:kFontName size:16.0f];
            cell.mainLabel.alpha = 1.0f;
            
            cell.secondaryLabel.text = nil;
            
            cell.buttonRight.alpha = 0.0f;
            
            cell.buttonLeft.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
            cell.buttonLeft.alpha = 1.0f;
            [cell.buttonLeft setImage:[UIImage imageNamed:@"email-active"] forState:UIControlStateNormal];
            [cell.buttonLeft setTintColor:COLOR_EMAIL_RED];
            cell.buttonLeft.tag = -indexPath.row - TAG_BUTTON_OFFSET;
            cell.buttonLeft.userInteractionEnabled = YES;
            
            cell.notesTextView.hidden = YES;
            
            [cell setFirstColor:nil];
            [cell setFirstIconName:nil];
            
            [cell setSecondColor:nil];
            [cell setSecondIconName:nil];
            
            [cell setThirdColor:COLOR_EMAIL_RED];
            [cell setThirdIconName:@"email-active"];
            
            [cell setFourthColor:COLOR_EMAIL_RED];
            [cell setThirdIconName:@"email-active"];
            
            cell.delegate = self;
            cell.panGestureRecognizer.enabled = YES;
            
            break;
        }
        case RCContactSectionLinkedIn:
        {
            cell.mainLabel.frame = CGRectMake(kButtonWidth, 0, CGRectGetWidth(_theTableView.frame) - kButtonWidth - (kButtonPadding * 2), kMainLabelHeight);
            cell.mainLabel.text = [NSString stringWithFormat:@"linkedin.com/in/%@", _contact.linkedInId];
            cell.mainLabel.font = [UIFont fontWithName:kBoldFontName size:16.0f];
            cell.mainLabel.alpha = 1.0f;
            
            cell.secondaryLabel.text = nil;
            
            cell.buttonRight.alpha = 0.0f;
            
            cell.buttonLeft.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
            cell.buttonLeft.alpha = 1.0f;
            [cell.buttonLeft setImage:[UIImage imageNamed:@"linkedin-active"] forState:UIControlStateNormal];
            [cell.buttonLeft setTintColor:COLOR_LINKEDIN_BLUE];
            cell.buttonLeft.userInteractionEnabled = NO;
            
            cell.notesTextView.hidden = YES;
            
            [cell setFirstColor:nil];
            [cell setFirstIconName:nil];
            
            [cell setSecondColor:nil];
            [cell setSecondIconName:nil];
            
            [cell setThirdColor:nil];
            [cell setThirdIconName:nil];
            
            [cell setFourthColor:nil];
            [cell setThirdIconName:nil];
            
            cell.delegate = nil;
            cell.panGestureRecognizer.enabled = NO;

            break;
        }
        case RCContactSectionTags:
        {
            
            cell.delegate = nil;
            
            break;
        }
        case RCContactSectionNotes:
        {
            
            cell.secondaryLabel.frame = CGRectMake(13, 12, CGRectGetWidth(cell.mainLabel.frame), 18);
            cell.secondaryLabel.text = @"Notes";
            
            cell.buttonLeft.alpha = 0.0f;
            cell.buttonRight.alpha = 0.0f;
            
            cell.notesTextView.hidden = NO;
            cell.notesTextView.frame = CGRectMake(7, CGRectGetMaxY(cell.secondaryLabel.frame), CGRectGetWidth(_theTableView.frame) - 14, kNotesTextViewHeight - CGRectGetMaxY(cell.secondaryLabel.frame));
            cell.notesTextView.text = _contact.notes;
            
            cell.mainLabel.frame = CGRectMake(14, CGRectGetMaxY(cell.secondaryLabel.frame), CGRectGetWidth(_theTableView.frame) - kButtonWidth - (kButtonPadding * 3), 33);
            cell.mainLabel.text = NSLocalizedString(@"Add notes for this contact", nil);
            cell.mainLabel.alpha = [cell.notesTextView.text length] ? 0.0f : 0.4f;
            cell.mainLabel.font = cell.notesTextView.font;
            
            cell.delegate = nil;
            cell.panGestureRecognizer.enabled = NO;
            
            break;
        }
        case RCContactSectionMeta:
        {
            
            cell.secondaryLabel.text = nil;
            
            cell.buttonLeft.alpha = 0.0f;
            cell.buttonRight.alpha = 0.0f;
            
            cell.notesTextView.hidden = YES;
            
            cell.mainLabel.frame = CGRectMake(14, 0, CGRectGetWidth(_theTableView.frame) - 28, kCellHeight);
            if ([_contact.modifiedAt timeIntervalSinceDate:_contact.createdAt] > 60*60*24) {
                cell.mainLabel.text = [NSString stringWithFormat:@"Created: %@\nModified: %@", [_dateFormatter stringFromDate:_contact.createdAt], [_dateFormatter stringFromDate:_contact.modifiedAt]];
            } else {
                cell.mainLabel.text = [NSString stringWithFormat:@"Created: %@", [_dateFormatter stringFromDate:_contact.createdAt]];
            }
            cell.mainLabel.numberOfLines = 0;
            cell.mainLabel.font = [UIFont fontWithName:kBoldFontName size:12.0f];
            
            cell.delegate = nil;
            cell.panGestureRecognizer.enabled = NO;
            
            break;
        }
        default:
            break;
            
    }
    
    cell.mainLabel.textColor = [UIColor whiteColor];
    cell.secondaryLabel.textColor = [UIColor whiteColor];
    cell.colorIndicatorView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

/**
 *  Not available yet. Will include eventually
 *
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 return (indexPath.section == RCContactSectionEmail && [_contact.emailArray count]>1) || (indexPath.section == RCContactSectionPhone && [_contact.phoneArray count]>1);
 }
 
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
 
 // Do not allow cross-section movements
 if (sourceIndexPath.section != destinationIndexPath.section) {
 [_theTableView reloadData];
 return;
 }
 
 }
 */

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case RCContactSectionPhone:
        {
            NSDictionary *phone = _contact.phoneArray[indexPath.row];
            NSString *label = [phone allKeys][0];
            NSString *value = [phone objectForKey:label];
            
            [self call:value];
            
            break;
        }
        case RCContactSectionEmail:
        {
            NSString *email = _contact.emailArray[indexPath.row];
            
            [self email:email];
            
            break;
        }
        case RCContactSectionLinkedIn:
        {
            
            [RCExternalRequestHandler openLinkedInProfile:_contact forceSafari:NO];
            
            break;
        }
        case RCContactSectionNotes:
        {
            RCContactDetailTableViewCell *cell = (RCContactDetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.notesTextView becomeFirstResponder];
            
            break;
        }
        default:
            break;
    }
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView != _theTableView) {
        return;
    }
    
    // Get the distance the view has dragged
    CGFloat yOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    
    // Determine if the remind button overlay should be present
    if (yOffset > kHeaderHeight - CGRectGetMinY(_remindButtonOverlay.frame)) {
        _remindButtonOverlay.alpha = 0.0f;
    } else {
        _remindButtonOverlay.alpha = 1.0f;
    }
    
    CGFloat offset = yOffset / CGRectGetHeight(_theTableView.frame);

    if (yOffset < 0) {
        // Scrolling up
        // Offset is negative
        
        CGFloat scaleFg = 1 - (offset * 0.75);
        CGFloat scaleBg = 1 - (offset * 1.5);
        
        CGFloat reminderAlpha = 1 + (yOffset / 78.0f);
        
        _contactHeaderView.transform = CGAffineTransformMakeScale(scaleFg, scaleFg);
        _contactHeaderBackgroundImage.transform = CGAffineTransformMakeScale(scaleBg, scaleBg);
        _remindButton.alpha = reminderAlpha;
        
        self.title = nil;
        
    }
    else if (yOffset > 0) {
        // Scrolling down
        // Offset is positive
        
        CGFloat reminderAlpha = 1 - (yOffset / 108.0f);
        
        _contactHeaderView.alpha = reminderAlpha;
        
        self.title = yOffset > kHeaderHeight - 64 ? _contact.fullName : nil;
        
    }
    else {
        // Reset to all good
        
        _contactHeaderView.alpha = 1.0f;
        _contactHeaderView.transform = CGAffineTransformIdentity;
        
        self.title = nil;
        
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (decelerate) {
        [self.view endEditing:YES];
    }
    
}

#pragma mark - Keyboard listening

- (void)keyboardWillShow:(NSNotification *)notification {
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
    UIEdgeInsets insets = _theTableView.contentInset;
    insets.bottom = keyboardBounds.size.height;
    _theTableView.contentInset = insets;
    
	// commit animations
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
    UIEdgeInsets insets = _theTableView.contentInset;
    insets.bottom = 0;
    _theTableView.contentInset = insets;
    
	// commit animations
	[UIView commitAnimations];
}

#pragma mark - Text View Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    UIEdgeInsets tableInsets = _theTableView.contentInset;
    tableInsets.bottom = 260;
    tableInsets.top = 0;
    _theTableView.contentInset = tableInsets;
    
    [_theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:RCContactSectionNotes] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        for (MCSwipeTableViewCell *cell in _theTableView.visibleCells) {
            if ([_theTableView indexPathForCell:cell].section != RCContactSectionNotes) {
                cell.contentView.alpha = 0.2f;
            }
        }
    }];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    UIEdgeInsets tableInsets = _theTableView.contentInset;
    tableInsets.bottom = 0;
    tableInsets.top = kHeaderHeight - 64;
    _theTableView.contentInset = tableInsets;
    
    [UIView animateWithDuration:0.2 animations:^{
        for (MCSwipeTableViewCell *cell in _theTableView.visibleCells) {
            cell.contentView.alpha = 1.0f;
        }
    }];
    
    [_contact saveNotes:textView.text];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.viewController saveAddressBook];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        
        [self.view endEditing:YES];
        
        return NO;
    }
    
    RCContactDetailTableViewCell *detailCell = (RCContactDetailTableViewCell *)[_theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:RCContactSectionNotes]];
    if ([[textView.text stringByReplacingCharactersInRange:range withString:text] length]) {
        detailCell.mainLabel.alpha = 0.0f;
    } else {
        detailCell.mainLabel.alpha = 0.4;
    }
    
    return YES;
}

#pragma mark - Token Delegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj {
    
    [_contact saveTag:title];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.viewController saveAddressBook];
    
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj {
    
    [_contact deleteTag:title];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.viewController saveAddressBook];
    
}

- (void)tokenFieldDidBeginEditing:(JSTokenField *)tokenField {
    
    UIEdgeInsets tableInsets = _theTableView.contentInset;
    tableInsets.bottom = 260;
    _theTableView.contentInset = tableInsets;
    
    [_theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:RCContactSectionTags] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        for (UITableViewCell *cell in _theTableView.visibleCells) {
            if ([_theTableView indexPathForCell:cell].section != RCContactSectionTags) {
                cell.contentView.alpha = 0.2f;
            }
        }
    }];

}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField {

    UIEdgeInsets tableInsets = _theTableView.contentInset;
    tableInsets.bottom = 0;
    tableInsets.top = kHeaderHeight - 64;
    _theTableView.contentInset = tableInsets;
    
    [UIView animateWithDuration:0.2 animations:^{
        for (UITableViewCell *cell in _theTableView.visibleCells) {
            cell.contentView.alpha = 1.0f;
        }
    }];

}


- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{
	//[_toRecipients removeObjectAtIndex:index];
	//NSLog(@"Deleted token %d\n%@", index, _toRecipients);
    
    if (![_tagField.tokens count]) {
        _tagField.textField.placeholder = NSLocalizedString(@"Tags", nil);
    }
    
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    NSMutableString *recipient = [NSMutableString string];
	
	NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
    NSString *rawStr = [[tokenField textField] text];
	for (int i = 0; i < [rawStr length]; i++)
	{
		if (![charSet characterIsMember:[rawStr characterAtIndex:i]])
		{
			[recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
		}
	}
    
    if ([rawStr length])
	{
		[tokenField addTokenWithTitle:rawStr representedObject:recipient];
	}
    
    tokenField.textField.text = nil;
    
    return NO;
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == TAG_ACTION_EDIT) {
        
        switch (buttonIndex) {
            case 0:
            {
                // Set Photo
                
                UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Existing", nil];
                ac.tag = TAG_ACTION_PHOTO;
                [ac showInView:self.view];
                
                break;
            }
            case 1:
            {
                // Edit
                
                ABRecordRef person = _contact.originAddressBookRef;
                ABPersonViewController *picker = [[ABPersonViewController alloc] init];
                picker.displayedPerson = person;
                // Allow users to edit the person’s information
                picker.allowsEditing = YES;
                
                _shouldUpdateOnAppear = YES;
                
                [self.navigationController pushViewController:picker animated:YES];
                
                break;
            }
            case 2:
            {
                // Delete
                
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Delete Contact" message:@"Are you sure you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
                al.tag = TAG_ALERT_DELETE;
                [al show];
                
                break;
            }
            default:
                break;
        }
        
    }
    else if (actionSheet.tag == TAG_ACTION_PHOTO) {
        
        if (buttonIndex == 0) {
            // camera
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                if (_imgPicker == nil) {
                    _imgPicker = [[UIImagePickerController alloc] init];
                }
                _imgPicker.delegate = self;
                _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [delegate.viewController presentViewController:_imgPicker animated:YES completion:nil];
                
            } else {
                [[[UIAlertView alloc] initWithTitle:@"No Camera Available" message:@"Sorry, but it looks like your device does not have a camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            
        } else if (buttonIndex == 1) {
            // existing
            
            if (_imgPicker == nil) {
                _imgPicker = [[UIImagePickerController alloc] init];
            }
            _imgPicker.delegate = self;
            _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.viewController presentViewController:_imgPicker animated:YES completion:nil];
            
        }
        
    }
    
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == TAG_ALERT_DELETE) {
        
        if (buttonIndex) {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.viewController deleteContact:_contact];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    
}

#pragma mark -
#pragma mark Image Picker Delegation

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    // Compress image
    float actualHeight = img.size.height;
    float actualWidth = img.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 640.0/960.0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 960.0 / actualHeight;
            actualWidth = ceilf(imgRatio * actualWidth);
            actualHeight = 960.0;
        }
        else{
            imgRatio = 640.0 / actualWidth;
            actualHeight = ceilf(imgRatio * actualHeight);
            actualWidth = 640.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [img drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Store the image
    [_contact savePhoto:image];
    
    // Save contact list
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.viewController saveAddressBook];
    
    [self configureViewForContact:_contact];
    
}

#pragma mark - External Request Delegates

#pragma mark Email

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Text

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Reminder

- (void)reminderView:(RCReminderViewController *)controller didSetReminderForContact:(Contact *)contact {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reminderViewDidCancel:(RCReminderViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
