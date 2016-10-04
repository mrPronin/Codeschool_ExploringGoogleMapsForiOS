//
//  CSMarker.h
//  GM01_AddingMarkersToMap
//
//  Created by Aleksandr Pronin on 10/5/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface CSMarker : GMSMarker

@property(nonatomic, copy) NSString *objectID;

@end
