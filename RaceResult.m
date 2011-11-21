//
//  RaceResult.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RaceResult.h"


@implementation RaceResult

@synthesize meet = _meet;
@synthesize date = _date;
@synthesize stroke = _stroke;
@synthesize time = _time;
@synthesize distance = _distance; 
@synthesize shortcourse = _shortcourse;
@synthesize course = _course;
@synthesize age = _age;
@synthesize powerpoints = _powerpoints;
@synthesize standard = _standard;
@synthesize key = _key;

- (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSDate*)stroke distance:(int)distance shortcourse:(BOOL)shortcourse course:(NSString*)course age:(int)age powerpoints:(int)powerpoints standard:(NSString*)standard key:(int)key
{
    if ((self = [super init])) {
        _time = time;
        _distance = distance;
        _shortcourse = shortcourse;
        _date = [date copy];
        _meet = [meet copy];
        _stroke = [stroke copy];
        _course = [course copy];
        _key = key;
        _standard = [standard copy];
        _age = age;
        _powerpoints = powerpoints;
    }
    return self;
}

- (BOOL)hasSplits {
    return (self.key > 0);
}

- (NSComparisonResult)compareByTime:(RaceResult *)otherObject
{
    return [otherObject.time caseInsensitiveCompare:self.time];
}

- (NSComparisonResult)compareByDistance:(RaceResult *)otherObject
{
     if (self.distance < otherObject.distance)
     {
         return NSOrderedDescending;
     }
     
     if (self.distance > otherObject.distance)
     {
     return NSOrderedAscending;
     }
     
     return NSOrderedSame;
}


- (void)dealloc {
    [_stroke release];
    _stroke = nil;
    [_meet release];
    _meet = nil;
    [_date release];
    _date = nil;
    [_time release];
    _time = nil;
    _distance = 0;
    _shortcourse = YES;
    [_course release];
    _course = nil;
    [_standard release];
    _standard = nil;
    [super dealloc];
}

@end
