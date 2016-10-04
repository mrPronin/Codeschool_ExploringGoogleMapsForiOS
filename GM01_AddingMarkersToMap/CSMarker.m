//
//  CSMarker.m
//  GM01_AddingMarkersToMap
//
//  Created by Aleksandr Pronin on 10/5/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "CSMarker.h"

@implementation CSMarker

- (BOOL)isEqual:(id)object {
    CSMarker *otherMarker = (CSMarker *)object;
    if ([self.objectID isEqualToString:otherMarker.objectID]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.objectID hash];
}

@end
