//
//  RCRemindListTableViewController.m
//  Reach
//
//  Created by Tom Bachant on 10/22/15.
//  Copyright © 2015 Tom Bachant. All rights reserved.
//

#import "RCRemindListTableViewController.h"
#import "RCContactManager.h"
#import "TTTTimeIntervalFormatter.h"
#import "RCExternalRequestHandler.h"

static const CGFloat kButtonWidth = 50.0f;
static const CGFloat kButtonPadding = 9.0f;

#define TAG_BUTTON_OFFSET 10

@interface RCRemindListTableViewController ()

- (void)hide;

- (void)didTapCallButton:(id)sender;
- (void)didTapTextButton:(id)sender;

@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) TTTTimeIntervalFormatter *formatter;

@end

@implementation RCRemindListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Reminders", nil);
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(hide)];
    
    self.tableView.backgroundColor = COLOR_TABLE_CELL;
    
    _notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    _formatter = [[TTTTimeIntervalFormatter alloc] init];
    _formatter.usesIdiomaticDeicticExpressions = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)hide {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapCallButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    NSInteger tag = button.tag;
    
    if (tag >= TAG_BUTTON_OFFSET) {
        // Call
        NSInteger index = tag - TAG_BUTTON_OFFSET;
        NSNotification *notif = _notifications[index];
        NSString *contactId = notif.userInfo[kLocalNotificationUserInfoUserID];
        
        Contact *contact = [[RCContactManager shared] contactFromId:contactId];
        NSDictionary *phone = contact.phoneArray[index];
        NSString *label = [phone allKeys][0];
        NSString *value = [phone objectForKey:label];
        
        [RCExternalRequestHandler call:value completionHandler:nil];
        
    }
}

- (void)didTapTextButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    NSInteger tag = button.tag;
    
    if (tag >= TAG_BUTTON_OFFSET) {
        // Text
        NSInteger index = tag - TAG_BUTTON_OFFSET;
        NSNotification *notif = _notifications[index];
        NSString *contactId = notif.userInfo[kLocalNotificationUserInfoUserID];
        
        Contact *contact = [[RCContactManager shared] contactFromId:contactId];
        NSDictionary *phone = contact.phoneArray[index];
        NSString *label = [phone allKeys][0];
        NSString *value = [phone objectForKey:label];
        
        [RCExternalRequestHandler text:value delegate:nil presentationHandler:^(BOOL shown) {
            
        } completionHandler:^(BOOL completed) {
            
        }];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_notifications count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kButtonPadding + kButtonWidth + kButtonPadding;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = COLOR_TABLE_CELL;
    cell.contentView.backgroundColor = COLOR_TABLE_CELL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"CellID";
    
    RCContactDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[RCContactDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        
        cell.defaultCellBackgroundColor = [UIColor clearColor];
        
        cell.buttonRight.layer.cornerRadius = kButtonWidth / 2;
        cell.buttonRight.clipsToBounds = YES;
        cell.buttonRight.layer.borderWidth = 1.0f;
        [cell.buttonRight addTarget:self action:@selector(didTapTextButton:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.buttonLeft.layer.cornerRadius = kButtonWidth / 2;
        cell.buttonLeft.clipsToBounds = YES;
        [cell.buttonLeft addTarget:self action:@selector(didTapCallButton:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.mainLabel.frame = CGRectMake(12, 18, 200, 27);
        cell.mainLabel.backgroundColor = [UIColor clearColor];
        cell.mainLabel.font = [UIFont systemFontOfSize:20.0f];
        cell.mainLabel.textColor = [UIColor blackColor];
        cell.mainLabel.textAlignment = NSTextAlignmentLeft;
        cell.mainLabel.adjustsFontSizeToFitWidth = YES;
        cell.mainLabel.minimumScaleFactor = 14.0f/21.0f;
        
        cell.secondaryLabel.font = [UIFont systemFontOfSize:13.0f];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.secondaryLabel.frame = CGRectMake(13, 12, CGRectGetWidth(cell.mainLabel.frame), 18);
    
    cell.mainLabel.frame = CGRectMake(13, CGRectGetMaxY(cell.secondaryLabel.frame) + 1, CGRectGetWidth(self.tableView.frame) - 34, 27);
    cell.mainLabel.font = [UIFont systemFontOfSize:20.0f];
    cell.mainLabel.alpha = 1.0f;
    
    cell.buttonRight.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) - kButtonWidth - kButtonPadding, kButtonPadding, kButtonWidth, kButtonWidth);
    cell.buttonRight.alpha = 1.0f;
    [cell.buttonRight setImage:[UIImage imageNamed:@"text-active"] forState:UIControlStateNormal];
    [cell.buttonRight setTintColor:COLOR_TEXT_BLUE];
    cell.buttonRight.layer.borderWidth = 0.0f;
    cell.buttonRight.tag = indexPath.row + TAG_BUTTON_OFFSET;
    
    cell.buttonLeft.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) - (kButtonWidth * 2) - kButtonPadding, CGRectGetMinY(cell.buttonRight.frame), kButtonWidth, kButtonWidth);
    cell.buttonLeft.alpha = 1.0f;
    [cell.buttonLeft setImage:[UIImage imageNamed:@"phone-home-active"] forState:UIControlStateNormal];
    [cell.buttonLeft setTintColor:COLOR_CALL_GREEN];
    cell.buttonLeft.tag = indexPath.row + TAG_BUTTON_OFFSET;
    cell.buttonLeft.userInteractionEnabled = YES;
        
    [cell setFirstColor:COLOR_TEXT_BLUE];
    [cell setFirstIconName:@"text-active"];
    
    [cell setSecondColor:COLOR_CALL_GREEN];
    [cell setSecondIconName:@"phone-home-active"];
    
    [cell setThirdColor:nil];
    [cell setThirdIconName:nil];
    
    [cell setFourthColor:nil];
    [cell setFourthColor:nil];
    
    cell.panGestureRecognizer.enabled = NO;
    
    cell.mainLabel.textColor = [UIColor blackColor];
    cell.secondaryLabel.textColor = COLOR_DEFAULT_RED;
    cell.colorIndicatorView.backgroundColor = [UIColor clearColor];
    
    // Configure for notification
    NSNotification *notif = _notifications[indexPath.row];
    NSDictionary *info = notif.userInfo;
    
    if ([info[kLocalNotificationUserInfoDate] respondsToSelector:@selector(doubleValue)]) {
        NSTimeInterval interval = (NSTimeInterval)[info[kLocalNotificationUserInfoDate] doubleValue];
        interval -= [[NSDate date] timeIntervalSince1970];
        cell.mainLabel.text = [NSString stringWithFormat:@"%@ %@", info[kLocalNotificationUserInfoActionString], info[kLocalNotificationUserInfoUserName]];
        cell.secondaryLabel.text =  [_formatter stringForTimeInterval:interval];
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Cancel", nil);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        UILocalNotification *notif = _notifications[indexPath.row];
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
        
        _notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
