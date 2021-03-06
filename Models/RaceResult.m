//
//  RaceResult.m
//  SimpleTimes
//
//  Created by David LaPorte on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RaceResult.h"
#import "AthleteCD.h"

@implementation RaceResult
@dynamic time;
@dynamic stroke;
@dynamic course;
@dynamic standard;
@dynamic meet;
@dynamic date;
@dynamic splitskey;
@dynamic powerpoints;
@dynamic distance;
@dynamic athlete;
@dynamic splits;

- (NSComparisonResult)compareByTime:(RaceResult *)otherObject
{
    return [otherObject.time caseInsensitiveCompare:self.time];
}

- (NSComparisonResult)compareByDistance:(RaceResult *)otherObject
{
    if ([self.distance intValue] > [otherObject.distance intValue])
    {
        return NSOrderedDescending;
    }
    
    if ([self.distance intValue] < [otherObject.distance intValue])
    {
        return NSOrderedAscending;
    }
    
    return NSOrderedSame;
}

- (NSString*) shortenMeetName
{
    NSString* shortname;
    if ([self.meet hasPrefix:@"201"] || [self.meet hasPrefix:@"200"]) {
        shortname = [self.meet substringWithRange:NSMakeRange(5, [self.meet length]-5)];
    } else {
        shortname = self.meet;
    }
    return shortname;
}

@end
