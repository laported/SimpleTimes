//
//  TimeStandard.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/20/11.
//  Copyright 2011 org.laporte6. All rights reserved.
//

#import "TimeStandard.h"

@implementation TimeStandard

const char* sz_nine_ten_w_q1 [5][8] = {
    // 25     50       100        200        400      500        1000     1650
    {  NULL,  "31.49", "1:09.49", "2:31.59", NULL,    "6:50.59", NULL,    NULL   },  // free
    {  NULL,  "37.09", "1:20.09", NULL,      NULL,    NULL,      NULL,    NULL   },  // back
    {  NULL,  "42.09", "1:32.49", NULL,      NULL,    NULL,      NULL,    NULL   },  // breast
    {  NULL,  "35.89", "1:26.29", NULL,      NULL,    NULL,      NULL,    NULL   },  // fly
    {  NULL,  NULL,    "1:19.99", "2:54.39", NULL,    NULL,      NULL,    NULL   }   // IM
};

const char* sz_nine_ten_w_q2 [5][8] = {
    // 25     50        100        200        400      500        1000    1650
    {  NULL,   "33.59", "1:15.99", "2:50.09", NULL,    "7:42.89", NULL,    NULL   },  // free
    {  NULL,   "40.39", "1:27.79", NULL,      NULL,    NULL,      NULL,    NULL   },  // back
    {  NULL,   "45.59", "1:42.79", NULL,      NULL,    NULL,      NULL,    NULL   },  // breast
    {  NULL,   "39.79", "1:40.99", NULL,      NULL,    NULL,      NULL,    NULL   },  // fly
    {  NULL,   NULL,    "1:26.59", "3:16.09", NULL,    NULL,      NULL,    NULL   }   // IM
};
const char* sz_nine_ten_w_b [5][8] = {
    // 25     50        100        200        400      500        1000    1650
    {  NULL,   "39.79", "1:31.29", "3:20.19", NULL,    "8:30.49", NULL,   NULL   },  // free
    {  NULL,   "48.79", "1:45.69", NULL,      NULL,    NULL,      NULL,   NULL   },  // back
    {  NULL,   "53.59", "1:59.99", NULL,      NULL,    NULL,      NULL,   NULL   },  // breast
    {  NULL,   "48.79", "1:57.49", NULL,      NULL,    NULL,      NULL,   NULL   },  // fly
    {  NULL,   NULL,    "1:44.99", "3:42.69", NULL,    NULL,      NULL,   NULL   }   // IM
};

const char* sz_nine_ten_m_q1 [5][8] = {
    // 25     50       100        200        400      500        1000     1650
    {  NULL,  "31.59", "1:10.29", "2:34.99", NULL,    "6:55.99", NULL,    NULL   },  // free
    {  NULL,  "37.39", "1:20.59", NULL,      NULL,    NULL,      NULL,    NULL   },  // back
    {  NULL,  "48.09", "1:34.19", NULL,      NULL,    NULL,      NULL,    NULL   },  // breast
    {  NULL,  "36.89", "1:29.99", NULL,      NULL,    NULL,      NULL,    NULL   },  // fly
    {  NULL,  NULL,    "1:21.09", "2:56.49", NULL,    NULL,      NULL,    NULL   }   // IM
};
const char* sz_nine_ten_m_q2 [5][8] = {
    // 25     50        100        200        400      500        1000    1650
    {  NULL,   "34.59", "1:19.09", "2:55.69", NULL,    "8:05.99", NULL,    NULL   },  // free
    {  NULL,   "41.69", "1:32.29", NULL,      NULL,    NULL,      NULL,    NULL   },  // back
    {  NULL,   "48.09", "1:44.29", NULL,      NULL,    NULL,      NULL,    NULL   },  // breast
    {  NULL,   "42.69", "1:40.59", NULL,      NULL,    NULL,      NULL,    NULL   },  // fly
    {  NULL,   NULL,    "1:30.99", "3:24.69", NULL,    NULL,      NULL,    NULL   }   // IM
};
const char* sz_nine_ten_m_b [5][8] = {
    // 25     50        100        200        400      500        1000    1650
    {  NULL,   "38.89", "1:29.19", "3:09.89", NULL,    "8:25.79", NULL,   NULL   },  // free
    {  NULL,   "49.19", "1:42.89", NULL,      NULL,    NULL,      NULL,   NULL   },  // back
    {  NULL,   "53.59", "1:55.69", NULL,      NULL,    NULL,      NULL,   NULL   },  // breast
    {  NULL,   "47.29", "1:55.19", NULL,      NULL,    NULL,      NULL,   NULL   },  // fly
    {  NULL,   NULL,    "1:41.29", "3:40.89", NULL,    NULL,      NULL,   NULL   }   // IM
};

