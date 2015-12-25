//
//  RCOnboardingTableViewController.m
//  Reach
//
//  Created by Tom Bachant on 12/24/15.
//  Copyright © 2015 Tom Bachant. All rights reserved.
//

#import "RCOnboardingTableViewController.h"

@interface RCOnboardingTableViewController ()

@end

@implementation RCOnboardingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contactAccessSwitch = [UISwitch new];
    _notificationAccessSwitch = [UISwitch new];
    
    self.title = @"Get Started";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 120.0f;
    }
    return 5.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Enable contacts";
        cell.detailTextLabel.text = @"This loads your contact list, and never touches a server";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryView = nil;
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = @"Enable reminders";
        cell.detailTextLabel.text = @"This lets us send notifications for reminders that you set";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryView = nil;
    }
    else if (indexPath.section == 2) {
        cell.textLabel.text = @"Finish";
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
    
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
}

@end
