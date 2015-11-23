//
//  RCContactManager.h
//  Reach
//
//  Created by Tom Bachant on 11/22/15.
//  Copyright © 2015 Tom Bachant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "Contact.h"

@interface RCContactManager : NSObject

+ (instancetype)shared;

- (void)getContactListAuthorizationWithCompletion:(void(^)(ABAuthorizationStatus status))compBlock;
- (void)fetchContacts;
- (void)saveContact:(ABRecordRef)recordRef;
- (void)deleteContact:(Contact *)contact;
- (void)saveAddressBook;

- (Contact *)contactFromId:(NSString *)contactId;
- (Contact *)contactFromAddressBookRef:(ABAddressBookRef)abRef;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, assign) BOOL accessRevoked;

@end
