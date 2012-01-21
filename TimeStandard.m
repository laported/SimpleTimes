//
//  TimeStandard.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/20/11.
//  Copyright 2011 org.laporte6. All rights reserved.
//

#import "TimeStandard.h"


@implementation TimeStandard

const float eleven_twelve__m_q1 [5][8] = {
    // 25     50     100    200     400    500     1000    1650
    {  0.0,   28.09, 61.59, 134.59, 0.0,    360.59, 0.0,    0.0   },  // free
    {  0.0,   33.29, 71.69, 154.79, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   37.79, 81.69, 179.99, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   32.09, 73.99, 175.89, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   72.79, 155.49, 335.79, 0.0,    0.0,    0.0   }   // IM
};

const float eleven_twelve__m_q2 [5][8] = {
    // 25     50     100    200     400    500     1000    1650
    {  0.0,   30.59, 69.19, 152.99, 0.0,    402.19, 0.0,    0.0   },  // free
    {  0.0,   37.09, 80.19, 189.59, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   41.99, 92.09, 205.79, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   36.29, 86.69, 203.99, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   80.29, 175.69, 390.89, 0.0,    0.0,    0.0   }   // IM
};

const float eleven_twelve__m_b [5][8] = {
    // 25     50     100    200     400    500      1000    1650
    {  0.0,   33.39, 73.09, 158.89, 0.0,    425.49, 890.09, 1497.49   },  // free
    {  0.0,   39.49, 85.79, 178.39, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   44.29, 95.09, 201.69, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   38.19, 85.79, 181.19, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   83.69, 183.09, 383.69, 0.0,    0.0,    0.0   }   // IM
};

// TODO - these are boys right now
const float eleven_twelve_w_q1 [5][8] = {
    // 25     50     100    200     400    500     1000    1650
    {  0.0,   28.09, 61.59, 134.59, 0.0,    360.59, 0.0,    0.0   },  // free
    {  0.0,   33.29, 71.69, 154.79, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   37.79, 81.69, 179.99, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   32.09, 73.99, 175.89, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   72.79, 155.49, 335.79, 0.0,    0.0,    0.0   }   // IM
};

// TODO - these are boys right now
const float eleven_twelve_w_q2 [5][8] = {
    // 25     50     100    200     400    500     1000    1650
    {  0.0,   30.59, 69.19, 152.99, 0.0,    402.19, 0.0,    0.0   },  // free
    {  0.0,   37.09, 80.19, 189.59, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   41.99, 92.09, 205.79, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   36.29, 86.69, 203.99, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   80.29, 175.69, 390.89, 0.0,    0.0,    0.0   }   // IM
};

// TODO - these are boys right now
const float eleven_twelve_w_b [5][8] = {
    // 25     50     100    200     400    500      1000    1650
    {  0.0,   33.39, 73.09, 158.89, 0.0,    425.49, 890.09, 1497.49   },  // free
    {  0.0,   39.49, 85.79, 178.39, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   44.29, 95.09, 201.69, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   38.19, 85.79, 181.19, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   83.69, 183.09, 383.69, 0.0,    0.0,    0.0   }   // IM
};

// 13-14 M ---------------------------------------------------------------------
const float thirteen_fourteen_m_q1 [5][8] = {
    // 25     50     100    200     400    500     1000     1650
    {  0.0,   25.29, 54.89, 119.99, 0.0,    325.09, 679.99, 1157.99 },  // free
    // TODO _ THESE ARE Q2ss
    {  0.0,   0.0,   70.99, 155.99, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   0.0,   79.49, 174.49, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   0.0,   69.99, 161.99, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   0.0,   148.99, 324.99, 0.0,    0.0,    0.0   }   // IM
};

