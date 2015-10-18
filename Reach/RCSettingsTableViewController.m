//
//  RCSettingsTableViewController.m
//  Reach
//
//  Created by Tom Bachant on 4/19/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCSettingsTableViewController.h"


static const NSString *kAppStoreLink = @"";

@interface RCSettingsTableViewController ()

- (void)share;

- (void)sendFeedback;

- (void)followTwitter;

- (void)openTutorial;

- (void)viewAbout;

- (void)rateInAppStore;

@end

@implementation RCSettingsTableViewController

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
    
    self.title = @"Settings";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Table view data source

/*****************
 *
 * 0 :
 *      Tutorial
 *      Tips & Tricks
 *      Send Feedback
 *      Share
 *
 * 1 :
 *      Rate
 *      About
 *
 *****************/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 2;
            break;
        
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60.0f;
    }
    
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 160.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 160)];
        mainView.backgroundColor = self.tableView.backgroundColor;
        
        UIImageView *companyLogo = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.tableView.frame) - 280) / 2, 40, 280, 80)];
        companyLogo.image = [UIImage imageNamed:@"settings-logo"];
        
        [mainView addSubview:companyLogo];
        
        return mainView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 104.0f;
    }
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 104)];
        v.backgroundColor = self.tableView.backgroundColor;
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(v.bounds) - 40, 50)];
        mainLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
        mainLabel.font = [UIFont systemFontOfSize:14];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        mainLabel.numberOfLines = 2;
        mainLabel.backgroundColor = v.backgroundColor;
        mainLabel.text = [NSString stringWithFormat:@"v%@\n© 2014 Thomas Bachant", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        
        UIButton *followButton = [UIButton buttonWithType:UIButtonTypeSystem];
        followButton.frame = CGRectMake(CGRectGetMinX(mainLabel.frame), CGRectGetMaxY(mainLabel.frame) + 8, CGRectGetWidth(mainLabel.frame), 18);
        followButton.tintColor = COLOR_TEXT_BLUE;
        [followButton setTitle:@"Follow me on Twitter for Updates" forState:UIControlStateNormal];
        [followButton addTarget:self action:@selector(followTwitter) forControlEvents:UIControlEventTouchUpInside];
        
        [v addSubview:mainLabel];
        [v addSubview:followButton];
        
        return v;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    switch (indexPath.section) {
        case 0: {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Tutorial";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Send Feedback";
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Share";
            }
            
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        }
        case 1: {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"About Reach";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Rate in App Store";
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            
            if (indexPath.row == 0) {
                [self openTutorial];
            } else if (indexPath.row == 1) {
                [self sendFeedback];
            } else if (indexPath.row == 2) {
                [self share];
            }
            
            break;
        }
        case 1: {
            
            if (indexPath.row == 0) {
                [self viewAbout];
            } else if (indexPath.row == 1) {
                [self rateInAppStore];
            }
            
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Actions

- (void)share
{
    
    NSString *shareText = NSLocalizedString(@"Check out the Reach contact list app", nil);
    UIActivityViewController *actSheet = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"%@: %@", shareText, kAppStoreLink], [UIImage imageNamed:@"sample"]] applicationActivities:nil];
    actSheet.completionHandler = (UIActivityViewControllerCompletionHandler)^(NSString *activityType, BOOL completed) {
        
        if (completed) {
            [MNMToast showWithText:NSLocalizedString(@"Thanks for sharing :)", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
        }
        
    };

    [self presentViewController:actSheet animated:YES completion:nil];
}

- (void)sendFeedback
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        [composer setToRecipients:[NSArray arrayWithObject:@"bachonk@gmail.com"]];
        composer.mailComposeDelegate = self;
        composer.navigationBar.tintColor = COLOR_DEFAULT_RED;
        composer.navigationBar.barTintColor = [UIColor whiteColor];
        
        [self presentViewController:composer animated:YES completion:^{
            
        }];
        
    } else {
        // Can't send email
        
        [MNMToast showWithText:NSLocalizedString(@"Emailing not available on this device :(", nil) autoHidding:YES priority:MNMToastPriorityNormal completionHandler:nil tapHandler:nil];
    }
}

- (void)openTutorial
{
    RCTutorialViewController *tut = [[RCTutorialViewController alloc] init];
    [self presentViewController:tut animated:YES completion:nil];
}

- (void)viewAbout
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://coincidentalcode.com"]];
}

- (void)followTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=bachonk"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/bachonk"]];
    }
}

- (void)rateInAppStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/reach-your-contact-list/id898802540?ls=1&mt=8"]];
}

#pragma mark - Mail Compose Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
