//
//  RCPhoneController.m
//  Reach
//
//  Created by Tom Bachant on 7/20/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import "RCPhoneController.h"

@interface RCPhoneController ()

@end

@implementation RCPhoneController

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
    
    _favorites = [[NSMutableArray alloc] init];
    _recents = [[NSMutableArray alloc] init];
    rawPhoneString = [[NSMutableString alloc] init];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureTriggered:)];
    [self.view addGestureRecognizer:panGesture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (IBAction)addNumber:(UIButton *)sender {
    NSString *title = sender.titleLabel.text;
    
    [rawPhoneString appendString:title];
    
    [self didBeginTypingNumber];
}

#pragma mark - Pan Gesture Handling

#pragma mark - Pan Gesture Handling

- (void)panGestureTriggered:(UIPanGestureRecognizer *)gesture {
    UIGestureRecognizerState state = [gesture state];
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.view.frame) relativeToHeight:CGRectGetHeight(self.view.frame)];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    if (state == UIGestureRecognizerStateBegan) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }
    else if (state == UIGestureRecognizerStateChanged) {
        
        CGPoint center = {self.view.center.x, self.view.center.y + translation.y};
        [self.view setCenter:center];
        
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
        if (percentage > 0.4 && velocity.y > 400) {
            [self animateViewOutWithVelocity:velocity completion:nil];
        } else {
            [self resetViewStateAnimated:YES];
        }
        
    }
    
}

- (void)resetViewStateAnimated:(BOOL)animated {
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.15];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    self.view.frame = frame;
    
    if (animated) {
        [UIView commitAnimations];
    }
    
}

- (void)animateViewOutWithVelocity:(CGPoint)velocity completion:(void (^)(void))completion {
    
    [UIView animateWithDuration:[self animationDurationWithVelocity:velocity] delay:0.0f options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        CGRect frame = self.view.frame;
        frame.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        self.view.frame = frame;
        
    } completion:^(BOOL completed) {
        completion();
    }];
    
}

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToHeight:(CGFloat)height {
    CGFloat offset = percentage * height;
    
    if (offset < -height) offset = -height;
    else if (offset > height) offset = 1.0;
    
    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToHeight:(CGFloat)height {
    CGFloat percentage = offset / height;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat height = CGRectGetHeight(self.view.bounds);
    NSTimeInterval animationDurationDiff = 1 - 0.1;
    CGFloat verticalVelocity = velocity.y;
    
    if (verticalVelocity < -height) verticalVelocity = -height;
    else if (verticalVelocity > height) verticalVelocity = height;
    
    return (1 + 0.1) - fabs(((verticalVelocity / height) * animationDurationDiff));
}

#pragma mark - Event handling

- (void)didBeginTypingNumber {
    // Did start typing a number
    // Move the favorites frame to the full view
    // It will be treated as the suggestions table
    
    if (self.isTypingNumber) return; // Don't rearrange
    
    self.typingNumber = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect favFrame = favoritesTableView.frame;
        CGRect recFrame = recentsTableView.frame;
        
        favFrame.size.width = CGRectGetWidth(self.view.frame);
        recFrame.origin.x = CGRectGetWidth(self.view.frame);
        
        favoritesTableView.frame = favFrame;
        recentsTableView.frame = recFrame;
        
        [favoritesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
}

- (void)didClearNumber {
    // Did clear out the number
    // Move frames, and change suggestions table to favorites table
    
    if (!self.isTypingNumber) return; // Don't rearrange if nothing's changed
    
    self.typingNumber = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect favFrame = favoritesTableView.frame;
        CGRect recFrame = recentsTableView.frame;
        
        favFrame.size.width = CGRectGetWidth(recFrame);
        recFrame.origin.x = CGRectGetWidth(recFrame);
        
        favoritesTableView.frame = favFrame;
        recentsTableView.frame = recFrame;
        
        [favoritesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 24.0)];
    
    backgroundView.frame = CGRectMake(8, 0, CGRectGetWidth(self.view.frame), 24.0);
    backgroundView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 24)];
    titleLabel.backgroundColor = COLOR_DEFAULT_RED;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.layer.cornerRadius = 12.0f;
    
    if (tableView == favoritesTableView) {
        if (self.isTypingNumber) {
            titleLabel.text = @"Suggestions";
        } else {
            titleLabel.text = @"Favorites";
        }
    } else {
        titleLabel.text = @"Recents";
    }
    
    [backgroundView addSubview:titleLabel];
    return backgroundView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == favoritesTableView) {
        return [_favorites count];
	}
    
    return [_recents count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    cell.contentView.backgroundColor = cell.backgroundColor;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    
	return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == favoritesTableView) {
		
	} else {
		
	}
}

@end
