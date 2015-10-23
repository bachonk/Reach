//
//  RCContactDetailViewController.h
//  Reach
//
//  Created by Tom Bachant on 7/7/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

#import "UIImageView+Letters.h"
#import "RCContactDetailTableViewCell.h"
#import "TLTagsControl.h"
#import "FXBlurView.h"
#import "RCMergeViewController.h"

#import "Contact.h"

@protocol RCContactDetailViewControllerDelegate <NSObject>

- (void)contactDetailViewControllerDidCancel;

@end

@interface RCContactDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MCSwipeTableViewCellDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, RCReminderViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *theTableView;

@property (nonatomic, strong) UIImageView *contactHeaderBackgroundImage;
@property (nonatomic, strong) UIView *contactHeaderView;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) UIImageView *userImage;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) TLTagsControl *tagField;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIImageView *largeUserImage;

@property (nonatomic, strong) Contact *contact;

@property (nonatomic, weak) id <RCContactDetailViewControllerDelegate> delegate;

- (void)configureViewForContact:(Contact *)contct;
- (void)hide;
- (void)hideDownward:(BOOL)shouldGoDownward;

- (void)call:(NSString *)number;
- (void)text:(NSString *)number;
- (void)email:(NSString *)address;
- (void)remind:(Contact *)contact;

- (void)editContact;


@end
