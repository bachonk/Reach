//
//  RCPhoneController.h
//  Reach
//
//  Created by Tom Bachant on 7/20/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"

@interface RCPhoneController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UILabel *phoneLabel;
    
    IBOutlet UITableView *recentsTableView;
    IBOutlet UITableView *favoritesTableView;
    
    NSMutableArray *_recents;
    NSMutableArray *_favorites;
    
    NSMutableString *rawPhoneString;
    
}

- (IBAction)addNumber:(UIButton *)sender;

- (void)didBeginTypingNumber;
- (void)didClearNumber;

@property (nonatomic, assign, getter = isTypingNumber) BOOL typingNumber;

@end
