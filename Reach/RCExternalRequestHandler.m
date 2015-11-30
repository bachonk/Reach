//
//  RCExternalRequestHandler.m
//  Reach
//
//  Created by Tom Bachant on 5/26/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCExternalRequestHandler.h"
#import "MNMToast.h"
#import "AppDelegate.h"
#import "RCSocialDetailViewController.h"
#import "LinkedInManager.h"

@implementation RCExternalRequestHandler

+ (void)call:(NSString *)number completionHandler:(void (^)(BOOL))compBlock
{
    NSURL *urlToOpen = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlToOpen]) {
        [[UIApplication sharedApplication] openURL:urlToOpen];
        
        if (compBlock) {
            compBlock(YES);
        }
        
    } else {
        // Can't make calls :(
        [MNMToast showWithText:NSLocalizedString(@"Phone calls not available on this device :(", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
        
        if (compBlock) {
            compBlock(NO);
        }
    }
}

+ (void)text:(NSString *)number delegate:(id<MFMessageComposeViewControllerDelegate>)delegate presentationHandler:(void (^)(BOOL))presBlock completionHandler:(void (^)(BOOL))compBlock
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", number]]];
    
    /*
     * Settings for using the text modal
     *
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if ([MFMessageComposeViewController canSendText]) {
        
        MFMessageComposeViewController *composer = [[MFMessageComposeViewController alloc] init];
        composer.messageComposeDelegate = delegate;
        composer.recipients = @[number];
        composer.navigationBar.tintColor = COLOR_DEFAULT_RED;
        composer.navigationBar.barTintColor = [UIColor whiteColor];
        
        UIViewController *controller = (UIViewController *)delegate;
        [controller presentViewController:composer animated:YES completion:^{
            
            if (presBlock) {
                presBlock(YES);
            }

        }];
        
    } else {
        // Can't send texts
        
        if (presBlock) {
            presBlock(NO);
        }
        if (compBlock) {
            compBlock(NO);
        }
        
        [MNMToast showWithText:NSLocalizedString(@"Texting not available on this device :(", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
    }
     */
    
}

+ (void)email:(NSString *)email delegate:(id<MFMailComposeViewControllerDelegate>)delegate presentationHandler:(void (^)(BOOL))presBlock completionHandler:(void (^)(BOOL))compBlock
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        [composer setToRecipients:[NSArray arrayWithObject:email]];
        composer.mailComposeDelegate = delegate;
        composer.navigationBar.tintColor = COLOR_DEFAULT_RED;
        composer.navigationBar.barTintColor = [UIColor whiteColor];

        UIViewController *controller = (UIViewController *)delegate;
        [controller presentViewController:composer animated:YES completion:^{
            
            if (presBlock) {
                presBlock(YES);
            }
            
        }];
        
    } else {
        // Can't send email
        
        if (presBlock) {
            presBlock(NO);
        }
        if (compBlock) {
            compBlock(NO);
        }
        
        [MNMToast showWithText:NSLocalizedString(@"Emailing not available on this device :(", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
    }
    
}

+ (void)remind:(Contact *)contact delegate:(id<RCReminderViewControllerDelegate>)delegate presentationHandler:(void (^)(BOOL))presBlock completionHandler:(void (^)(BOOL))compBlock
{
    RCReminderViewController *reminder = [[RCReminderViewController alloc] initWithContact:contact];
    reminder.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    reminder.delegate = delegate;
    
    UIViewController *controller = (UIViewController *)delegate;
    [controller presentViewController:reminder animated:YES completion:nil];
}

+ (void)openLinkedInProfile:(Contact *)profile forceSafari:(BOOL)safari
{
    if ([LinkedInManager hasLinkedInApp] && !safari) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"linkedin://#profile/%@", profile.linkedInId]]];
        
    }
    else {
        
        LinkedInContact *linkedIn = (LinkedInContact *)profile;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkedIn.profileLink]];
        
    }
}

@end
