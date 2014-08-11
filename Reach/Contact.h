//
//  Contact.h
//  Reach
//
//  Created by Tom Bachant on 12/18/12.
//  Copyright (c) 2012 Thomas Bachant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "Definitions.h"

@interface Contact : NSObject

@property (nonatomic) NSInteger sectionNumber;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSArray *phoneArray;
@property (nonatomic, strong) NSArray *emailArray;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *home;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) UIImage *temporaryImagePlaceholder;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *modifiedAt;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSString *highlightedTag;
@property (nonatomic, strong) NSString *contactId;
@property (nonatomic, strong) NSString *linkedInId;
//@property (nonatomic, strong) NSString *facebookId;
//@property (nonatomic, strong) NSString *twitterId;

@property (nonatomic, assign) ABAddressBookRef originAddressBookRef;

@property (nonatomic, assign) RCContactType type;

+ (Contact *)contactFromAddressBook:(ABAddressBookRef)addressBook;

- (void)saveTag:(NSString *)tag;
- (void)deleteTag:(NSString *)tag;
- (void)saveNotes:(NSString *)notes;
- (void)savePhoto:(UIImage *)img;
- (void)saveLinkedInId:(NSString *)liId;

@end
