//
//  Definitions.h
//  Reach
//
//  Created by Tom Bachant on 2/23/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#ifndef Reach_Definitions_h
#define Reach_Definitions_h

#import "RCExternalRequestHandler.h"

#import "UIView+FrameResizing.h"
#import "UIImage+TintColor.h"
#import "NSString+PhoneFormatting.h"
#import "RCTagView.h"

#pragma mark - Cell customization - 

// Layout
static const CGFloat kCellHeightDefault = 52.0f;
static const CGFloat kCellImageInset = 4.0f;

// Design
#define CELL_TEXT_FONT_DEFAULT [UIFont systemFontOfSize:18.0f]
#define CELL_TEXT_FONT_DISABLED [UIFont italicSystemFontOfSize:18.0f]

// Colors
#define COLOR_WINDOW_BACKGROUND [UIColor colorWithWhite:0.84f alpha:1.0f]
#define COLOR_NAVIGATION_BAR [UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:230.0/255.0f alpha:1.0f]
#define COLOR_TABLE_CELL [UIColor colorWithWhite:0.975f alpha:1.0f]
#define COLOR_DEFAULT_RED [UIColor colorWithRed:222.0/255.0 green:67.0/255.0 blue:40.0/255.0f alpha:1.0f]

#define COLOR_TEXT_BLUE [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0f]
#define COLOR_CALL_GREEN [UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1.0f]
#define COLOR_EMAIL_RED [UIColor colorWithRed:232.0/255.0 green:61.0/255.0 blue:14.0/255.0 alpha:1.0f]
#define COLOR_REMIND_YELLOW [UIColor colorWithRed:0.938 green:0.816 blue:0.236 alpha:1.000]
#define COLOR_TAG_BLUE [UIColor colorWithRed:0.0/255.0 green:160.0/255.0f blue:215.0/255.0 alpha:1.000]
#define COLOR_IMAGE_DEFAULT [UIColor colorWithWhite:0.7f alpha:1.0f]
#define COLOR_LINKEDIN_BLUE [UIColor colorWithRed:0.0f green:116.0/255.0f blue:184.0f/255.0f alpha:1.000]

// Scroll view definitions
#define SCROLL_DRAG_DISTANCE 80.0f

// Reminders
enum RCReminderType
{
    RCReminderTypeCall = 0,
    RCReminderTypeText,
    RCReminderTypeEmail
};

typedef NS_ENUM(NSInteger, RCContactType)
{
    RCContactTypePhoneContact = 0,
    RCContactTypeLinkenIn
};

// Tag separator
static NSString *kContactTagSeparator = @"\n•••\n";

// Notifications
static NSString *kLocalNotificationAlertActionName = @"reachAlert";
static NSString *kLocalNotificationUserInfoUserID = @"reachUserID";
static NSString *kLocalNotificationUserInfoActionType = @"reachActionType";
static NSString *kLocalNotificationUserInfoActionString = @"reachActionString";
static NSString *kLocalNotificationActionText = @"Text";
static NSString *kLocalNotificationActionCall = @"Call";
static NSString *kLocalNotificationActionEmail = @"Email";
static NSString *kLocalNotificationActionCategory = @"AlertCategory";

// URL Scheme
static NSString *kURLSchemeNewContact = @"new";

#endif
