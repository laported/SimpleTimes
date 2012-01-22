//
//  AthleteCD.m
//  SimpleTimes
//
//  Created by David LaPorte on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AthleteCD.h"
#import "TimeStandard.h"
#import "RaceResult.h"
#import "Swimmers.h"

@implementation AthleteCD
@dynamic club;
@dynamic lastname;
@dynamic gender;
@dynamic miswimid;
@dynamic birthdate;
@dynamic firstname;
@dynamic races;

-(int) ageAtDate:(NSDate*)date {
    NSLog(@"ageAtDateString: age=%@ date=%@",self.birthdate,date);
    NSInteger years = [[[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                       fromDate: self.birthdate
                                                         toDate: date
                                                        options: 0] year];
    NSLog(@"returning %d",years);
    return (int)years;
}

- (void) countCuts:(PCUTS)cuts {
    NSArray* times = [self personalBests];
    NSDate* dateOfJOMeet;
    NSDate* dateOfStateMeet;
    NSDate* dateOfSectionalsMeet;
    NSDate* dateOfNationalsMeet;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    cuts->jos = 0;
    cuts->states = 0;
    cuts->sectionals = 0;
    cuts->nationals = 0;

    dateOfJOMeet = [df dateFromString:@JO_DATE];
    dateOfStateMeet = [df dateFromString:@STATE_DATE];
    dateOfSectionalsMeet = [df dateFromString: @SECTIONALS_DATE];
    dateOfNationalsMeet = [df dateFromString: @NATIONALS_DATE];
    [df release];

    for (int k=0;k<[times count];k++) {
        RaceResult* race = [times objectAtIndex:k];

        float ftime = [TimeStandard getFloatTimeFromStringTime:race.time];
        int nStroke = [Swimmers intStrokeValue:race.stroke];
        
        NSString *timestd = [TimeStandard getTimeStandardWithAge:[self ageAtDate:dateOfStateMeet] distance:[race.distance intValue] stroke:nStroke gender:self.gender time:ftime];
        
        if ([timestd hasPrefix:@"Q1"]) {
            cuts->states++;
        }
        
        timestd = [TimeStandard getTimeStandardWithAge:[self ageAtDate:dateOfJOMeet] distance:[race.distance intValue] stroke:nStroke gender:self.gender time:ftime];
        
        if ([timestd hasPrefix:@"Q2"]) {
            NSLog(@"JO Cut: %@ : %@ : %@",race.distance,race.stroke,race.time);
            cuts->jos++;
        }
    }
}

- (NSArray*)personalBests {
    NSMutableArray* strokes;
    NSMutableArray* all_requested_times = [NSMutableArray array];
    NSArray*        all_sorted_requested_times = nil;
    NSSet*          raceSet = self.races;
    NSArray *       times = [raceSet allObjects];
    
    int distances[] = { 25, 50, 100, 200, 500, 1000, 1650 };
    strokes   = [NSArray arrayWithObjects:@"Fly", @"Back", @"Breast", @"Free", @"IM", nil];
    
    for (int i=0;i<sizeof(distances)/sizeof(distances[0]);i++) {
        for (int j=0;j<[strokes count]; j++) {
            float       besttime = 9999999999.0;
            RaceResult* bestrace = nil;
            RaceResult* race = nil;
            for (int k=0;k<[times count];k++) {
                race = [times objectAtIndex:k];
                
                if ([race.distance intValue] != distances[i])
                    continue;
                if ([Swimmers intStrokeValue:race.stroke] != [Swimmers intStrokeValue:[strokes objectAtIndex:j]])
                    continue;
                
                float comptime = [TimeStandard getFloatTimeFromStringTime:race.time];
                if (comptime < besttime) {
                    /* this race is the new best */
                    bestrace = race;
                    besttime = comptime;
                }
            }
            if (bestrace != nil) {
                [all_requested_times addObject:bestrace];
            }
        }
    }
    
    all_sorted_requested_times = [all_requested_times sortedArrayUsingSelector:@selector(compareByDistance:)];        

    return all_sorted_requested_times;
}

@end