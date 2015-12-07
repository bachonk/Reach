//
//  RCContactManager.m
//  Reach
//
//  Created by Tom Bachant on 11/22/15.
//  Copyright © 2015 Tom Bachant. All rights reserved.
//

#import "RCContactManager.h"

static RCContactManager *shared = nil;

@implementation RCContactManager

- (id)init {
    self = [super init];
    if (self) {
        _contacts = [NSMutableArray new];
        _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    return self;
}

+ (instancetype)shared {
    if (nil != shared) {
        return shared;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        shared = [RCContactManager new];
    });
    
    return shared;
}

#pragma mark - Getters

- (Contact *)contactFromId:(NSString *)contactId {
    ABRecordID recordId = (int32_t)[contactId intValue];
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(self.addressBook, recordId);
    return [Contact contactFromAddressBook:record];
}

- (Contact *)contactFromAddressBookRef:(ABAddressBookRef)abRef {
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(self.addressBook, ABRecordGetRecordID(abRef));
    return [Contact contactFromAddressBook:record];
}

#pragma mark - Address Book Manipulation

- (void)saveAddressBook {
    CFErrorRef error;
    ABAddressBookSave(_addressBook, &error);
}

- (void)saveContact:(ABRecordRef)recordRef {    
    // Add to address book
    CFErrorRef error;
    ABAddressBookAddRecord(self.addressBook, recordRef, &error);
    
    // Save it
    ABAddressBookSave(_addressBook, nil);
    
    // Lazy way to refresh table
    [self fetchContacts];
}

- (void)deleteContact:(Contact *)contact {
    CFErrorRef error;
    ABAddressBookRemoveRecord(_addressBook, contact.originAddressBookRef, &error);
    
    [self saveAddressBook];
    
    [shared fetchContacts];
}

#pragma mark - Instance methods

- (void)fetchContacts {
    // Create addressbook data model
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(self.addressBook);
    
    NSMutableArray *addressBookTemp = [NSMutableArray new];
    
    for (NSInteger i = 0; i < nPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        Contact *contact = [Contact contactFromAddressBook:person];
        
        [addressBookTemp addObject:contact];
    }
    
    // Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    for (Contact *addressBook in addressBookTemp) {
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
    
    for (Contact *addressBook in addressBookTemp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:addressBook.sectionNumber] addObject:addressBook];
    }
    
    [self.contacts removeAllObjects];
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(fullName)];
        [self.contacts addObject:sortedSection];
    }
}

- (void)getContactListAuthorizationWithCompletion:(void (^)(ABAuthorizationStatus))compBlock {
    
    switch (ABAddressBookGetAuthorizationStatus())
    {
        case  kABAuthorizationStatusAuthorized:
        {
            self.accessRevoked = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchContacts];
                
                compBlock(kABAuthorizationStatusAuthorized);
            });
            
            break;
        }
        case  kABAuthorizationStatusNotDetermined:
        {
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         if (granted)
                                                         {
                                                             shared.accessRevoked = NO;
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [shared fetchContacts];
                                                                 
                                                                 compBlock(kABAuthorizationStatusAuthorized);
                                                             });
                                                             
                                                         }
                                                         else
                                                         {
                                                             shared.accessRevoked = YES;
                                                             
                                                             compBlock(kABAuthorizationStatusDenied);
                                                         }
                                                         
                                                     });
            break;
        }
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        {
            self.accessRevoked = YES;
            
            compBlock(kABAuthorizationStatusDenied);
            
            break;
        }
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Warning", nil)
                                                            message:NSLocalizedString(@"Permission was not granted for Contacts.", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            shared.accessRevoked = YES;
            
            compBlock(kABAuthorizationStatusRestricted);
            
            break;
        }
        default:
            compBlock(kABAuthorizationStatusDenied);
            
            break;
    }
    
}

@end
