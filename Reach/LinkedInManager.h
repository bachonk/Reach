//
//  LinkedInManager.h
//  Reach
//
//  Created by Tom Bachant on 8/3/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LinkedInContact.h"

@interface LinkedInManager : NSObject

+ (instancetype)shared;


// Authorization
- (void)getLinkedInAccessFromViewController:(UIViewController *)controller completion:(void(^)(BOOL success, NSError *error))compBlock;
- (void)getContactsWithCompletion:(void(^)(NSArray *results, NSError *error))compBlock;
- (BOOL)isAuthorized;

- (void)revokeAuthorization;

// Details
+ (BOOL)hasLinkedInApp;


@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *authorizationCode;
@property (nonatomic, strong) NSMutableArray *contacts;

@end
