//
//  RCTutorialViewController.h
//  Reach
//
//  Created by Tom Bachant on 5/27/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCSwipeTableViewCell.h"

@interface RCTutorialViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UILabel *topLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UITableView *displayTableView;
@property (nonatomic, weak) IBOutlet UILabel *confirmationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *swipeGuideImageView;

- (IBAction)getStarted:(id)sender;

- (IBAction)skipToEnd:(id)sender;

- (IBAction)dismissTutorial:(id)sender;

@end