const char* sz_eleven_twelve_m_q1 [5][8] = {
    // 25      50     100          200        400       500        1000    1650
    {  NULL,   "28.09", "1:01.59", "2:14.59", NULL,     "6:00.59", NULL,   NULL   },  // free
    {  NULL,   "33.29", "1:11.69", "2:34.79", NULL,      NULL,     NULL,   NULL   },  // back
    {  NULL,   "37.79", "1:21.69", "2:59.99", NULL,      NULL,     NULL,   NULL   },  // breast
    {  NULL,   "32.09", "1:13.99", "2:55.89", NULL,      NULL,     NULL,   NULL   },  // fly
    {  NULL,   NULL,    "1:12.79", "2:35.49", "5:35.79", NULL,     NULL,   NULL   }   // IM
};

const char* sz_eleven_twelve_m_q2 [5][8] = {
    // 25     50       100        200        400        500        1000    1650
    {  NULL,  "30.59", "1:09.19", "2:32.99", NULL,      "6:42.19", NULL,   NULL   },  // free
    {  NULL,  "37.09", "1:20.19", "3:09.59", NULL,      NULL,      NULL,   NULL   },  // back
    {  NULL,  "41.99", "1:32.09", "3:25.79", NULL,      NULL,      NULL,   NULL   },  // breast
    {  NULL,  "36.29", "1:26.69", "3:23.99", NULL,      NULL,      NULL,   NULL   },  // fly
    {  NULL,   NULL,   "1:20.29", "2:55.69", "6:30.89", NULL,      NULL,   NULL   }   // IM
};

const char* sz_eleven_twelve_m_b [5][8] = {
    // 25     50       100        200        400        500        1000        1650
    {  NULL,  "33.39", "1:13.09", "2:38.89", NULL,      "7:05.49", "14:50.09", "24:57.49"   },  // free
    {  NULL,  "39.49", "1:25.79", "2:58.39", NULL,      NULL,      NULL,       NULL         },  // back
    {  NULL,  "44.29", "1:35.09", "3:21.69", NULL,      NULL,      NULL,       NULL         },  // breast
    {  NULL,  "38.19", "1:25.79", "3:01.19", NULL,      NULL,      NULL,       NULL         },  // fly
    {  NULL,  NULL,    "1:23.69", "3:03.09", "6:23.69", NULL,      NULL,       NULL         }   // IM
};

