//
//  RCListSelectorTableViewController.h
//  Reach
//
//  Created by Tom Bachant on 8/4/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"

@protocol RCListSelectorDelegate <NSObject>

- (void)listSelectorDidChooseType:(RCContactType)type;

@end

@interface RCListSelectorTableViewController : UITableViewController

@property (nonatomic, assign) id<RCListSelectorDelegate> delegate;

@property (nonatomic, assign) RCContactType *selectedType;

@property (nonatomic, getter = isLoading) BOOL loading;

- (void)openSettings;
- (void)close;

@end
