//
//  DRCPlaceSearchTableViewController.h
//  DashrideClientTemplate
//
//  Created by Tom Bachant on 10/29/14.
//  Copyright (c) 2014 Dashride. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Geocoder.h"

#define TAG_PICKUP 10
#define TAG_DROPOFF 11
#define TAG_LOCATION_HOME 20
#define TAG_LOCATION_WORK 21

@class DRCPlaceSearchTableViewController;
@protocol DRCPlaceSearchDelegate

- (void)placeSearchViewController:(DRCPlaceSearchTableViewController *)controller didReturnPlace:(NSString *)result location:(CLLocationCoordinate2D)coordinate;

- (void)placeSearchViewControllerDidCancel:(DRCPlaceSearchTableViewController *)controller;

@end

@interface DRCPlaceSearchTableViewController : UITableViewController <UITextFieldDelegate> {
    
    UITextField *searchField;
    
    UIActivityIndicatorView *activityIndicator; // show during autocomplete searching
        
    NSMutableArray *results;
    NSArray *pastLocations;
    
    NSString *errorDescription;
    
}

- (void)cancel;

@property (nonatomic) int tag;
@property (nonatomic, strong) id<DRCPlaceSearchDelegate> delegate;

@end