const char* sz_eleven_twelve_w_q1 [5][8] = {
    // 25     50       100        200        400        500        1000        1650
    {  NULL,  "27.89", "1:00.79", "2:13.39", NULL,      "5:53.49", "15:00.29", "25:16.19" },  // free
    {  NULL,  "32.59", "1:10.09", "2:30.89", NULL,      NULL,      NULL,       NULL       },  // back
    {  NULL,  "36.59", "1:20.19", "2:51.99", NULL,      NULL,      NULL,       NULL       },  // breast
    {  NULL,  "31.09", "1:11.29", "2:45.49", NULL,      NULL,      NULL,       NULL       },  // fly
    {  NULL,  NULL,    "1:10.79", "2:32.09", "5:25.59", NULL,      NULL,       NULL       }   // IM
};
const char* sz_eleven_twelve_w_q2 [5][8] = {
    // 25     50       100        200        400        500        1000        1650
    {  NULL,  "29.09", "1:05.09", "2:24.39", NULL,      "6:27.99", NULL,       NULL       },  // free
    {  NULL,  "35.09", "1:16.39", "2:48.09", NULL,      NULL,      NULL,       NULL       },  // back
    {  NULL,  "39.99", "1:27.69", "3:11.09", NULL,      NULL,      NULL,       NULL       },  // breast
    {  NULL,  "34.19", "1:22.99", "3:12.59", NULL,      NULL,      NULL,       NULL       },  // fly
    {  NULL,  NULL,    "1:16.29", "2:47.59", "6:19.89", NULL,      NULL,       NULL       }   // IM
};
const char* sz_eleven_twelve_w_b [5][8] = {
    // 25     50       100        200        400        500        1000        1650
    {  NULL,  "34.29", "1:13.59", "2:43.19", NULL,      "7:10.79", "15:00.29", "25:16.19" },  // free
    {  NULL,  "39.59", "1:27.99", "3:01.89", NULL,      NULL,      NULL,       NULL       },  // back
    {  NULL,  "44.09", "1:36.39", "3:26.39", NULL,      NULL,      NULL,       NULL       },  // breast
    {  NULL,  "37.79", "1:27.19", "3:04.99", NULL,      NULL,      NULL,       NULL       },  // fly
    {  NULL,  NULL,    "1:26.29", "3:03.79", "6:32.19", NULL,      NULL,       NULL       }   // IM
};

// 13-14 M ---------------------------------------------------------------------
const char* sz_thirteen_fourteen_m_q1 [5][8] = {
    // 25     50        100        200        400      500        1000        1650
    {  NULL,   "25.29", "54.89",   "1:59.99", NULL,    "5:25.09", "11:19.99", "19:17.99" },  // free
    {  NULL,   NULL,    "1:04.09", "2:18.09", NULL,    NULL,    NULL,    NULL   },  // back
    {  NULL,   NULL,    "1:12.49", "2:38.09", NULL,    NULL,    NULL,    NULL   },  // breast
    {  NULL,   NULL,    "1:02.39", "2:26.69", NULL,    NULL,    NULL,    NULL  },  // fly
    {  NULL,   NULL,    NULL,      "2:16.89", "4:59.99", NULL,    NULL,  NULL   }   // IM
};

const char* sz_thirteen_fourteen_m_q2 [5][8] = {
    // 25     50       100        200        400        500        1000        1650
    {  NULL,  "27.09", "58.89",   "2:11.09", NULL,      "5:53.69", "12:35.59", "21:19.99" },  // free
    {  NULL,   NULL,   "1:10.99", "2:35.99", NULL,      NULL,      NULL,       NULL   },  // back
    {  NULL,   NULL,   "1:19.49", "2:54.49", NULL,      NULL,      NULL,       NULL  },  // breast
    {  NULL,   NULL,   "1:09.99", "2:41.99", NULL,      NULL,      NULL,       NULL  },  // fly
    {  NULL,   NULL,   NULL,      "2:28.99", "5:24.99", NULL,      NULL,       NULL   }   // IM
};
const char* sz_thirteen_fourteen_m_b [5][8] = {
    // 25     50       100        200        400        500        1000        1650
    {  NULL,  "30.69", "1:06.99", "2:26.09", NULL,      "6:31.09", "13:32.49", "22:28.29" },  // free
    {  NULL,   NULL,   "1:14.89", "2:41.29", NULL,      NULL,      NULL,       NULL   },  // back
    {  NULL,   NULL,   "1:24.09", "3:02.39", NULL,      NULL,      NULL,       NULL  },  // breast
    {  NULL,   NULL,   "1:13.29", "2:43.69", NULL,      NULL,      NULL,       NULL  },  // fly
    {  NULL,   NULL,   NULL,      "2:43.69", "5:50.59", NULL,      NULL,       NULL   }   // IM
};
const char* sz_thirteen_fourteen_w_q1 [5][8] = {
    // 25     50        100        200        400      500        1000        1650
    {  NULL,   "26.39", "57.09",   "2:03.89", NULL,    "5:32.99", "11:35.99", "19:35.99" },  // free
    {  NULL,   NULL,    "1:05.09", "2:20.99", NULL,    NULL,    NULL,    NULL   },  // back
    {  NULL,   NULL,    "1:13.99", "2:41.99", NULL,    NULL,    NULL,    NULL   },  // breast
    {  NULL,   NULL,    "1:04.79", "2:27.99", NULL,    NULL,    NULL,    NULL  },  // fly
    {  NULL,   NULL,    NULL,      "2:22.09", "5:03.89", NULL,    NULL,  NULL   }   // IM
};

