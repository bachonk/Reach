//
//  RCNewContactTableViewController.m
//  Reach
//
//  Created by Tom Bachant on 6/16/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCNewContactTableViewController.h"

#import "AppDelegate.h"

#import "NSString+EmailAddresses.h"

#import "Definitions.h"
#import "Contact.h"

typedef enum {
    RCNewContactRowName = 0,
    RCNewContactRowPhone,
    RCNewContactRowEmail,
    RCNewContactRowTags,
    RCNewContactRowNotes,
    RCNewContactRowLocation
} RCNewContactRow;

static const CGFloat kCellPadding = 14.0f;
static const CGFloat kCellUserImageWidth = 52.0f;
static const CGFloat kCellAccessoryImageWidth = 26.0f;

@interface RCNewContactTableViewController () {
    NSMutableString *phoneNumberFormatted;
    
    UIImagePickerController *imgPicker;
}

- (void)uploadUserPhoto:(id)sender;

- (void)didReceiveLastKnownLocation;

- (void)call;

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation RCNewContactTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(kCellPadding + kCellUserImageWidth + kCellPadding, kCellPadding, CGRectGetWidth(self.tableView.frame) - (kCellPadding * 3) - kCellUserImageWidth, kCellUserImageWidth)];
    _nameField.font = [UIFont boldSystemFontOfSize:20.0f];
    _nameField.placeholder = NSLocalizedString(@"Name", @"");
    _nameField.borderStyle = UITextBorderStyleNone;
    _nameField.backgroundColor = [UIColor clearColor];
    _nameField.delegate = self;
    _nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _nameField.tintColor = COLOR_DEFAULT_RED;
    
    _userImageButton = [[UIButton alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, kCellUserImageWidth, kCellUserImageWidth)];
    [_userImageButton setBackgroundImage:[[UIImage imageNamed:@"user-blank"] imageWithTintColor:COLOR_IMAGE_DEFAULT] forState:UIControlStateNormal];
    _userImageButton.layer.cornerRadius = kCellUserImageWidth / 2;
    _userImageButton.clipsToBounds = YES;
    _userImageButton.contentMode = UIViewContentModeScaleAspectFill;
    [_userImageButton addTarget:self action:@selector(uploadUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect inputFrame = CGRectMake(kCellPadding + kCellAccessoryImageWidth + kCellPadding, kCellPadding, CGRectGetWidth(self.tableView.frame) - (kCellPadding * 3) - kCellAccessoryImageWidth, kCellAccessoryImageWidth);
    
    _phoneField = [[UITextField alloc] initWithFrame:inputFrame];
    _phoneField.font = [UIFont systemFontOfSize:18.0f];
    _phoneField.placeholder = NSLocalizedString(@"Phone", @"");
    _phoneField.borderStyle = UITextBorderStyleNone;
    _phoneField.backgroundColor = [UIColor clearColor];
    _phoneField.delegate = self;
    _phoneField.keyboardType = UIKeyboardTypePhonePad;
    _phoneField.tintColor = COLOR_CALL_GREEN;
    
    _phoneImage = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, kCellAccessoryImageWidth, kCellAccessoryImageWidth)];
    _phoneImage.image = [[UIImage imageNamed:@"phone-home-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    
    _phoneCallButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _phoneCallButton.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) - 68, kCellPadding, 68, kCellAccessoryImageWidth);
    _phoneCallButton.tintColor = COLOR_CALL_GREEN;
    _phoneCallButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_phoneCallButton setTitle:NSLocalizedString(@"Call", @"") forState:UIControlStateNormal];
    _phoneCallButton.alpha = 0.0f;
    [_phoneCallButton addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];
    
    _emailField = [[UITextField alloc] initWithFrame:inputFrame];
    _emailField.font = [UIFont systemFontOfSize:18.0f];
    _emailField.placeholder = NSLocalizedString(@"Email", @"");
    _emailField.borderStyle = UITextBorderStyleNone;
    _emailField.backgroundColor = [UIColor clearColor];
    _emailField.delegate = self;
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailField.tintColor = COLOR_EMAIL_RED;
    
    _emailImage = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, kCellAccessoryImageWidth, kCellAccessoryImageWidth)];
    _emailImage.image = [[UIImage imageNamed:@"email-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    
    _notesField = [[UITextField alloc] initWithFrame:inputFrame];
    _notesField.font = [UIFont systemFontOfSize:18.0f];
    _notesField.backgroundColor = [UIColor clearColor];
    _notesField.placeholder = NSLocalizedString(@"Notes", @"");
    _notesField.borderStyle = UITextBorderStyleNone;
    _notesField.backgroundColor = [UIColor clearColor];
    _notesField.delegate = self;
    _notesField.tintColor = COLOR_DEFAULT_RED;
    
    _notesImage = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, kCellAccessoryImageWidth, kCellAccessoryImageWidth)];
    _notesImage.image = [[UIImage imageNamed:@"notes-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    
    CGRect locationRect = inputFrame;
    locationRect.size.height = 16.0f;
    locationRect.origin.y = 16.0f;
    _locationField = [[UITextField alloc] initWithFrame:locationRect];
    _locationField.font = [UIFont systemFontOfSize:13.0f];
    _locationField.textColor = [UIColor colorWithWhite:0.14f alpha:1.0f];
    _locationField.backgroundColor = [UIColor clearColor];
    _locationField.placeholder = NSLocalizedString(@"Location", @"");
    _locationField.borderStyle = UITextBorderStyleNone;
    _locationField.backgroundColor = [UIColor clearColor];
    _locationField.delegate = self;
    _locationField.tintColor = COLOR_DEFAULT_RED;
    
    _locationImage = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, kCellAccessoryImageWidth, kCellAccessoryImageWidth)];
    _locationImage.image = [[UIImage imageNamed:@"location-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    
    CGRect mapRect = inputFrame;
    mapRect.size.height = 160.0f;
    mapRect.origin.y = 42.0f;
    _locationMap = [[MKMapView alloc] initWithFrame:mapRect];
    _locationMap.userInteractionEnabled = NO;
    
    inputFrame.origin.y = 14.0f;
    inputFrame.origin.x = inputFrame.origin.x - 3;
    _tagField = [[JSTokenField alloc] initWithFrame:inputFrame];
    _tagField.textField.font = _emailField.font;
    _tagField.textField.placeholder = NSLocalizedString(@"Tags", nil);
    _tagField.textField.tintColor = COLOR_TAG_BLUE;
    _tagField.delegate = self;
    
    _tagImage = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, kCellAccessoryImageWidth, kCellAccessoryImageWidth)];
    _tagImage.image = [[UIImage imageNamed:@"tag-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    
    // Listen for location changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLastKnownLocation)
                                                 name:kNotificationDidUpdateLocation
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)prepareForNewContact {
    [self clearData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // For some reason, the name field isn't immediately available
        [_nameField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (![CLLocationManager locationServicesEnabled]) {
            [delegate.locationManager requestWhenInUseAuthorization];
        }
        else {
            [delegate.locationManager startUpdatingLocation];
        }
    });
}

- (void)clearData {
    _nameField.text = nil;
    _phoneField.text = nil;
    _emailField.text = nil;
    _notesField.text = nil;
    _userImage = nil;
    [_userImageButton setBackgroundImage:[[UIImage imageNamed:@"user-blank"] imageWithTintColor:COLOR_IMAGE_DEFAULT] forState:UIControlStateNormal];
    [_tagField removeAllTokens];
    
    [self.tableView reloadData];
}

- (BOOL)hasData {
    return [_nameField.text length] || [_phoneField.text length] || [_emailField.text length] || [_tagField.tokens count] || _userImage;
}

- (ABRecordRef)getContactRef {
    ABRecordRef person = ABPersonCreate(); // create a person
    CFErrorRef error = NULL;
    
    // Phone number is a multivalue
    if ([_phoneField.text length]) {
        ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)(_phoneField.text),kABPersonPhoneMobileLabel, NULL);
        
        ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, &error);
        
    }
    
    // Email is also a multivalue
    if ([_emailField.text length]) {
        ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
        ABMultiValueAddValueAndLabel(emailMultiValue ,(__bridge CFTypeRef)(_emailField.text),kABHomeLabel, NULL);
        
        ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, &error);
    }
    
    // Set name
    NSString *nameString = _nameField.text;
    if ([nameString length]) {
        NSArray *comps = [nameString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSMutableString *firstName = [NSMutableString stringWithString:@""];
        
        if ([comps count] == 1) {
            
            [firstName appendString:nameString];
            
        }
        if ([comps count] >= 2) {
            
            for (int i = 0; i < [comps count] - 1; i++) {
                if ([firstName length]) {
                    [firstName appendString:@" "];
                }
                [firstName appendString:comps[i]];
            }
            
            NSString *lastName = comps[[comps count] - 1];
            
            // Set last name
            ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName) , nil);
            
        }
        
        // Set first name
        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName) , nil);
        
    }
    
    // Set image
    if (_userImage) {
        NSData *imgData = UIImagePNGRepresentation(_userImage);
        CFErrorRef *error = NULL;
        ABPersonSetImageData(person, (__bridge CFDataRef)imgData, error);
    }
    
    // Set notes & tags
    NSMutableString *notesString = [NSMutableString stringWithString:_notesField.text ?: @""];
    
    [notesString appendString:kContactMetadataSeparator];
    
    NSMutableArray *tags = [NSMutableArray new];
    for (UIButton *tag in _tagField.tokens) {
        if ([tag.titleLabel.text length]) {
            [tags addObject:[[tag.titleLabel.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
    NSDictionary *meetingDict;
    if ([_locationField.text length]) {
        // Stores meeting location
        
        meetingDict = @{
                        kContactLocationAddressKey: _locationField.text,
                        kContactLocationCoordinateKey: @[ [NSNumber numberWithDouble:_coordinate.latitude], [NSNumber numberWithDouble:_coordinate.longitude] ]
                        };
        
    }
    
    NSDictionary *metadata = @{
                               kContactTagsKey: tags,
                               kContactPersonalAddressKey: @{},
                               kContactMeetingLocationKey: meetingDict ?: @{}
                               };
    
    NSError *err;
    NSData *metadataDataRep = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:&err];
    
    if (!err) {
        NSString *metadataStringRep = [[NSString alloc] initWithData:metadataDataRep encoding:NSUTF8StringEncoding];
        [notesString appendString:@"\n"];
        [notesString appendString:metadataStringRep];
    }
    
    ABRecordSetValue(person, kABPersonNoteProperty, (__bridge CFTypeRef)(notesString) , nil);
    
    return person;
}

- (void)call {
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _phoneField.text]]];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:5082085888"]]];
    
    [RCExternalRequestHandler call:_phoneField.text completionHandler:nil];
}

