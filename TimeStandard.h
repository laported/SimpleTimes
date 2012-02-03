//
//  TimeStandard.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/20/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JO_DATE         "2012-03-01" // TODO
#define STATE_DATE      "2012-03-14" // TODO
#define SECTIONALS_DATE "2012-03-21" // TODO
#define NATIONALS_DATE  "2012-04-14" // TODO

@interface TimeStandard : NSObject {
    
}

+(float) getFloatTimeFromStringTime:(NSString*)sTime;

+(NSString*) getTimeStandardWithAge:(int)age distance:(int)distance stroke:(int)stroke gender:(NSString*)gender time:(float)time;


@end
