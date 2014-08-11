//
//  RCNewContactTableViewController.h
//  Reach
//
//  Created by Tom Bachant on 6/16/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>

#import "JSTokenField.h"

@interface RCNewContactTableViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, JSTokenFieldDelegate>

- (void)clearData;
- (BOOL)hasData;

- (ABRecordRef)getContactRef;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UIButton *userImageButton;

@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UIImageView *phoneImage;

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UIImageView *emailImage;

@property (nonatomic, strong) JSTokenField *tagField;
@property (nonatomic, strong) UIImageView *tagImage;

@property (nonatomic, strong) UITextField *notesField;
@property (nonatomic, strong) UIImageView *notesImage;

@property (nonatomic, strong) UIImage *userImage;

@end
