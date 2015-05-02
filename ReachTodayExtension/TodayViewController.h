//
//  TodayViewController.h
//  ReachTodayExtension
//
//  Created by Tom Bachant on 12/26/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *textButton;
@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (nonatomic, weak) IBOutlet UIButton *contactButton;

- (IBAction)newText:(id)sender;
- (IBAction)newEmail:(id)sender;
- (IBAction)newContact:(id)sender;

@end