const float thirteen_fourteen_m_q2 [5][8] = {
    // 25     50     100    200     400    500      1000    1650
    {  0.0,   27.09, 58.89, 131.09, 0.0,    353.69, 755.59, 1279.99 },  // free
    {  0.0,   0.0,   70.99, 155.99, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   0.0,   79.49, 174.49, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   0.0,   69.99, 161.99, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   0.0,   148.99, 324.99, 0.0,    0.0,    0.0   }   // IM
};

const float thirteen_fourteen_m_b [5][8] = {
    // 25     50     100    200     400    500      1000    1650
    {  0.0,   30.69, 66.99, 146.09, 0.0,    391.09, 812.49, 1348.29   },  // free
    {  0.0,   0.0,   74.89, 161.29, 0.0,    0.0,    0.0,    0.0   },  // back
    {  0.0,   0.0,   84.09, 182.39, 0.0,    0.0,    0.0,    0.0   },  // breast
    {  0.0,   0.0,   73.29, 163.69, 0.0,    0.0,    0.0,    0.0   },  // fly
    {  0.0,   0.0,   0.0,   163.69, 350.59, 0.0,    0.0,    0.0   }   // IM
};

+(float) getFloatTimeFromStringTime:(NSString*)sTime {

    float ret = 0;
    int idx = 0;
    
    if([sTime isEqualToString:@"DQ"]){
        return 9999999999;
    }
    
    NSArray* parts = [sTime componentsSeparatedByString:@":"];
    if ([parts count] == 2) {
        // get the minutes
        ret = [[parts objectAtIndex:0] floatValue] * 60.0;
        idx++;
    }
    // get the seconds
    NSArray* p2 = [[parts objectAtIndex:idx] componentsSeparatedByString:@"."];
    ret += [[p2 objectAtIndex:0] floatValue];
    if ([p2 count] == 2) {
        // milliseconds
        int places = [[p2 objectAtIndex:1] length];
        float denom = (float)pow(10,places);
        ret += ([[p2 objectAtIndex:1] floatValue])/denom;
    }
    return ret; 
}

+(NSString*) getTimeStandardWithAge:(int)age distance:(int)distance stroke:(int)stroke gender:(NSString*)gender time:(float)time {
    int distanceidx;
    switch (distance) {
        case 25:   distanceidx = 0; break;
        case 50:   distanceidx = 1; break;
        case 100:  distanceidx = 2; break;
        case 200:  distanceidx = 3; break;
        case 400:  distanceidx = 4; break;
        case 500:  distanceidx = 5; break;
        case 1000: distanceidx = 6; break;
        case 1650: distanceidx = 7; break;
        default: assert(false); distanceidx = 0; break;
    }
    switch (age) {
        case 11:
        case 12:
            if ([gender isEqualToString:@"m"]) {
               if (time <= eleven_twelve__m_q1[stroke-1][distanceidx])
                    return @"Q1";
                if (time <= eleven_twelve__m_q2[stroke-1][distanceidx]) {
                   return [NSString stringWithFormat:@"Q2 (Q1+%2.2f)",time-eleven_twelve__m_q1[stroke-1][distanceidx]];
                }
               if (time <= eleven_twelve__m_b[stroke-1][distanceidx])
                   return [NSString stringWithFormat:@"B (Q2+%2.2f)",time-eleven_twelve__m_q2[stroke-1][distanceidx]];
            }
            break;
        case 13:
        case 14:
            if ([gender isEqualToString:@"m"]) {
                if (time <= thirteen_fourteen_m_q1[stroke-1][distanceidx])
                    return @"Q1";
                if (time <= thirteen_fourteen_m_q2[stroke-1][distanceidx]) {
                    return [NSString stringWithFormat:@"Q2 (Q1+%2.2f)",time-thirteen_fourteen_m_q1[stroke-1][distanceidx]];
                }
                if (time <= thirteen_fourteen_m_b[stroke-1][distanceidx])
                    return [NSString stringWithFormat:@"B (Q2+%2.2f)",time-thirteen_fourteen_m_q2[stroke-1][distanceidx]];
            }
            break;
        default:
            break;
    }
    return @"";
}

@end

