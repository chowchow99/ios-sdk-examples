//
//  Examples.m
//  Examples
//
//  Created by Jason Wray on 1/28/16.
//  Copyright © 2016 Mapbox. All rights reserved.
//

#import "Examples.h"

@implementation Examples

+ (NSArray *)list {
    NSArray *initialList = [[NSMutableArray alloc] initWithArray:@[
        MBXExampleSimpleMapView,
        MBXExampleCustomStyle,
        MBXExampleDefaultStyles,
        MBXExampleCustomRasterStyle,
        MBXExampleSatelliteStyle,
        MBXExampleDrawingAMarker,
        MBXExampleCalloutDelegateUsage,
        MBXDrawingAGeoJSONLineExample,
    ]];

    NSMutableArray *meh = [[NSMutableArray alloc] init];

    [initialList enumerateObjectsUsingBlock:^(NSString *objcName, NSUInteger index, BOOL *stop) {
        NSString *swiftName = [NSString stringWithFormat:@"%@_Swift", objcName];

        [meh insertObject:swiftName atIndex:index*2];
        [meh insertObject:objcName atIndex:index*2];
    }];

    return [meh copy];
}

@end