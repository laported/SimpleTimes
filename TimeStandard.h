//
//  TimeStandard.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TimeStandard : NSObject {
    
}

+(float) getFloatTimeFromStringTime:(NSString*)sTime;

+(NSString*) getTimeStandardWithAge:(int)age distance:(int)distance stroke:(int)stroke gender:(NSString*)gender time:(float)time;


@end
