//
//  NSString+PhoneFormatting.h
//  Reach
//
//  Created by Tom Bachant on 6/13/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PhoneFormatting)

- (NSString *)unformattedPhoneString;
- (NSString *)formattedPhoneNumber;

@end
