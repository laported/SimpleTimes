//
//  TimeStandard.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/20/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeStandard : NSObject {
    
}

+(int) ageAtDate:(NSDate*)date dob:(NSDate*)dob;

+(int) distanceIndex:(int)distance;

+(float) getFloatTimeFromCStringTime:(const char*)sz;
+(float) getFloatTimeFromStringTime:(NSString*)sTime;

+(NSString*) getTimeStandardWithAge:(int)age distance:(int)distance stroke:(int)stroke gender:(NSString*)gender time:(float)time;

+(NSString*) getTimeStandardForMHSAAWithDistance:(int)distance stroke:(int)stroke gender:(NSString*)gender time:(float)time;

+(NSString*) getJoCutWithAge:(NSDate*)dob distance:(int)distance stroke:(int) stroke gender:(NSString*)gender ;

+(NSDate*) dateObjectFromString:(NSString*)s;

@end
