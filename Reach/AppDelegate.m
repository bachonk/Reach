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
    
    //self.windowBackgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.windowBackgroundView.backgroundColor = COLOR_WINDOW_BACKGROUND;
    //[self.window addSubview:self.windowBackgroundView];
    
    // Red nav bar appearance
    [[UINavigationBar appearanceWhenContainedIn:[RCNavigationController class], nil] setBackgroundImage:[[UIImage imageNamed:@"navigation-bar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:1] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[RCNavigationController class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kLightFontName size:18.0f], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [[UINavigationBar appearanceWhenContainedIn:[RCNavigationController class], nil] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearanceWhenContainedIn:[RCNavigationController class], nil] setBarTintColor:[UIColor whiteColor]];
    
    // Gray nav bar appearance
    [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setBackgroundImage:[[UIImage imageNamed:@"search-bar"] stretchableImageWithLeftCapWidth:1 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kLightFontName size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil]];
    [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setTintColor:COLOR_DEFAULT_RED];
    [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setBarTintColor:COLOR_DEFAULT_RED];
    
    // Bar button appearance
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kBoldFontName size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationController class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:COLOR_DEFAULT_RED, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[RCNavigationController class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    // Back button
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back-indicator"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back-indicator"]];
    
    // Startup Crashlytics
    [Crashlytics startWithAPIKey:@"19a3cbb17a05a126e819c4e05c7c9e61a4f5fb8e"];

    self.viewController = [[RCSwipeViewController alloc] init];
    
    self.navigationController = [[RCNavigationController alloc] initWithRootViewController:self.viewController];
    self.navigationController.navigationBar.translucent = YES;
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    
    [self.viewController applicationDidReceiveRemoteNotification:notification applicationState:application.applicationState];
    
}

@end
