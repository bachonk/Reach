//
//  RCSocialDetailViewController.h
//  Reach
//
//  Created by Tom Bachant on 8/3/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Contact.h"

@interface RCSocialDetailViewController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, strong) Contact *contact;

- (id)initWithContact:(Contact *)contact;

- (void)showOptions;

@end
