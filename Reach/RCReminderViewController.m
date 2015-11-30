//
//  RCReminderViewController.m
//  Reach
//
//  Created by Tom Bachant on 5/10/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCReminderViewController.h"
#import "Definitions.h"
#import "MNMToast.h"
#import "Contact.h"

@interface RCReminderViewController ()

- (void)dismissKeyboard;

@end

@implementation RCReminderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithContact:(Contact *)person {
    self = [super initWithNibName:@"RCReminderViewController" bundle:nil];
    if (self) {
        _contact = person;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    
    //
    // Set all frames manually
    //
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    CGPoint headerCenter = _headerLabelContainer.center;
    headerCenter.x = CGRectGetMidX(screenFrame);
    _headerLabelContainer.center = headerCenter;
    
    _cancelButton.frame = CGRectMake(10, CGRectGetHeight(screenFrame) - 74, (CGRectGetWidth(screenFrame) - 20) / 2, 74);
    _confirmButton.frame = CGRectMake(CGRectGetMaxX(_cancelButton.frame), CGRectGetMinY(_cancelButton.frame), CGRectGetWidth(_cancelButton.frame), CGRectGetHeight(_cancelButton.frame));
    
    _detailsTextField.frame = CGRectMake(0, CGRectGetMinY(_cancelButton.frame) - 40, CGRectGetWidth(screenFrame), 40);
    
    // Add tap gesture recognizer to dismiss keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    
    _pickerView.frame = CGRectMake(0, CGRectGetMidY(screenFrame) - 110, 76, 216);
    _pickerView.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:149.0f/255.0f blue:125/255.0f alpha:1.0f];
    [self.view addSubview:_pickerView];
    
    _datePicker.frame = CGRectMake(CGRectGetMaxX(_pickerView.frame), CGRectGetMinY(_pickerView.frame), CGRectGetWidth(screenFrame) - CGRectGetWidth(_pickerView.frame), CGRectGetHeight(_pickerView.frame));
    _datePicker.minimumDate = [NSDate date];
    [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [_datePicker setDate:[NSDate dateWithTimeInterval:60 * 10 sinceDate:[NSDate date]] animated:YES];
    _datePicker.backgroundColor = _pickerView.backgroundColor;

    [self.view addSubview:_datePicker];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:screenFrame];
    bgImage.image = [UIImage imageNamed:@"navigation-bar"];
    [self.view addSubview:bgImage];
    [self.view sendSubviewToBack:bgImage];
    
    // Observe keyboard changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Keyboard changes

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *options = [notification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    keyboardEndFrame = [[options objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:(UIViewAnimationOptions)animationCurve animations:^{
        
        _detailsTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
        _detailsTextField.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds) - CGRectGetHeight(keyboardEndFrame) - 70, CGRectGetWidth(self.view.bounds), 70);
        
        _headerLabelContainer.alpha = 0.32f;
        
        _datePicker.alpha = 0.0f;
        _pickerView.alpha = 0.0f;
        
    } completion:nil];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *options = [notification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView animateWithDuration:animationDuration delay:0 options:(UIViewAnimationOptions)animationCurve animations:^{
        
        _detailsTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:[_detailsTextField.text length] ? 0.2f : 0.0f];
        _detailsTextField.frame = CGRectMake(0, CGRectGetMinY(_cancelButton.frame) - 40, CGRectGetWidth(self.view.bounds), 40);
        
        _headerLabelContainer.alpha = 1.0f;
        
        _datePicker.alpha = 1.0f;
        _pickerView.alpha = 1.0f;
    
    } completion:nil];
    
}

#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    if (row == 0) {
        title = NSLocalizedString(@"Text", nil);
    } else if (row == 1) {
        title = NSLocalizedString(@"Call", nil);
    } else if (row == 2) {
        title = NSLocalizedString(@"Email", nil);
    }
    return title;
}

#pragma mark - Actions

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setReminder:(id)sender {
    //
    // Create local notification
    //
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    //
    // Fire date
    //
    notification.fireDate = _datePicker.date;
    
    //
    // Alert message
    //
    NSString *alertType = @"";
    NSInteger rowForType = [_pickerView selectedRowInComponent:0];
    if (rowForType == RCReminderTypeCall) {
        alertType = NSLocalizedString(@"Call", nil);
    } else if (rowForType == RCReminderTypeText) {
        alertType = NSLocalizedString(@"Text", nil);
    } else if (rowForType == RCReminderTypeEmail) {
        alertType = NSLocalizedString(@"Email", nil);
    }
    
    notification.alertBody = [NSString stringWithFormat:@"%@ %@%@", alertType, _contact.fullName, [_detailsTextField.text length] ? [NSString stringWithFormat:@"\n%@", _detailsTextField.text] : @""];
    
    //
    // Alert button actions
    //
    notification.category = kLocalNotificationActionCategory;
    
    //
    // Notification details
    //
    notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             alertType, kLocalNotificationUserInfoActionString,
                             [NSNumber numberWithInteger:rowForType], kLocalNotificationUserInfoActionType,
                             _detailsTextField.text, kLocalNotificationAlertActionName,
                             _contact.contactId, kLocalNotificationUserInfoUserID,
                             _contact.phoneArray[0], kLocalNotificationUserInfoUserPhone,
                             _contact.fullName, kLocalNotificationUserInfoUserName,
                             [NSNumber numberWithDouble:[_datePicker.date timeIntervalSince1970]], kLocalNotificationUserInfoDate,
                             nil];
    
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [MNMToast showWithText:NSLocalizedString(@"Reminder Set :)", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
    }];
}

@end
