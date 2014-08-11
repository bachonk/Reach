//
//  LinkedInContact.m
//  Reach
//
//  Created by Tom Bachant on 8/2/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "LinkedInContact.h"

static const NSString *kLinkedInKeyFirstName =  @"firstName";
static const NSString *kLinkedInKeyLastName =   @"lastName";
static const NSString *kLinkedInKeyHeadline =   @"headline";
static const NSString *kLinkedInKeyIndustry =   @"industry";
static const NSString *kLinkedInKeyId =         @"id";
static const NSString *kLinkedInKeyProfilePic = @"pictureUrl";
static const NSString *kLinkedInKeyProfileLink = @"siteStandardProfileRequest";
static const NSString *kLinkedInKeyProfileLinkURL = @"url";

@implementation LinkedInContact

+ (instancetype)linkedInContactFromDictionary:(NSDictionary *)dict {
    
    LinkedInContact *contact = [LinkedInContact new];
    
    contact.type = RCContactTypeLinkenIn;
    
    contact.firstName = dict[kLinkedInKeyFirstName];
    contact.lastName = dict[kLinkedInKeyLastName];
    contact.fullName = [contact.firstName length] && [contact.lastName length] ? [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName] : [NSString stringWithFormat:@"%@%@", contact.firstName, contact.lastName];
    contact.headline = dict[kLinkedInKeyHeadline];
    contact.industry = dict[kLinkedInKeyIndustry];
    contact.linkedInId = dict[kLinkedInKeyId];
    contact.profilePicURL = dict[kLinkedInKeyProfilePic];
    
    NSDictionary *profileLinkDict = dict[kLinkedInKeyProfileLink];
    contact.profileLink = profileLinkDict[kLinkedInKeyProfileLinkURL];
    
    return contact;
    
}

@end
