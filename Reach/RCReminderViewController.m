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

static CGFloat const kPickerRowTextSize = 16.0f;
static CGFloat const kPickerRowHeight = 50.0f;

@interface RCReminderViewController ()

- (void)dismissKeyboard;

- (CGFloat)widthOfName;

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
    
    NSLog(@"Width is : %f", CGRectGetWidth(screenFrame));
    
    _reminderPicker.frame = CGRectMake(0, CGRectGetMidY(screenFrame) - 110, CGRectGetWidth(screenFrame), 216);
    _reminderPicker.showsSelectionIndicator = NO;
    
    _cancelButton.frame = CGRectMake(10, CGRectGetHeight(screenFrame) - 74, (CGRectGetWidth(screenFrame) - 20) / 2, 74);
    _confirmButton.frame = CGRectMake(CGRectGetMaxX(_cancelButton.frame), CGRectGetMinY(_cancelButton.frame), CGRectGetWidth(_cancelButton.frame), CGRectGetHeight(_cancelButton.frame));
    
    _detailsTextField.frame = CGRectMake(0, CGRectGetMinY(_cancelButton.frame) - 40, CGRectGetWidth(screenFrame), 40);
    
    // Add tap gesture recognizer to dismiss keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    
    // Alrighty, now let's get this scroll view setup
    _containerScrollView.contentSize = CGSizeMake(CGRectGetWidth(screenFrame) * 2, CGRectGetHeight(screenFrame));
    _containerScrollView.pagingEnabled = YES;
    _containerScrollView.showsHorizontalScrollIndicator = NO;
    _containerScrollView.showsVerticalScrollIndicator = NO;
    _containerScrollView.backgroundColor = [UIColor clearColor];
    [self.view sendSubviewToBack:_containerScrollView];
    
    // Add the white borders to the picker
    _whiteSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(-2, _reminderPicker.center.y - (kPickerRowHeight / 2), CGRectGetWidth(screenFrame) + 4, kPickerRowHeight)];
    _whiteSeparatorView.backgroundColor = [UIColor clearColor];
    _whiteSeparatorView.layer.borderWidth = 1.0f;
    _whiteSeparatorView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _whiteSeparatorView.userInteractionEnabled = NO;
    [self.view addSubview:_whiteSeparatorView];
    [self.view sendSubviewToBack:_whiteSeparatorView];
    
    _datePicker.center = CGPointMake(CGRectGetWidth(screenFrame) * 1.5, _reminderPicker.center.y);
    _datePicker.minimumDate = [NSDate date];
    [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [_datePicker setDate:[NSDate dateWithTimeInterval:60 * 10 sinceDate:[NSDate date]] animated:YES];
    [_containerScrollView addSubview:_datePicker];
    
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

#pragma mark - Helper

- (CGFloat)widthOfName {
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGFloat fullWidth = CGRectGetWidth(screenFrame);
    
    CGFloat leftWidthMin = 70.0f;
    CGFloat rightWidthMin = 130.0f;
    
    NSString *firstName = [_contact.fullName length] ? [_contact.fullName componentsSeparatedByString:@" "][0] : NSLocalizedString(@"them", nil);
    CGSize nameSize = [firstName boundingRectWithSize:CGSizeMake(fullWidth - leftWidthMin - rightWidthMin, 20)
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kPickerRowTextSize],NSFontAttributeName, nil]context:nil].size;
    
    return nameSize.width + 20;
}

#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            return 3;
            break;
        }
        case 1: {
            return 1;
            break;
        }
        case 2: {
            return 5;
            break;
        }
        default:
            break;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return kPickerRowHeight;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGFloat fullWidth = CGRectGetWidth(screenFrame);
    
    CGFloat nameWidth = [self widthOfName];
    
    if (component == 1) {
        return nameWidth;
    }
    
    CGFloat remainder = fullWidth - nameWidth;
    
    if (component == 0) {
        return remainder * 0.35;
    }
    return remainder * 0.65;
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17.0f];
    label.textColor = [UIColor whiteColor];
    
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGFloat fullWidth = CGRectGetWidth(screenFrame);
    
    CGFloat nameWidth = [self widthOfName];
    
    CGFloat remainder = fullWidth - nameWidth;
    
    NSString *title = @"";
    
    switch (component) {
        case 0:
        {
            if (row == 0) {
                title = NSLocalizedString(@"Call", nil);
            } else if (row == 1) {
                title = NSLocalizedString(@"Text", nil);
            } else if (row == 2) {
                title = NSLocalizedString(@"Email", nil);
            }
            
            label.frame = CGRectMake(0, 0, remainder * 0.35, kPickerRowHeight);
            
            label.font = [UIFont boldSystemFontOfSize:kPickerRowTextSize];
            label.textAlignment = NSTextAlignmentRight;
            
            break;
        }
        case 1: {
            title = [_contact.fullName length] ? [_contact.fullName componentsSeparatedByString:@" "][0] : NSLocalizedString(@"them", nil);
            
            label.frame = CGRectMake(0, 0, nameWidth, kPickerRowHeight);
            
            label.font = [UIFont systemFontOfSize:kPickerRowTextSize];
            label.textAlignment = NSTextAlignmentCenter;
            
            break;
        }
        case 2: {
            if (row == RCReminderTimePeriod10Minutes) {
                title = NSLocalizedString(@"in 10 minutes", nil);
            } else if (row == RCReminderTimePeriod1Hour) {
                title = NSLocalizedString(@"in an hour", nil);
            } else if (row == RCReminderTimePeriodTomorrow) {
                title = NSLocalizedString(@"tomorrow", nil);
            } else if (row == RCReminderTimePeriod3Days) {
                title = NSLocalizedString(@"in 3 days", nil);
            } else if (row == RCReminderTimePeriodCustom) {
                title = NSLocalizedString(@"set date...", nil);
            }
            
            label.frame = CGRectMake(0, 0, remainder * 0.65, kPickerRowHeight);
            
            label.font = [UIFont boldSystemFontOfSize:kPickerRowTextSize];
            label.textAlignment = NSTextAlignmentLeft;
            
            break;
        }
        default:
            break;
    }

    label.text = title;
    return label;
}

