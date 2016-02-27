//
//  Geocoder.h
//  Dashride
//
//  Created by Tom Bachant on 11/3/13.
//  Copyright (c) 2013 Sobrio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <MapKit/MapKit.h>


@interface Geocoder : NSObject

/**
 Input an address search term.
 Returns an array of google result objects.
 Access the "description" property to get the place name
 */
+ (void)searchForAddress:(NSString *)address results:(void(^)(NSArray *results, NSError *error))_block;

/**
 Input an address identifier returned from -searchForAddress.
 Returns the lat/long of the place
 */
+ (void)geocodeAddressIdentifier:(NSString *)identifier result:(void(^)(CLLocationCoordinate2D coordinate, NSError *error))_block;

@end
