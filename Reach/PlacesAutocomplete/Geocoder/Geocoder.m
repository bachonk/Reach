//
//  Geocoder.m
//  AmRide
//
//  Created by Tom Bachant on 11/3/13.
//  Copyright (c) 2013 Sobrio. All rights reserved.
//

#import "Geocoder.h"
#import "AppDelegate.h"

#define GOOGLE_API_KEY @"XXXXXXX"

// ------------
// Autocomplete
// ------------
//
// Google documentation here:
// https://developers.google.com/places/documentation/autocomplete#examples
#define AUTOCOMPLETE_STATUS_OK @"OK" //indicates that no errors occurred and at least one result was returned.
#define AUTOCOMPLETE_STATUS_ZERO_RESULTS @"ZERO_RESULTS" //indicates that the search was successful but returned no results. This may occur if the search was passed a bounds in a remote location.
#define AUTOCOMPLETE_STATUS_OVER_QUERY_LIMIT @"OVER_QUERY_LIMIT" //indicates that you are over your quota.
#define AUTOCOMPLETE_STATUS_REQUEST_DENIED @"REQUEST_DENIED" //indicates that your request was denied, generally because of lack of a sensor parameter.
#define AUTOCOMPLETE_STATUS_INVALID_REQUEST @"INVALID_REQUEST"

// ---------
// Geocoding
// ---------
//
// Google documentation here:
// https://developers.google.com/places/documentation/details
#define GEOCODE_STATUS_OK @"OK" //indicates that no errors occurred and at least one result was returned.
#define GEOCODE_UNKNOWN_ERROR @"UNKNOWN_ERROR" //indicates a server-side error; trying again may be successful.
#define GEOCODE_ZERO_RESULTS @"ZERO_RESULTS" //indicates that the reference was valid but no longer refers to a valid result. This may occur if the establishment is no longer in business.
#define GEOCODE_OVER_QUERY_LIMIT @"OVER_QUERY_LIMIT" //indicates that you are over your quota.
#define GEOCODE_REQUEST_DENIED @"REQUEST_DENIED" //indicates that your request was denied, generally because of lack of a sensor parameter.
#define GEOCODE_INVALID_REQUEST @"INVALID_REQUEST" //generally indicates that the query (reference) is missing.
#define GEOCODE_NOT_FOUND @"NOT_FOUND" //indicates that the referenced location was not found in the Places database.


@interface Geocoder ()

@end

@implementation Geocoder

+ (void)searchForAddress:(NSString *)address results:(void (^)(NSArray *, NSError *))_block {
    if (!address || ![address length]) {
        _block(nil, [NSError errorWithDomain:@"com.coincidentalCode.reach" code:400 userInfo:nil]);
        return;
    }
    
    // Format address for url
    address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *radius = @"804627"; // AKA 500 miles
    
    // Build the string to send off to El Goog
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&radius=%@&sensor=true&key=%@", address, radius, GOOGLE_API_KEY];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D coordinate = delegate.locationManager.location.coordinate;
    if (coordinate.latitude) {
        urlString = [NSString stringWithFormat:@"%@&location=%f,%f", urlString, coordinate.latitude, coordinate.longitude];
    }
    
    // Retrieve the results of the URL.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if (!data) {
            _block(nil, [NSError errorWithDomain:@"com.coincidentalCode.reach" code:400 userInfo:nil]);
            return;
        }
        
        NSError *err;
        NSDictionary *response = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&err];
        
        // Check the status first
        NSString *status = [response objectForKey:@"status"];
        
        if ([status isEqualToString:AUTOCOMPLETE_STATUS_OK]) {
            // All good
            NSArray *predictions = [response objectForKey:@"predictions"];
            _block(predictions, nil);
        }
        else {
            // Some kind of error happened
            NSString *errorMessage;
            if ([status isEqualToString:AUTOCOMPLETE_STATUS_ZERO_RESULTS]) {
                errorMessage = @"No results.";
            }
            else if ([status isEqualToString:AUTOCOMPLETE_STATUS_OVER_QUERY_LIMIT]) {
                errorMessage = @"Exceeded maximum number of queries.";
            }
            else if ([status isEqualToString:AUTOCOMPLETE_STATUS_INVALID_REQUEST]) {
                errorMessage = @"Invalid request.";
            }
            else if ([status isEqualToString:AUTOCOMPLETE_STATUS_REQUEST_DENIED]) {
                errorMessage = @"Request was denied.";
            }
            else {
                errorMessage = @"Unknown error occurred";
            }
            
            NSLog(@"Error autocompleting: %@", errorMessage);
            
            _block(nil, [NSError errorWithDomain:@"com.amRide" code:400 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:@"geocode_error"]]);
        }
    });
}

+ (void)geocodeAddressIdentifier:(NSString *)identifier result:(void (^)(CLLocationCoordinate2D, NSError *))_block {
    if (!identifier || ![identifier length]) {
        _block(CLLocationCoordinate2DMake(0, 0), [NSError errorWithDomain:@"com.coincidentalCode.reach" code:400 userInfo:nil]);
        return;
    }
    
    // Build the string to send off to El Goog
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&sensor=true&key=%@", identifier, GOOGLE_API_KEY];
    
    // Retrieve the results of the URL.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if (!data) {
            _block(CLLocationCoordinate2DMake(0, 0), [NSError errorWithDomain:@"com.coincidentalCode.reach" code:400 userInfo:nil]);
            return;
        }
        
        NSError *err;
        NSDictionary *response = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&err];
        
        // Check the status first
        NSString *status = [response objectForKey:@"status"];
        
        if ([status isEqualToString:GEOCODE_STATUS_OK]) {
            // All good
            NSDictionary *location = [[[response objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"];
            
            double latitude = [[location objectForKey:@"lat"] doubleValue];
            double longitude = [[location objectForKey:@"lng"] doubleValue];
            
            _block(CLLocationCoordinate2DMake(latitude, longitude), nil);
        }
        else {
            // Some kind of error happened
            NSString *errorMessage;
            if ([status isEqualToString:GEOCODE_ZERO_RESULTS]) {
                errorMessage = @"No results.";
            }
            else if ([status isEqualToString:GEOCODE_OVER_QUERY_LIMIT]) {
                errorMessage = @"Exceeded maximum number of queries.";
            }
            else if ([status isEqualToString:GEOCODE_INVALID_REQUEST]) {
                errorMessage = @"Invalid request.";
            }
            else if ([status isEqualToString:GEOCODE_REQUEST_DENIED]) {
                errorMessage = @"Request was denied.";
            }
            else if ([status isEqualToString:GEOCODE_NOT_FOUND]) {
                errorMessage = @"Place not found.";
            }
            else if ([status isEqualToString:GEOCODE_UNKNOWN_ERROR]) {
                errorMessage = @"Internal server error.";
            }
            else {
                errorMessage = @"Unknown error occurred.";
            }
            
            NSLog(@"Error geocoding: %@", errorMessage);
            
            _block(CLLocationCoordinate2DMake(0, 0), [NSError errorWithDomain:@"com.coincidentalCode.reach" code:400 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:@"geocode_error"]]);
        }
    });
}

@end
