//
//  RCReminderViewController.h
//  Reach
//
//  Created by Tom Bachant on 5/10/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCReminderViewController;
@class Contact;

@protocol RCReminderViewControllerDelegate

@optional
- (void)reminderView:(RCReminderViewController *)controller didSetReminderForContact:(Contact *)contact;
- (void)reminderViewDidCancel:(RCReminderViewController *)controller;

@end

@interface RCReminderViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) id<RCReminderViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIView *headerLabelContainer;
@property (nonatomic, weak) IBOutlet UIPickerView *reminderPicker;
@property (nonatomic, strong) UIView *whiteLineUpper;
@property (nonatomic, strong) UIView *whiteLineLower;
@property (nonatomic, weak) IBOutlet UITextField *detailsTextField;

@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *confirmButton;

@property (nonatomic, strong) Contact *contact;

- (IBAction)cancel:(id)sender;
- (IBAction)setReminder:(id)sender;

- (id)initWithContact:(Contact *)person;

@end