const char* sz_thirteen_fourteen_w_q2 [5][8] = {
    // 25     50        100        200       400        500         1000       1650
    {  NULL,  "27.59", "59.89",   "2:11.69", NULL,      "5:50.99", "12:33.39", "20:57.09" },  // free
    {  NULL,   NULL,   "1:09.59", "2:29.89", NULL,      NULL,      NULL,       NULL   },  // back
    {  NULL,   NULL,   "1:20.69", "2:55.09", NULL,      NULL,      NULL,       NULL  },  // breast
    {  NULL,   NULL,   "1:10.29", "2:48.59", NULL,      NULL,      NULL,       NULL  },  // fly
    {  NULL,   NULL,   NULL,      "2:28.99", "5:26.89", NULL,      NULL,       NULL   }   // IM
};
const char* thirteen_fourteen_w_b [5][8] = {
    // 25     50       100         200       400        500        1000        1650
    {  NULL,  "33.39", "1:12.49", "2:36.09", NULL,      "6:51.79", "14:08.89", "23:34.19" },  // free
    {  NULL,   NULL,   "1:19.89", "2:51.79", NULL,      NULL,      NULL,       NULL   },  // back
    {  NULL,   NULL,   "1:30.59", "3:14.59", NULL,      NULL,      NULL,       NULL  },  // breast
    {  NULL,   NULL,   "1:19.09", "2:53.39", NULL,      NULL,      NULL,       NULL  },  // fly
    {  NULL,   NULL,   NULL,      "2:55.49", "6:10.79", NULL,      NULL,       NULL   }   // IM
};

const char* sz_fifteen_eighteen_m_q1 [5][8] = {
    // 25     50        100        200        400        500        1000        1650
    {  NULL,   "23.29", "50.59",   "1:51.89", NULL,      "5:03.99", "10:40.19", "18:10.49" },  // free
    {  NULL,   NULL,    "58.99",   "2:09.19", NULL,      NULL,    NULL,    NULL   },  // back
    {  NULL,   NULL,    "1:06.69", "2:27.99", NULL,      NULL,    NULL,    NULL   },  // breast
    {  NULL,   NULL,    "57.09",   "2:15.99", NULL,      NULL,    NULL,    NULL   },  // fly
    {  NULL,   NULL,    NULL,      "2:06.99", "4:40.99", NULL,    NULL,    NULL   }   // IM
};
const char* sz_fifteen_eighteen_m_q2 [5][8] = {
    // 25     50       100        200        400        500        1000        1650
    {  NULL,  "27.09", "58.89",   "2:11.09", NULL,      "5:53.69", "12:35.59", "21:19.99" },  // free
    {  NULL,   NULL,   "1:10.99", "2:35.99", NULL,      NULL,      NULL,       NULL   },  // back
    {  NULL,   NULL,   "1:19.49", "2:54.49", NULL,      NULL,      NULL,       NULL  },  // breast
    {  NULL,   NULL,   "1:09.99", "2:41.99", NULL,      NULL,      NULL,       NULL  },  // fly
    {  NULL,   NULL,   NULL,      "2:28.99", "5:24.99", NULL,      NULL,       NULL   }   // IM
};
const char* sz_fifteen_eighteen_m_b [5][8] = {
    // 25     50        100        200        400        500        1000        1650
    {  NULL,   "29.49", "1:04.39", "2:20.09", NULL,      "6:18.39", "13:04.19", "21:55.89" },  // free
    {  NULL,   NULL,    "1:11.29", "2:34.39", NULL,      NULL,    NULL,    NULL   },  // back
    {  NULL,   NULL,    "1:20.39", "2:55.09", NULL,      NULL,    NULL,    NULL   },  // breast
    {  NULL,   NULL,    "1:10.09", "2:35.59", NULL,      NULL,    NULL,    NULL   },  // fly
    {  NULL,   NULL,    NULL,      "2:37.69", "5:35.79", NULL,    NULL,    NULL   }   // IM
};

