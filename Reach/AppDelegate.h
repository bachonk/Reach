//
//  AppDelegate.h
//  Reach
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

#import "RCSwipeViewController.h"
#import "RCPhoneController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *windowBackgroundView;

@property (strong, nonatomic) RCSwipeViewController *viewController;

@property (strong, nonatomic) NSDate *dateSinceLastOpen;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *lastLocationDescription;

// Actions
- (void)registerPushNotifications;

@end