#pragma mark - Picker delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 2) {
        
        if (row == RCReminderTimePeriodCustom) {
            [_containerScrollView scrollRectToVisible:_datePicker.frame animated:YES];
        }
        
    }
    
}

#pragma mark - Scrolling Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat threshold = scrollView.contentSize.width / 2;
    CGFloat scrollOffset = scrollView.contentOffset.x;
    
    CGFloat topShrunk = _reminderPicker.center.y - (kPickerRowHeight / 2);
    CGFloat topExpanded = CGRectGetMinY(_datePicker.frame);
    
    [_whiteSeparatorView setFrameOriginY:topShrunk + ((scrollOffset / threshold) * (topExpanded - topShrunk))];
    
    CGFloat minY = topShrunk + ((scrollOffset / threshold) * (topExpanded - topShrunk));
    if (minY > topShrunk) minY = topShrunk;
    else if (minY < topExpanded) minY = topExpanded;
    
    CGFloat height = kPickerRowHeight + ((scrollOffset / threshold) * (_datePicker.frame.size.height - kPickerRowHeight));
    if (height < kPickerRowHeight) height = kPickerRowHeight;
    else if (height > _datePicker.frame.size.height) height = _datePicker.frame.size.height;
    
    CGFloat alpha = (scrollOffset / threshold) * 0.7;
    if (alpha > 0.7) alpha = 0.7f;
    else if (alpha < 0) alpha = 0.0f;
    
    CGRect separatorFrame = _whiteSeparatorView.frame;
    separatorFrame.origin.y = minY;
    separatorFrame.size.height = height;
    _whiteSeparatorView.frame = separatorFrame;
    _whiteSeparatorView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:alpha];
    
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
        _reminderPicker.alpha = 0.0f;
        _whiteSeparatorView.alpha = 0.0f;
        
        _datePicker.alpha = 0.0f;
        
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
        _reminderPicker.alpha = 1.0f;
        _whiteSeparatorView.alpha = 1.0f;
        
        _datePicker.alpha = 1.0f;
    
    } completion:nil];
    
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
    NSInteger row = [_reminderPicker selectedRowInComponent:2];
    
    if (row == RCReminderTimePeriodCustom) {
        
        notification.fireDate = _datePicker.date;
        
    }
    else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
        
        if (row == RCReminderTimePeriod10Minutes) {
            comps.minute += 10;
        } else if (row == RCReminderTimePeriod1Hour) {
            comps.hour += 1;
        } else if (row == RCReminderTimePeriodTomorrow) {
            comps.day += 1;
            comps.hour = 10; // set 10am
            comps.minute = 0;
        } else if (row == RCReminderTimePeriod3Days) {
            comps.day += 3;
            comps.hour = 10; // set 10am
            comps.minute = 0;
        }
        
        notification.fireDate = [calendar dateFromComponents:comps];
    }
    
    
    
    //
    // Alert message
    //
    NSString *alertType = @"";
    NSInteger rowForType = [_reminderPicker selectedRowInComponent:0];
    if (rowForType == RCReminderTypeCall) {
        alertType = NSLocalizedString(@"Call", nil);
    } else if (rowForType == RCReminderTypeText) {
        alertType = NSLocalizedString(@"Text", nil);
    } else if (rowForType == RCReminderTypeEmail) {
        alertType = NSLocalizedString(@"Email", nil);
    }
    
    notification.alertBody = [NSString stringWithFormat:@"%@ %@%@", alertType, _contact.fullName, [_detailsTextField.text length] ? [NSString stringWithFormat:@"\n%@", _detailsTextField.text] : @""];
    
    //
    // Alert button title
    //
    notification.alertAction = NSLocalizedString(@"Open", nil);
    
    //
    // Notification details
    //
    notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             alertType, kLocalNotificationUserInfoActionString,
                             [NSNumber numberWithInteger:rowForType], kLocalNotificationUserInfoActionType,
                             _detailsTextField.text, kLocalNotificationAlertActionName,
                             _contact.contactId, kLocalNotificationUserInfoUserID, nil];
    
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [MNMToast showWithText:NSLocalizedString(@"Reminder Set :)", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
    }];
}

@end
