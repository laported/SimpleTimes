//
//  RaceResult.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import "RaceResultMI.h"

@implementation RaceResultMI

@synthesize meet = _meet;
@synthesize date = _date;
@synthesize stroke = _stroke;
@synthesize time = _time;
@synthesize distance = _distance; 
@synthesize course = _course;
@synthesize age = _age;
@synthesize powerpoints = _powerpoints;
@synthesize standard = _standard;
@synthesize key = _key;
@synthesize splits = _splits;
@synthesize tmDatabase = _tmDatabase;

- (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSString*)stroke distance:(int)distance course:(NSString*)course age:(int)age powerpoints:(int)powerpoints standard:(NSString*)standard splits:(NSArray*)splits db:(NSString*)db
{
    if ((self = [super init])) {
        _time = [time copy];
        _distance = distance;
        _date = [date copy];
        _meet = [meet copy];
        _stroke = [stroke copy];
        _course = [course copy];
        //_key = key;
        self.splits = splits;
        _standard = [standard copy];
        _age = age;
        _powerpoints = powerpoints;
        _tmDatabase = [db copy];
    }
    return self;
}

- (void) setSplitsKey:(int)key
{
    _key = key;
}

- (BOOL)hasSplits {
    return [self.splits count] > 0;
}

- (NSComparisonResult)compareByTime:(RaceResultMI *)otherObject
{
    return [otherObject.time caseInsensitiveCompare:self.time];
}

- (NSComparisonResult)compareByDistance:(RaceResultMI *)otherObject
{
     if (self.distance > otherObject.distance)
     {
         return NSOrderedDescending;
     }
     
     if (self.distance < otherObject.distance)
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
    [_course release];
    _course = nil;
    [_standard release];
    _standard = nil;
    [_splits release];
    [_tmDatabase release];
    _tmDatabase = nil;
    [super dealloc];
}

@end
