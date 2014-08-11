//
//  RCTutorialViewController.m
//  Reach
//
//  Created by Tom Bachant on 5/27/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCTutorialViewController.h"
#import "Definitions.h"

typedef enum {
    RCTutorialStatusWelcome = 0,
    RCTutorialStatusText,
    RCTutorialStatusCall,
    RCTutorialStatusEmail,
    RCTutorialStatusRemind,
    RCTutorialStatusEnd
} RCTutorialStatus;

@interface RCTutorialViewController ()

@property (nonatomic, assign) RCTutorialStatus status;

- (void)configureForWelcome;
- (void)configureForText;
- (void)configureForCall;
- (void)configureForEmail;
- (void)configureForReminder;
- (void)configureForEnd;

- (void)showSwipeGuide;

@end

@implementation RCTutorialViewController

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
    
    _displayTableView.scrollEnabled = NO;
    
    _displayTableView.rowHeight = kCellHeightDefault;
    
    _swipeGuideImageView.userInteractionEnabled = NO;
    
    [_closeButton setTitleColor:[UIColor colorWithWhite:0.34f alpha:1.0f] forState:UIControlStateNormal];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self configureForWelcome];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - IB Actions

- (void)getStarted:(id)sender {
    if (self.status == RCTutorialStatusWelcome) {
        [self configureForText];
    } else {
        [self dismissTutorial:nil];
    }
}

- (void)skipToEnd:(id)sender {
    [self dismissTutorial:nil];
}

- (void)dismissTutorial:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI Configuration

- (void)configureForWelcome
{
    _status = RCTutorialStatusWelcome;
    
    _closeButton.alpha = 0.0f;
    _displayTableView.alpha = 0.0f;
    _confirmationLabel.alpha = 0.0f;
    _getStartedButton.alpha = 0.0f;
    
    [_getStartedButton setBackgroundColor:COLOR_CALL_GREEN];
    [_getStartedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _getStartedButton.frame = CGRectMake(20, CGRectGetHeight([[UIScreen mainScreen] bounds]) + 20, CGRectGetWidth([[UIScreen mainScreen] bounds]) - 40, 47);
    
    _descriptionLabel.alpha = 0.0f;
    _descriptionLabel.text = NSLocalizedString(@"Reach makes it easy to manage your contacts with the swipe of a finger", @"");
    _descriptionLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    _topLabel.alpha = 0.0f;
    _topLabel.text = NSLocalizedString(@"Welcome to Reach", @"");
    _topLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.7f animations:^{
        
        _topLabel.alpha = 1.0f;
        _topLabel.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:0.7f delay:0.7 options:0 animations:^{
            
            _descriptionLabel.alpha = 1.0f;
            _descriptionLabel.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL completed) {
            
            [UIView animateWithDuration:1.0f delay:1.0f options:0 animations:^{
                _getStartedButton.alpha = 1.0f;
                _getStartedButton.center = self.view.center;

            } completion:^(BOOL finished) {
                
            }];
            
        }];
        
    }];

}

- (void)configureForText
{
    _status = RCTutorialStatusText;
    
    _topLabel.text = NSLocalizedString(@"Swipe Right To Text", nil);
    _descriptionLabel.text = NSLocalizedString(@"Swipe your finger to the right to text a contact", nil);
    
    [UIView animateWithDuration:0.7f animations:^{
        
        _getStartedButton.frame = CGRectMake(20, CGRectGetHeight([[UIScreen mainScreen] bounds]) + 20, CGRectGetWidth([[UIScreen mainScreen] bounds]) - 40, 47);
        _displayTableView.center = self.view.center;
        _displayTableView.alpha = 1.0f;
        
        _closeButton.alpha = 1.0f;
        _closeButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY([[UIScreen mainScreen] bounds]) - 40);
        
    } completion:^(BOOL completed) {
       
        [self showSwipeGuide];
        
    }];

}

- (void)configureForCall
{
    _status = RCTutorialStatusCall;
    
    _descriptionLabel.alpha = 0.0f;
    _topLabel.alpha = 0.0f;
    
    _confirmationLabel.text = NSLocalizedString(@"Good!", nil);
    _confirmationLabel.alpha = 1.0f;
    
    [UIView animateWithDuration:0.35f animations:^{
        
        _displayTableView.frame = CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]) + 20, CGRectGetWidth([[UIScreen mainScreen] bounds]), kCellHeightDefault);
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:0.7 delay:0.5f options:0 animations:^{
            
            [_displayTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

            _displayTableView.center = self.view.center;
            
            _confirmationLabel.alpha = 0.0f;
            
            _topLabel.text = NSLocalizedString(@"Long Swipe to Call", nil);
            _descriptionLabel.text = NSLocalizedString(@"Swipe your finger all the way to the right to make a call", nil);
            
            _topLabel.alpha = 1.0f;
            _descriptionLabel.alpha = 1.0f;
 
        } completion:^(BOOL completed) {
            
            [self showSwipeGuide];
            
        }];
        
    }];
    
}

