//
//  MasterViewController.h
//  Reach
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
