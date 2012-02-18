//
//  SplitCD.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/10/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "SplitCD.h"
#import "RaceResult.h"


@implementation SplitCD

@dynamic distance;
@dynamic time;
@dynamic cumulative;
@dynamic race;

- (NSComparisonResult)compareByDistance:(SplitCD *)otherObject
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

@end