- (void)configureForEmail
{
    _status = RCTutorialStatusEmail;
    
    _descriptionLabel.alpha = 0.0f;
    _topLabel.alpha = 0.0f;
    
    _confirmationLabel.text = NSLocalizedString(@"Good!", nil);
    _confirmationLabel.alpha = 1.0f;
    
    [UIView animateWithDuration:0.35f animations:^{
        
        _displayTableView.frame = CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]) + 20, CGRectGetWidth([[UIScreen mainScreen] bounds]), kCellHeightDefault);
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:0.7 delay:0.5f options:0 animations:^{
            
            [_displayTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            _displayTableView.center = self.view.center;
            
            _confirmationLabel.alpha = 0.0f;
            
            _topLabel.text = NSLocalizedString(@"Swipe Left to Email", nil);
            _descriptionLabel.text = NSLocalizedString(@"Swipe your finger to the left to email a contact", nil);
            
            _topLabel.alpha = 1.0f;
            _descriptionLabel.alpha = 1.0f;
            
        } completion:^(BOOL completed) {
            
            [self showSwipeGuide];
            
        }];
        
    }];
    
}

- (void)configureForReminder
{
    _status = RCTutorialStatusRemind;
    
    _descriptionLabel.alpha = 0.0f;
    _topLabel.alpha = 0.0f;
    
    _confirmationLabel.text = NSLocalizedString(@"Good!", nil);
    _confirmationLabel.alpha = 1.0f;
    
    [UIView animateWithDuration:0.35f animations:^{
        
        _displayTableView.frame = CGRectMake(00, CGRectGetHeight([[UIScreen mainScreen] bounds]) + 20, CGRectGetWidth([[UIScreen mainScreen] bounds]), kCellHeightDefault);
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:0.7 delay:0.5f options:0 animations:^{
            
            [_displayTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            _displayTableView.center = self.view.center;
            
            _confirmationLabel.alpha = 0.0f;
            
            _topLabel.text = NSLocalizedString(@"Long Swipe to Set Reminder", nil);
            _descriptionLabel.text = NSLocalizedString(@"Swipe your finger all the way to the left to set a reminder", nil);
            
            _topLabel.alpha = 1.0f;
            _descriptionLabel.alpha = 1.0f;
            
        } completion:^(BOOL completed) {
            
            [self showSwipeGuide];
            
        }];
        
    }];
    
}

- (void)configureForEnd
{
    _status = RCTutorialStatusEnd;
    
    _topLabel.text = NSLocalizedString(@"All Set!", nil);
    _descriptionLabel.text = nil;
    
    [_getStartedButton setTitle:NSLocalizedString(@"Go to my Contacts", nil) forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.35f animations:^{
        
        _displayTableView.frame = CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]), CGRectGetWidth([[UIScreen mainScreen] bounds]), kCellHeightDefault);
        _displayTableView.alpha = 0.0f;
        
        _closeButton.alpha = 0.0f;
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:0.7f animations:^{
            _getStartedButton.alpha = 1.0f;
            _getStartedButton.center = self.view.center;
        }];
        
    }];
}

- (void)showSwipeGuide {
    
    // Show swipe guide
    
    if (_status == RCTutorialStatusText || _status == RCTutorialStatusCall) {
        _swipeGuideImageView.center = _displayTableView.center;
        _swipeGuideImageView.image = [[UIImage imageNamed:@"guide-indicator-right.png"] imageWithTintColor:_status == RCTutorialStatusText ? COLOR_TEXT_BLUE : COLOR_CALL_GREEN];
    } else {
        _swipeGuideImageView.center = CGPointMake(CGRectGetWidth(_displayTableView.frame) - 60, _displayTableView.center.y);
        _swipeGuideImageView.image = [[UIImage imageNamed:@"guide-indicator-left.png"] imageWithTintColor:_status == RCTutorialStatusEmail ? COLOR_EMAIL_RED : COLOR_REMIND_YELLOW];
    }
    
    CGFloat distance = (_status == RCTutorialStatusText || _status == RCTutorialStatusEmail) ? 70.0f : 130.0f;
    
    [UIView animateWithDuration:0.25f delay:0.38f options:0 animations:^{
        
        _swipeGuideImageView.alpha = 0.4f;
        
    } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:1.1f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            if (_status == RCTutorialStatusText || _status == RCTutorialStatusCall) {
                _swipeGuideImageView.center = CGPointMake(_swipeGuideImageView.center.x + distance, _displayTableView.center.y);
            } else {
                _swipeGuideImageView.center = CGPointMake(_swipeGuideImageView.center.x - distance,  _displayTableView.center.y);
            }
            _swipeGuideImageView.alpha = 0.0f;
            
        }completion:^(BOOL completed) {
            
        }];
        
    }];
    
}

