//
//  DetailViewController.h
//  Reach
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
