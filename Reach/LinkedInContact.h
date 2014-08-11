//
//  LinkedInContact.h
//  Reach
//
//  Created by Tom Bachant on 8/2/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "Contact.h"

@interface LinkedInContact : Contact

@property (nonatomic, strong) NSString *headline;
@property (nonatomic, strong) NSString *industry;
@property (nonatomic, strong) NSString *profilePicURL;
@property (nonatomic, strong) NSString *profileLink;
@property (nonatomic, strong) UIImage *cachedImage;

+ (instancetype)linkedInContactFromDictionary:(NSDictionary *)dict;

@end