const char* sz_fifteen_eighteen_w_q1 [5][8] = {
    // 25     50        100        200        400        500        1000        1650
    {  NULL,   "25.59", "55.59",   "2:00.79", NULL,      "5:23.29", "11:20.99", "18:58.89" },  // free
    {  NULL,   NULL,    "1:03.09", "2:16.99", NULL,      NULL,    NULL,    NULL   },  // back
    {  NULL,   NULL,    "1:13.09", "2:39.69", NULL,      NULL,    NULL,    NULL   },  // breast
    {  NULL,   NULL,    "1:02.09", "2:23.39", NULL,      NULL,    NULL,    NULL   },  // fly
    {  NULL,   NULL,    NULL,      "2:16.99", "4:54.29", NULL,    NULL,    NULL   }   // IM
};
const char* sz_fifteen_eighteen_w_q2 [5][8] = {
    // 25     50     100    200     400    500      1000    1650
    {  NULL,  "27.59", "59.89",   "2:11.69", NULL,      "5:50.99", "12:33.39", "20:57.09" },  // free
    {  NULL,   NULL,   "1:09.59", "2:29.89", NULL,      NULL,      NULL,       NULL   },  // back
    {  NULL,   NULL,   "1:20.69", "2:55.09", NULL,      NULL,      NULL,       NULL  },  // breast
    {  NULL,   NULL,   "1:10.29", "2:48.59", NULL,      NULL,      NULL,       NULL  },  // fly
    {  NULL,   NULL,   NULL,      "2:28.99", "5:26.89", NULL,      NULL,       NULL   }   // IM
};
const char* sz_fifteen_eighteen_w_b [5][8] = {
    // 25     50        100        200        400        500         1000       1650
    {  NULL,   "32.69", "1:10.89", "2:32.09", NULL,      "6:45.29", "13:55.19", "23:18.79" },  // free
    {  NULL,   NULL,    "1:17.69", "2:47.89", NULL,      NULL,      NULL,    NULL   },  // back
    {  NULL,   NULL,    "1:28.29", "3:09.99", NULL,      NULL,      NULL,    NULL   },  // breast
    {  NULL,   NULL,    "1:17.39", "2:48.59", NULL,      NULL,      NULL,    NULL   },  // fly
    {  NULL,   NULL,    NULL,      "2:51.49", "6:01.49", NULL,      NULL,    NULL   }   // IM
};

