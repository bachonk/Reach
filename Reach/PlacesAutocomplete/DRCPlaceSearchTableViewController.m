//
//  DRCPlaceSearchTableViewController.m
//  DashrideClientTemplate
//
//  Created by Tom Bachant on 10/29/14.
//  Copyright (c) 2014 Dashride. All rights reserved.
//

#import "DRCPlaceSearchTableViewController.h"

#define CELL_BACKGROUND_COLOR [UIColor colorWithWhite:0.98f alpha:1.0f]

@interface DRCPlaceSearchTableViewController ()

@end

@implementation DRCPlaceSearchTableViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    results = [[NSMutableArray alloc] init];
    errorDescription = [[NSString alloc] init];
    
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]) - 100, 22)];
    searchField.textAlignment = NSTextAlignmentLeft;
    searchField.font = [UIFont boldSystemFontOfSize:16.0f];
    searchField.textColor = [UIColor blackColor];
    searchField.delegate = self;
    searchField.placeholder = @"Search for address...";
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(CGRectGetMaxX(searchField.frame) - 20, CGRectGetMidY(searchField.frame));
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator stopAnimating]; // just in case
    
    searchField.rightView = activityIndicator;
    searchField.rightViewMode = UITextFieldViewModeAlways;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchField];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [searchField becomeFirstResponder];
}

#pragma mark - Actions

- (void)cancel {
    [delegate placeSearchViewControllerDidCancel:self];
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *term = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([term length] < 3) {
        return YES;
    }
    
    [activityIndicator startAnimating];
    [Geocoder searchForAddress:term results:^(NSArray *places, NSError *error) {
        // Hop back on the main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            [results removeAllObjects];
            errorDescription = @"";
            
            if (!error) {
                [results addObjectsFromArray:places];
            }
            else {
                // No results
                
                // If choosing start location, mandate that the start location is valid
                // If choosing destination, they can just choose a place with a name and no location
                
                if (self.tag == TAG_DROPOFF) {
                    // Create fake entry to display for custom address
                    NSDictionary *customPlace = [NSDictionary dictionaryWithObjectsAndKeys:term, @"description", nil];
                    [results addObject:customPlace];
                }
                else {
                    errorDescription = [error.userInfo objectForKey:@"geocode_error"];
                }
                
            }
            
            [self.tableView reloadData];
            [activityIndicator stopAnimating];
        });
        
    }];
    
    return YES;
}

#pragma mark - Table view

/****
  Table layout
 
 0:
    Results if available, otherwise past locations
 
 1:
    Google footer
 
 ****/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        if (errorDescription.length) {
            return 0;
        }
        return [results count];
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && [errorDescription length]) {
        return 152.0f;
    }
    if (section == 1 && ![results count] && ![errorDescription length] ) {
        return 28.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && [errorDescription length]) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 152.0f)];
        v.backgroundColor = [UIColor clearColor];
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, CGRectGetWidth(v.frame) - 60, 80.0f)];
        desc.backgroundColor = v.backgroundColor;
        desc.font = [UIFont systemFontOfSize:18.0f];
        desc.textAlignment = NSTextAlignmentCenter;
        desc.numberOfLines = 0;
        desc.text = errorDescription;
        [v addSubview:desc];
        
        return v;
    }
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 0.5f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return [[UIView alloc] init];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        cell.backgroundColor = [UIColor clearColor];
    } else {
        cell.backgroundColor = CELL_BACKGROUND_COLOR;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    static NSString *googleID = @"googleID";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 1) {
        // Google attribution
        
        cell = [tableView dequeueReusableCellWithIdentifier:googleID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:googleID];
            
            UIImageView *poweredByElGoog = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 104, 16)];
            poweredByElGoog.image = [UIImage imageNamed:@"powered-by-google-on-white.png"];
            [cell.contentView addSubview:poweredByElGoog];
            
            poweredByElGoog.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2, cell.contentView.center.y);
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0f];
            cell.detailTextLabel.backgroundColor = CELL_BACKGROUND_COLOR;
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
        
        NSDictionary *entry = [results objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [entry objectForKey:@"description"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [results count]) {
        __block NSDictionary *entry = [results objectAtIndex:indexPath.row];
        
        // First, check if it's a custom location
        // If it not a google place, it will not be able to be geocoded
        if (![entry objectForKey:@"place_id"]) {
            [delegate placeSearchViewController:self didReturnPlace:[entry objectForKey:@"description"] location:CLLocationCoordinate2DMake(0, 0)];
            return;
        }
        
        // Selected a place. Geocode the address
        [Geocoder geocodeAddressIdentifier:[entry objectForKey:@"place_id"] result:^(CLLocationCoordinate2D coord, NSError *error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Geocoder threw us off the main thread, so let's get back on there!

                if (!error) {
                    
                    NSString *address = entry[@"description"];
                    
                    // Send to delegate
                    [delegate placeSearchViewController:self
                                         didReturnPlace:address
                                               location:coord];
                }
                else {
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error Making Selection" message:[NSString stringWithFormat:@"Please try again. Error: %@", [error.userInfo objectForKey:@"geocode_error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [al show];
                }
            });
            
        }];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [searchField resignFirstResponder];
}

@end
