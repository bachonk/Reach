//
//  TodayViewController.m
//  ReachTodayExtension
//
//  Created by Tom Bachant on 12/26/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _textButton.layer.borderColor = [[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor];
    _textButton.layer.cornerRadius = 3.0f;
    
    _emailButton.layer.borderColor = [[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor];
    _emailButton.layer.cornerRadius = 3.0f;
    
    _contactButton.layer.borderColor = [[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor];
    _contactButton.layer.cornerRadius = 3.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNoData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

#pragma mark - Actions

- (IBAction)newText:(id)sender {
    NSURL *url = [NSURL URLWithString:@"sms:"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction)newEmail:(id)sender {
    NSURL *url = [NSURL URLWithString:@"mailto:"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction)newContact:(id)sender {
    NSURL *url = [NSURL URLWithString:@"reach://new"];
    [self.extensionContext openURL:url completionHandler:nil];
}


@end
