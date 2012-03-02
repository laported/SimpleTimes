//
//  TimeStandardUssScy.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/17/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeStandard.h"

#define JO_DATE         @"2012-03-02"
#define JO_ELG_DATE     @"2011-01-01"
#define STATE12U_DATE   @"2012-03-09"
#define STATE13O_DATE   @"2012-03-16"
#define SECTIONALS_DATE @"2012-03-21" // TODO
#define NATIONALS_DATE  @"2012-04-14" // TODO

@interface TimeStandardUssScy : TimeStandard

+(NSArray*) standardStrings;
+(NSDate*)  dateOfJoMeet;
+(NSDate*)  dateOfJoMeetEligibility;
+(NSDate*)  dateOf12UStateMeet;
+(NSDate*)  dateOf13OStateMeet;
+(float) q1TimeForEvent:(int)distance stroke:(int)stroke gender:(NSString*)gender birthday:(NSDate*)birthday;
+(float) q2TimeForEvent:(int)distance stroke:(int)stroke gender:(NSString*)gender birthday:(NSDate*)birthday;
+(float) bTimeForEvent:(int)distance stroke:(int)stroke gender:(NSString*)gender birthday:(NSDate*)birthday;

@end