#pragma mark - Table view data source

/******
 * 0 : Help
 *      Tutorial
 *      Tips & Tricks
 *
 * 1
 *      Send Feedback
 *
 * 2
 *      Share
 *
 * 3
 *      Review in App Store
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeightDefault;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // For the delegate callback
        [cell setDelegate:self];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Setting the type of the cell
    [cell setMode:MCSwipeTableViewCellModeSwitch];
    
    cell.frame = CGRectMake(0, 0, _displayTableView.frame.size.width, kCellHeightDefault);

    UIColor *firstColor;
    UIColor *secondColor;
    UIColor *thirdColor;
    UIColor *fourthColor;
    
    switch (_status) {
        case RCTutorialStatusCall:
        {
            firstColor = COLOR_TEXT_BLUE;
            secondColor = COLOR_CALL_GREEN;
            thirdColor = [UIColor whiteColor];
            fourthColor = [UIColor whiteColor];
            
            break;
        }
        case RCTutorialStatusEmail:
        {
            firstColor = [UIColor whiteColor];
            secondColor = [UIColor whiteColor];;
            thirdColor = COLOR_EMAIL_RED;
            fourthColor = COLOR_EMAIL_RED;
            
            break;
        }
        case RCTutorialStatusRemind:
        {
            firstColor = [UIColor whiteColor];
            secondColor = [UIColor whiteColor];;
            thirdColor = COLOR_EMAIL_RED;
            fourthColor = COLOR_REMIND_YELLOW;
            
            break;
        }
        default:
        {
            firstColor = COLOR_TEXT_BLUE;
            secondColor = COLOR_TEXT_BLUE;
            thirdColor = [UIColor whiteColor];
            fourthColor = [UIColor whiteColor];
            
            break;
        }
    }
    
    [cell setFirstStateIconName:@"text-active.png"
                     firstColor:firstColor
            secondStateIconName:_status == RCTutorialStatusText ? @"text-active.png" : @"phone-home-active.png"
                    secondColor:secondColor
                  thirdIconName:@"email-active.png"
                     thirdColor:thirdColor
                 fourthIconName:_status == RCTutorialStatusEmail ? @"email-active.png" : @"remind-active.png"
                    fourthColor:fourthColor];
    
    cell.textLabel.text = @"John Smith";
    
    return cell;
}

#pragma mark - Table Cell Delegate

- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    //
}

- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    //
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didChangeState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    _swipeGuideImageView.alpha = 0.0f;
    
    if (_status == RCTutorialStatusText && (state == MCSwipeTableViewCellState1 || state == MCSwipeTableViewCellState2)) {
        cell.phoneLabel.text = NSLocalizedString(@"Release!", nil);
    }
    else if (_status == RCTutorialStatusCall && state == MCSwipeTableViewCellState2) {
        cell.phoneLabel.text = NSLocalizedString(@"Release!", nil);
    }
    else if (_status == RCTutorialStatusEmail && (state == MCSwipeTableViewCellState3 || state == MCSwipeTableViewCellState4)) {
        cell.phoneLabel.text = NSLocalizedString(@"Release!", nil);
    }
    else if (_status == RCTutorialStatusRemind && state == MCSwipeTableViewCellState4) {
        cell.phoneLabel.text = NSLocalizedString(@"Release!", nil);
    }
    else {
        cell.phoneLabel.text = NSLocalizedString(@"Keep swiping!", nil);
    }
    
    cell.contentView.backgroundColor = COLOR_TABLE_CELL;
    
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    
    if (_status == RCTutorialStatusText && (state == MCSwipeTableViewCellState1 || state == MCSwipeTableViewCellState2)) {
        
        // TEXT CONFIRM
        [self configureForCall];
        
    } else if (_status == RCTutorialStatusCall && state == MCSwipeTableViewCellState2) {
        
        // CALL CONFIRM
        [self configureForEmail];
        
    } else if (_status == RCTutorialStatusEmail && (state == MCSwipeTableViewCellState3 || state == MCSwipeTableViewCellState4)) {
        
        // EMAIL CONFIRM
        [self configureForReminder];
       
    } else if (_status == RCTutorialStatusRemind && state == MCSwipeTableViewCellState4) {
        
        // REMINDER
        [self configureForEnd];
        
    }
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