+(float) getFloatTimeFromCStringTime:(const char*)sz 
{
    NSString* s = [NSString stringWithUTF8String:sz == NULL ? "0" : sz];
    return [TimeStandard getFloatTimeFromStringTime:s];
}

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
    const char* sz_q1 [5][8] = { NULL };
    const char* sz_q2 [5][8] = { NULL };
    const char* sz_b [5][8] = { NULL };
    
    // quick sanity check on the array values
    memcpy(sz_q1,sz_nine_ten_w_q1,sizeof(sz_q1));
    assert( strcmp("31.49",sz_q1[0][1]) == 0);
    
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
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
            if ([gender isEqualToString:@"m"]) {
               memcpy(sz_q1,sz_nine_ten_m_q1,sizeof(sz_q1));
               memcpy(sz_q2,sz_nine_ten_m_q2,sizeof(sz_q2));
               memcpy(sz_b,sz_nine_ten_m_b,sizeof(sz_b));
            } else {
                memcpy(sz_q1,sz_nine_ten_w_q1,sizeof(sz_q1));
                memcpy(sz_q2,sz_nine_ten_w_q2,sizeof(sz_q2));
                memcpy(sz_b,sz_nine_ten_w_b,sizeof(sz_b));
            }
            break;
          
        case 11:
        case 12:
            if ([gender isEqualToString:@"m"]) {
                memcpy(sz_q1,sz_eleven_twelve_m_q1,sizeof(sz_q1));
                memcpy(sz_q2,sz_eleven_twelve_m_q2,sizeof(sz_q2));
                memcpy(sz_b,sz_eleven_twelve_m_b,sizeof(sz_b));
            } else {
                memcpy(sz_q1,sz_eleven_twelve_w_q1,sizeof(sz_q1));
                memcpy(sz_q2,sz_eleven_twelve_w_q2,sizeof(sz_q2));
                memcpy(sz_b,sz_eleven_twelve_w_b,sizeof(sz_b));
            }
            break;
            
        case 13:
        case 14:
            if ([gender isEqualToString:@"m"]) {
                memcpy(sz_q1,sz_thirteen_fourteen_m_q1,sizeof(sz_q1));
                memcpy(sz_q2,sz_thirteen_fourteen_m_q2,sizeof(sz_q2));
                memcpy(sz_b,sz_thirteen_fourteen_m_b,sizeof(sz_b));
            } else {
                memcpy(sz_q1,sz_thirteen_fourteen_w_q1,sizeof(sz_q1));
                memcpy(sz_q2,sz_thirteen_fourteen_w_q2,sizeof(sz_q2));
                memcpy(sz_b,sz_thirteen_fourteen_m_b,sizeof(sz_b));
            }
            break;
          
        default:
            // 15-18, or Open
            if ([gender isEqualToString:@"m"]) {
                memcpy(sz_q1,sz_fifteen_eighteen_m_q1,sizeof(sz_q1));
                memcpy(sz_q2,sz_fifteen_eighteen_m_q2,sizeof(sz_q2));
                memcpy(sz_b,sz_fifteen_eighteen_m_b,sizeof(sz_b));
            } else {
                memcpy(sz_q1,sz_fifteen_eighteen_w_q1,sizeof(sz_q1));
                memcpy(sz_q2,sz_fifteen_eighteen_w_q2,sizeof(sz_q2));
                memcpy(sz_b,sz_fifteen_eighteen_w_b,sizeof(sz_b));
            }
            
            break;
    }
    
    if (sz_q1 != NULL) {
        float fQ1 = [TimeStandard getFloatTimeFromCStringTime:sz_q1[stroke-1][distanceidx]];
        float fQ2 = [TimeStandard getFloatTimeFromCStringTime:sz_q2[stroke-1][distanceidx]];
        float fB = [TimeStandard getFloatTimeFromCStringTime:sz_b[stroke-1][distanceidx]];
        if (time <= fQ1) {
            return @"Q1";
        }
        if (time <= fQ2) {
            return [NSString stringWithFormat:@"Q2 (Q1+%2.2f)",time-fQ1];
        }
        if (time <= fB) {
            return [NSString stringWithFormat:@"B (Q2+%2.2f)",time-fQ2];
        }

    }
   
    return @"";
}

@end

