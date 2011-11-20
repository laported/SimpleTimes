//
//  Split.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Split.h"


@implementation Split

@synthesize distance = _distance;
@synthesize time_cumulative = _time_cumulative;
@synthesize time_split = _time_split;

- (id)initWithDistance:(NSString*)distance time_cumulative:(NSString*)time_cumulative time_split:(NSString*)time_split
{
    _distance = [distance copy];
    _time_cumulative = [time_cumulative copy];
    _time_split = [time_split copy];
    return self;
}

- (NSComparisonResult)compareByDistance:(Split *)otherObject
{
    int d1 = [otherObject.distance intValue];
    int d2 = [self.distance intValue];
    if (d1 > d2)
    {
        return NSOrderedDescending;
    }
    
    if (d1 < d2)
    {
        return NSOrderedAscending;
    }
    
    return NSOrderedSame;
}

- (void)dealloc {
    [_distance release];
    _distance = nil;
    [_time_cumulative release];
    _time_cumulative = nil;
    [_time_split release];
    _time_split = nil;
    [super dealloc];
}
@end
