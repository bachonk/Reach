//
//  Contact.m
//  Reach
//
//  Created by Tom Bachant on 12/18/12.
//  Copyright (c) 2012 Thomas Bachant. All rights reserved.
//

#import "Contact.h"

#import "Definitions.h"

@interface Contact ()

- (void)saveNotesAndTags;

@end

@implementation Contact

+ (Contact *)contactFromAddressBook:(ABAddressBookRef)person {
    
    // Get First Name and Last Name
    
    Contact *contact = [Contact new];
    
    contact.originAddressBookRef = person;
    
    contact.type = RCContactTypePhoneContact;
    
    contact.firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    contact.lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    if (!contact.firstName) {
        contact.firstName = @"";
    }
    if (!contact.lastName) {
        contact.lastName = @"";
    }
    
    contact.fullName = [contact.firstName length] && [contact.lastName length] ? [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName] : [NSString stringWithFormat:@"%@%@", contact.firstName, contact.lastName];
    
    // Get contacts picture, if pic doesn't exists, show standart one
    
    NSData  *imgData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
    contact.thumbnail = [UIImage imageWithData:imgData];
    
    // Get Phone Numbers
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    
    ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
        
        NSString *phoneNumberUnformatted = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multiPhones, i);
        
        NSString *phoneNumberFormatted = [phoneNumberUnformatted formattedPhoneNumber];
        
        NSString *descriptionString = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(multiPhones, i);
        descriptionString = [[descriptionString stringByReplacingOccurrencesOfString:@"_$!<" withString:@""] stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
        
        if ([descriptionString isEqualToString:@"Mobile"] ||
            [descriptionString isEqualToString:@"iPhone"] ||
            [descriptionString isEqualToString:@"Main"]) {
            // Mobile phone
            
            contact.mobile = phoneNumberFormatted;
            
        } else {
            // Treat as home phone
            
            contact.home = phoneNumberFormatted;
            
        }
        
        if (phoneNumberFormatted && descriptionString) {
            [phoneNumbers addObject:@{descriptionString: phoneNumberFormatted}];
        }
        
    }
    
    contact.phoneArray = phoneNumbers;
    
    // Get Contact email
    
    NSMutableArray *contactEmails = [NSMutableArray new];
    ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
        CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
        NSString *contactEmail = (__bridge NSString *)contactEmailRef;
        
        [contactEmails addObject:contactEmail];
        
    }
    
    contact.emailArray = contactEmails;
    if ([contactEmails count])
        contact.email = contactEmails[0];
    
    // Get notes & tags
    
    contact.notes = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
    
    if (contact.notes && [contact.notes length]) {
        NSArray *notesAndTags = [contact.notes componentsSeparatedByString:kContactTagSeparator];
        contact.notes = [notesAndTags count] ? notesAndTags[0] : @"";
        
        contact.tags = [NSMutableArray array];
        if ([notesAndTags count] == 2) {
            NSArray *tagsRaw = [notesAndTags[1] componentsSeparatedByString:@"#"];
            for (NSString *tag in tagsRaw) {
                [contact.tags addObject:[tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
        }
    } else {
        contact.notes = @"";
        contact.tags = [NSMutableArray array];
    }
    
    // Get contact id
    
    ABRecordID recordId = ABRecordGetRecordID(person);
    contact.contactId = [NSString stringWithFormat:@"%d",recordId];
    
    // Get LinkedIn id
    
    ABMultiValueRef socialApps = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
    
    CFIndex thisSocialAppCount = ABMultiValueGetCount(socialApps);
    
    for (int i = 0; i < thisSocialAppCount; i++)
    {
        NSDictionary *socialItem = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(socialApps, i);
        NSString *name = [socialItem objectForKey:(NSString *)kABPersonSocialProfileServiceKey];
        if ([name isEqualToString:@"linkedin"]) {
            contact.linkedInId = [socialItem objectForKey:(NSString *)kABPersonSocialProfileUsernameKey];
        }
        /*else if ([name isEqualToString:@"twitter"]) {
            contact.twitterId = [socialItem objectForKey:(NSString *)kABPersonSocialProfileUsernameKey];
        } 
        else if ([name isEqualToString:@"facebook"]) {
            contact.facebookId = [socialItem objectForKey:(NSString *)kABPersonSocialProfileUsernameKey];
        }
         */
    }
    
    if (socialApps != Nil)
        CFRelease(socialApps);
    
    // Get Created/Modified Date
    
    CFTypeRef creationDate = ABRecordCopyValue(person, kABPersonCreationDateProperty);
    contact.createdAt = (__bridge NSDate*)creationDate;
    
    CFTypeRef modifyDate = ABRecordCopyValue(person, kABPersonModificationDateProperty);
    contact.modifiedAt = (__bridge NSDate*)modifyDate;
    
    return contact;
}

#pragma mark - Methods

- (void)saveNotes:(NSString *)notes {
    self.notes = notes;
    [self saveNotesAndTags];
}

- (void)saveTag:(NSString *)tag {
    [self.tags addObject:tag];
    [self saveNotesAndTags];
}

- (void)deleteTag:(NSString *)tag {
    [self.tags removeObject:tag];
    [self saveNotesAndTags];
}

#pragma mark Save to address book

- (void)saveNotesAndTags {
    // Set notes & tags
    NSMutableString *notesString = [NSMutableString stringWithString:self.notes];
    
    if ([self.tags count]) {
        // Has tags
        
        [notesString appendString:kContactTagSeparator];
        
        for (NSString *tag in self.tags) {
            if ([tag length]) {
                [notesString appendFormat:@"#%@ ", [tag lowercaseString]];
            }
        }
        
    }
    ABRecordSetValue(self.originAddressBookRef, kABPersonNoteProperty, (__bridge CFTypeRef)(notesString) , nil);
    
}

- (void)savePhoto:(UIImage *)img {

    self.thumbnail = img;
    
    NSData *imgData = UIImagePNGRepresentation(img);
    CFDataRef imgDataRef = (__bridge CFDataRef)imgData;
    ABPersonSetImageData(self.originAddressBookRef, imgDataRef, nil);
    
}

- (void)saveLinkedInId:(NSString *)liId {
    
    self.linkedInId = liId;
    
    /*
    ABMultiValueRef socialApps = ABRecordCopyValue(self.originAddressBookRef, kABPersonSocialProfileProperty);
    
    CFIndex thisSocialAppCount = ABMultiValueGetCount(socialApps);
    
    for (int i = 0; i < thisSocialAppCount; i++)
    {
        //NSDictionary *socialItem = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(socialApps, i);
        //NSString *name = [socialItem objectForKey:(NSString *)kABPersonSocialProfileServiceKey];
        //if ([name isEqualToString:@"linkedin"]) {
        //    self.linkedInId = [socialItem objectForKey:(NSString *)kABPersonSocialProfileUsernameKey];
        //}
    }
    
    if (socialApps != Nil)
        CFRelease(socialApps);
     */
    
}

@end