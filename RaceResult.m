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

- (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSDate*)stroke distance:(int)distance shortcourse:(BOOL)shortcourse;
{
    if ((self = [super init])) {
        _time = time;
        _distance = distance;
        _shortcourse = shortcourse;
        _date = [date copy];
        _meet = [meet copy];
        _stroke = [stroke copy];
    }
    return self;
}

- (NSComparisonResult)compareByTime:(RaceResult *)otherObject
{
    return [otherObject.time caseInsensitiveCompare:self.time];
    /* TODO
	NSTimeInterval diff = [self.time timeIntervalSinceDate:otherObject.time];
	if (diff > 0)
	{
		return NSOrderedDescending;
	}
    
	if (diff < 0)
	{
		return NSOrderedAscending;
	}
    
	return NSOrderedSame;*/
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
    [super dealloc];
}

@end
