//
//  RCListSelectorTableViewController.m
//  Reach
//
//  Created by Tom Bachant on 8/4/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCListSelectorTableViewController.h"
#import "RCSettingsTableViewController.h"
#import "LinkedInManager.h"

@interface RCListSelectorTableViewController ()

- (void)loadContacts;

@end

@implementation RCListSelectorTableViewController

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
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    titleButton.frame = CGRectMake(0, 0, 70, 44);
    [titleButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setBackgroundImage:[[UIImage imageNamed:@"header-logo.png"] imageWithTintColor:COLOR_DEFAULT_RED] forState:UIControlStateNormal];
    [self.navigationItem setTitleView:titleButton];
    
    UIBarButtonItem *barBut = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(openSettings)];
    self.navigationItem.leftBarButtonItem = barBut;
    
    UIBarButtonItem *closeBut = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = closeBut;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Settings

- (void)openSettings {
    RCSettingsTableViewController *settings = [[RCSettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settings animated:YES];
}

#pragma mark - Close

- (void)close {
    [_delegate listSelectorDidChooseType:_selectedType];
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    if (indexPath.row == 0) {
        
        // Phone
        
        cell.textLabel.text = NSLocalizedString(@"Phone Contacts", nil);
        
        cell.detailTextLabel.text = nil;

        cell.imageView.image = [UIImage imageNamed:@"icon-phone.png"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else if (indexPath.row == 1) {
        
        // LinkedIn
        
        cell.textLabel.text = @"LinkedIn";
        
        cell.imageView.image = [UIImage imageNamed:@"icon-linkedin"];
        
        if (_loading) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [indicator startAnimating];
            cell.accessoryView = indicator;
            
            cell.detailTextLabel.text = [[LinkedInManager shared] isAuthorized] ? nil : NSLocalizedString(@"Updating", nil);
            
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryView = nil;
            
            cell.detailTextLabel.text = [[LinkedInManager shared] isAuthorized] ? nil : NSLocalizedString(@"Connect", nil);
            
        }
    }
    
    if (indexPath.row == (NSInteger)_selectedType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.indentationLevel = 1;
    cell.indentationWidth = -20.0f;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [_delegate listSelectorDidChooseType:RCContactTypePhoneContact];
    }
    else if (indexPath.row == 1 && !_loading) {
        
        if ([[LinkedInManager shared] isAuthorized]) {
            if ([[LinkedInManager shared].contacts count]) {
                [_delegate listSelectorDidChooseType:RCContactTypeLinkenIn];
            } else {
                [self loadContacts];
            }
        }
        else {
            [[LinkedInManager shared] getLinkedInAccessFromViewController:self completion:^(BOOL success, NSError *error) {
                if (success) {
                    [self loadContacts];
                } else {
                    // Error
                    NSLog(@"Error occurred");
                }
            }];
        }
        
    }
}

#pragma mark - Loading

- (void)loadContacts {
    
    _loading = YES;
    [self.tableView reloadData];
    
    [[LinkedInManager shared] getContactsWithCompletion:^(NSArray *results, NSError *error) {
        
        if (!error) {
            
            _selectedType = RCContactTypeLinkenIn;
            
            _loading = NO;
            [self.tableView reloadData];
            
            [_delegate listSelectorDidChooseType:RCContactTypeLinkenIn];
            
        } else {
            // Error occurred
            NSLog(@"Error occurred");
            
            [[LinkedInManager shared] getLinkedInAccessFromViewController:self completion:^(BOOL success, NSError *error) {
                
                _loading = NO;
                
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error Authenticating" message:@"Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
                else {
                    _selectedType = RCContactTypeLinkenIn;
                    
                }
                
                [self.tableView reloadData];
                
            }];
            
        }
    }];
}

@end
