//
//  RCExternalRequestHandler.h
//  Reach
//
//  Created by Tom Bachant on 5/26/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "Definitions.h"
#import "RCReminderViewController.h"

@interface RCExternalRequestHandler : NSObject

+ (void)call:(NSString *)number completionHandler:(void(^)(BOOL success))compBlock;
+ (void)text:(NSString *)number delegate:(id<MFMessageComposeViewControllerDelegate>)delegate presentationHandler:(void(^)(BOOL presented))presBlock completionHandler:(void(^)(BOOL success))compBlock;
+ (void)email:(NSString *)email delegate:(id<MFMailComposeViewControllerDelegate>)delegate presentationHandler:(void(^)(BOOL presented))presBlock completionHandler:(void(^)(BOOL success))compBlock;
+ (void)remind:(Contact *)contact delegate:(id<RCReminderViewControllerDelegate>)delegate presentationHandler:(void(^)(BOOL presented))presBlock completionHandler:(void(^)(BOOL success))compBlock;
+ (void)openLinkedInProfile:(Contact *)profile forceSafari:(BOOL)safari;

@end
