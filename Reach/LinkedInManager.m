//
//  LinkedInManager.m
//  Reach
//
//  Created by Tom Bachant on 8/3/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "LinkedInManager.h"
#import "LinkedInContact.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

static NSString *kUserDefaultsLinkedInAuthorizationCode = @"kUserDefaultsLinkedInAuthorizationCode";
static NSString *kUserDefaultsLinkedInAccessTokenKey = @"kUserDefaultsLinkedInAccessTokenKey";

static LinkedInManager *shared;

@interface LinkedInManager ()

@property (nonatomic, strong) LIALinkedInHttpClient *linkedInClient;

@end

@implementation LinkedInManager

+ (instancetype)shared {
    if (nil != shared) {
        return shared;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        shared = [LinkedInManager new];
        shared.contacts = [NSMutableArray new];
        
        shared.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLinkedInAccessTokenKey];
        
        shared.authorizationCode = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLinkedInAuthorizationCode];
        
        NSArray *grantedAccess = @[@"r_basicprofile", @"r_network", @"w_messages"];
        
        //load the the secret data from an uncommitted LIALinkedInClientExampleCredentials.h file
        NSString *clientId = @"77rb9x2xdly741"; //the client secret you get from the registered LinkedIn application
        NSString *clientSecret = @"rYx8iAXqTH3c2nEQ"; //the client secret you get from the registered LinkedIn application
        NSString *state = @"939j3fj23kSLDFkJCm93fjSDkcm39kdjf92"; //A long unique string value of your choice that is hard to guess. Used to prevent CSRF
        LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://coincidentalcode.com/apps/reach" clientId:clientId clientSecret:clientSecret state:state grantedAccess:grantedAccess];
        shared.linkedInClient = [LIALinkedInHttpClient clientForApplication:application];
    });
    
    return shared;
}

#pragma mark - Authorization

- (BOOL)isAuthorized {
    return [self.accessToken length] ? YES : NO;
}

- (void)getLinkedInAccessFromViewController:(UIViewController *)controller completion:(void (^)(BOOL, NSError *))compBlock {
    
    self.linkedInClient.presentingViewController = controller;
    
    [_linkedInClient getAuthorizationCode:^(NSString *code) {
        
        self.authorizationCode = code;
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:kUserDefaultsLinkedInAuthorizationCode];
        
        [_linkedInClient getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            
            // Got the access token
            self.accessToken = accessToken;
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kUserDefaultsLinkedInAccessTokenKey];
            
            compBlock(YES, nil);
            
        } failure:^(NSError *error) {
            
            compBlock(NO, error);
            
        }];
        
    } cancel:^{
        
        compBlock(NO, nil);
        
    } failure:^(NSError *error) {
        
        compBlock(NO, error);
        
    }];
}

- (void)getContactsWithCompletion:(void (^)(NSArray *, NSError *))compBlock {
    [_linkedInClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/connections?oauth2_access_token=%@&format=json", self.accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        
        NSMutableArray *contactsTemp = [NSMutableArray new];
        
        for (NSDictionary *dict in (NSArray *)result[@"values"]) {
            [contactsTemp addObject:[LinkedInContact linkedInContactFromDictionary:dict]];
        }
        
        // Sort data
        UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
        
        for (Contact *addressBook in contactsTemp) {
            NSInteger sect = [theCollation sectionForObject:addressBook
                                    collationStringSelector:@selector(fullName)];
            addressBook.sectionNumber = sect;
        }
        
        NSInteger highSection = [[theCollation sectionTitles] count];
        NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
        for (int i=0; i<=highSection; i++) {
            NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
            [sectionArrays addObject:sectionArray];
        }
        
        for (Contact *addressBook in contactsTemp) {
            [(NSMutableArray *)[sectionArrays objectAtIndex:addressBook.sectionNumber] addObject:addressBook];
        }
        
        [self.contacts removeAllObjects];
        for (NSMutableArray *sectionArray in sectionArrays) {
            NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(fullName)];
            [self.contacts addObject:sortedSection];
        }
        
        compBlock(self.contacts, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        self.accessToken = nil;
        compBlock(nil, error);
        
    }];
    
}

- (void)revokeAuthorization {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsLinkedInAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsLinkedInAuthorizationCode];
    
    self.accessToken = nil;
    self.authorizationCode = nil;
    
    [self.contacts removeAllObjects];
}

#pragma mark - Details

+ (BOOL)hasLinkedInApp {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"linkedin://#profile/"]];
}

@end