- (void)uploadUserPhoto:(id)sender {
    [self.view endEditing:YES];
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"Set contact photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Existing", nil];
    [ac showInView:self.view];
}

- (void)didReceiveLastKnownLocation {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _locationField.text = delegate.lastLocationDescription;
    _coordinate = delegate.locationManager.location.coordinate;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0065, 0.0065);
    MKCoordinateRegion region = MKCoordinateRegionMake(delegate.locationManager.location.coordinate, span);
    [_locationMap setRegion:region];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[UIScreen mainScreen] bounds].size.height > 520 ? 6 : 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        return 78.0f;
    }
    
    if (indexPath.row == RCNewContactRowLocation) {
        return 54.0f + 160.0f;
    }
    
    return 54.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *nameCellID = @"newCellID";
    static NSString *phoneCellID = @"phoneCellID";
    static NSString *emailCellID = @"emailCellID";
    static NSString *tagsCellID = @"tagCellID";
    static NSString *notesCellID = @"notesCellID";
    static NSString *locCellID = @"locCellID";
    
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case RCNewContactRowName:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:nameCellID];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameCellID];
                
                [cell.contentView addSubview:_userImageButton];
                [cell.contentView addSubview:_nameField];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            break;
        }
        case RCNewContactRowPhone:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:phoneCellID];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCellID];
                
                [cell.contentView addSubview:_phoneImage];
                [cell.contentView addSubview:_phoneField];
                [cell.contentView addSubview:_phoneCallButton];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            break;
        }
        case RCNewContactRowEmail:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:emailCellID];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emailCellID];
                
                [cell.contentView addSubview:_emailImage];
                [cell.contentView addSubview:_emailField];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            break;
        }
        case RCNewContactRowTags:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:tagsCellID];
            
            if (cell == nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tagsCellID];
                
                [cell.contentView addSubview:_tagImage];
                [cell.contentView addSubview:_tagField];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            break;
        }
        case RCNewContactRowNotes:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:notesCellID];
            
            if (cell == nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notesCellID];
                
                [cell.contentView addSubview:_notesImage];
                [cell.contentView addSubview:_notesField];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            break;
        }
        case RCNewContactRowLocation:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:locCellID];
            
            if (cell == nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locCellID];
                
                [cell.contentView addSubview:_locationImage];
                [cell.contentView addSubview:_locationField];
                [cell.contentView addSubview:_locationMap];
                
                // Add circle indicator surrounding location
                UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
                indicatorView.layer.cornerRadius = CGRectGetHeight(indicatorView.frame) / 2;
                indicatorView.layer.borderColor = [[COLOR_DEFAULT_RED colorWithAlphaComponent:0.4f] CGColor];
                indicatorView.layer.borderWidth = 21.0f;
                indicatorView.center = _locationMap.center;
                [cell.contentView addSubview:indicatorView];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            break;
        }
        default:
            break;
    }
        
    return cell;
    
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case RCNewContactRowName:
        {
            [_nameField becomeFirstResponder];
            break;
        }
        case RCNewContactRowPhone:
        {
            [_phoneField becomeFirstResponder];
            break;
        }
        case RCNewContactRowEmail:
        {
            [_emailField becomeFirstResponder];
            break;
        }
        case RCNewContactRowTags:
        {
            [_tagField becomeFirstResponder];
            break;
        }
        case RCNewContactRowNotes:
        {
            [_notesField becomeFirstResponder];
            break;
        }
        case RCNewContactRowLocation:
        {
            [_locationField becomeFirstResponder];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == _phoneField) {
        _phoneImage.image = [[UIImage imageNamed:@"phone-home-active"] imageWithTintColor:COLOR_CALL_GREEN];
    }
    else if (textField == _emailField) {
        _emailImage.image = [[UIImage imageNamed:@"email-active"] imageWithTintColor:COLOR_EMAIL_RED];
    }
    else if (textField == _notesField) {
        _notesImage.image = [[UIImage imageNamed:@"notes-active"] imageWithTintColor:COLOR_DEFAULT_RED];
    }
    else if (textField == _locationField) {
        _locationImage.image = [[UIImage imageNamed:@"location-active"] imageWithTintColor:COLOR_DEFAULT_RED];
        [_locationField selectAll:nil];
    }
        
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == _phoneField) {
        _phoneImage.image = [[UIImage imageNamed:@"phone-home-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    }
    else if (textField == _emailField) {
        _emailImage.image = [[UIImage imageNamed:@"email-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    }
    else if (textField == _notesField) {
        _notesImage.image = [[UIImage imageNamed:@"notes-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    }
    else if (textField == _locationField) {
        _locationImage.image = [[UIImage imageNamed:@"location-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _nameField) {
        [_phoneField becomeFirstResponder];
    }
    else if (textField == _phoneField) {
        [_emailField becomeFirstResponder];
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _phoneField) {
        
        // Semi-international support
        if ([_phoneField.text length] && [[_phoneField.text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"+"]) {
            return YES;
        }
        
        if ([[_phoneField.text substringWithRange:range] isEqualToString:@"-"] ||
            [[_phoneField.text substringWithRange:range] isEqualToString:@"("] ||
            [[_phoneField.text substringWithRange:range] isEqualToString:@")"] ||
            [[_phoneField.text substringWithRange:range] isEqualToString:@" "]) {
            return YES;
        }
        
        NSString *phoneNumberDigits = [[[[[_phoneField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
        
        if ([phoneNumberDigits length] == 1 && [[phoneNumberDigits substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"]) {
            return NO;
        }
        
        if (phoneNumberFormatted == nil) {
            phoneNumberFormatted = [[NSMutableString alloc] init];
        }
        
        [phoneNumberFormatted setString:phoneNumberDigits];
        
        if ([phoneNumberFormatted length] >= 6) {
            [phoneNumberFormatted insertString:@"-" atIndex:6];
            [phoneNumberFormatted insertString:@") " atIndex:3];
            [phoneNumberFormatted insertString:@"(" atIndex:0];
        } else if ([phoneNumberFormatted length] >= 3) {
            [phoneNumberFormatted insertString:@") " atIndex:3];
            [phoneNumberFormatted insertString:@"(" atIndex:0];
        }
        
        _phoneField.text = phoneNumberFormatted;
        
        // Conditionally show or hide call button
        if ([phoneNumberFormatted length] && !_phoneCallButton.alpha) {
            [UIView animateWithDuration:0.32 animations:^{
                _phoneCallButton.alpha = 1.0f;
            }];
        }
        else if (![phoneNumberFormatted length] && _phoneCallButton.alpha) {
            [UIView animateWithDuration:0.32 animations:^{
                _phoneCallButton.alpha = 0.0f;
            }];
        }
        
        return NO;
    }
    else if (textField == _emailField) {
        
        NSString *currentText = [_emailField.text stringByReplacingCharactersInRange:range withString:string];
        
        if ([currentText rangeOfString:@"@"].location != NSNotFound) {
            // Run the correction
            _emailField.text = [currentText stringByCorrectingEmailTypos];;
            return NO;
            
        }
        
    }
    
    return YES;
}

#pragma mark - Token Field Delegate

- (void)tokenFieldDidBeginEditing:(JSTokenField *)tokenField {
    _tagImage.image = [[UIImage imageNamed:@"tag-active"] imageWithTintColor:COLOR_TAG_BLUE];
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField {
    _tagImage.image = [[UIImage imageNamed:@"tag-active"] imageWithTintColor:COLOR_IMAGE_DEFAULT];
}

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
    _tagField.textField.placeholder = nil;
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{
    if (![_tagField.tokens count]) {
        _tagField.textField.placeholder = NSLocalizedString(@"Tags", nil);
    }
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    NSMutableString *recipient = [NSMutableString string];
	
	NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
    NSString *rawStr = [[tokenField textField] text];
	for (int i = 0; i < [rawStr length]; i++)
	{
		if (![charSet characterIsMember:[rawStr characterAtIndex:i]])
		{
			[recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
		}
	}
    
    if ([rawStr length])
	{
		[tokenField addTokenWithTitle:rawStr representedObject:recipient];
	}
    
    tokenField.textField.text = nil;
    
    return NO;
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self.view endEditing:YES];
    
    if (buttonIndex == 0) {
        // camera
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            if (imgPicker == nil) {
                imgPicker = [[UIImagePickerController alloc] init];
            }
            imgPicker.delegate = self;
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.viewController presentViewController:imgPicker animated:YES completion:nil];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"No Camera Available" message:@"Sorry, but it looks like your device does not have a camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
    } else if (buttonIndex == 1) {
        // existing
        
        if (imgPicker == nil) {
            imgPicker = [[UIImagePickerController alloc] init];
        }
        imgPicker.delegate = self;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.viewController presentViewController:imgPicker animated:YES completion:nil];
        
    }
}

#pragma mark -
#pragma mark Image Picker Delegation

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.viewController dismissViewControllerAnimated:YES completion:nil];
    
    [_nameField becomeFirstResponder];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    // Compress image
    float actualHeight = img.size.height;
    float actualWidth = img.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 640.0/960.0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 960.0 / actualHeight;
            actualWidth = ceilf(imgRatio * actualWidth);
            actualHeight = 960.0;
        }
        else{
            imgRatio = 640.0 / actualWidth;
            actualHeight = ceilf(imgRatio * actualHeight);
            actualWidth = 640.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [img drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Store the image
    _userImage = image;
    [_userImageButton setBackgroundImage:_userImage forState:UIControlStateNormal];
    
}


@end
