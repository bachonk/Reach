//
//  AppDelegate.h
//  Reach
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RCSwipeViewController.h"
#import "RCPhoneController.h"
#import "RCNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *windowBackgroundView;

@property (strong, nonatomic) RCNavigationController *navigationController;

@property (strong, nonatomic) RCSwipeViewController *viewController;

@property (strong, nonatomic) NSDate *dateSinceLastOpen;

@end
