//
//  AppDelegate.m
//  Reach
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import "AppDelegate.h"
#import "RCSwipeViewController.h"
#import "Definitions.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Track the last time the app was opened
    _dateSinceLastOpen = [NSDate date];
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Red nav bar appearance
    [[UINavigationBar appearance] setTintColor:COLOR_DEFAULT_RED];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    // Back button
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back-indicator"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back-indicator"]];
    
    // Startup Crashlytics
    [Crashlytics startWithAPIKey:@"19a3cbb17a05a126e819c4e05c7c9e61a4f5fb8e"];
    
    // Register local notifications
    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:kLocalNotificationActionText];
    [action1 setIdentifier:kLocalNotificationActionText];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:kLocalNotificationActionCall];
    [action2 setIdentifier:kLocalNotificationActionCall];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:kLocalNotificationActionCategory];
    [actionCategory setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    // Setup view controllers
    self.viewController = [[RCSwipeViewController alloc] init];
    
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    self.window.rootViewController = navControl;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if ([[url absoluteString] rangeOfString:kURLSchemeNewContact].location != NSNotFound) {
        if ([self.viewController respondsToSelector:@selector(showNewContactView)]) {
            [self.viewController showNewContactView];
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    _dateSinceLastOpen = [NSDate date];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self.viewController applicationDidBecomeActiveSinceDate:_dateSinceLastOpen];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Local notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [self.viewController applicationDidReceiveRemoteNotification:notification actionType:nil applicationState:application.applicationState];
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    if ([identifier isEqualToString:kLocalNotificationActionCall]) {
        NSLog(@"You chose action 1.");
    }
    else if ([identifier isEqualToString:kLocalNotificationActionText]) {
        NSLog(@"You chose action 2.");
    }
    
    if (completionHandler) {
        completionHandler();
    }
}

@end
