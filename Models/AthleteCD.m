//
//  AthleteCD.m
//  SimpleTimes
//
//  Created by David LaPorte on 12/2/11.
//  Copyright (c) 2011 laporte6.org. All rights reserved.
//

#import "AthleteCD.h"
#import "TimeStandard.h"
#import "RaceResult.h"
#import "Swimmers.h"
#import "Swimming.h"
#import "TimeStandardUssScy.h"

@implementation AthleteCD
@dynamic club;
@dynamic lastname;
@dynamic gender;
@dynamic miswimid;
@dynamic birthdate;
@dynamic firstname;
@dynamic races;

-(int) ageAtDate:(NSDate*)date {
    //NSLog(@"ageAtDateString: age=%@ date=%@",self.birthdate,date);
    NSInteger years = [[[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                       fromDate: self.birthdate
                                                         toDate: date
                                                        options: 0] year];
    //NSLog(@"returning %d",years);
    return (int)years;
}

- (void) countCutsMHSAA:(PMHSAACUTS)cuts
{
    NSArray* times = [self personalBests];
    
    cuts->miscas = 0;
    cuts->states = 0;
    
    for (int k=0;k<[times count];k++) {
        RaceResult* race = [times objectAtIndex:k];
        
        float ftime = [TimeStandard getFloatTimeFromStringTime:race.time];
        int nStroke = [Swimmers intStrokeValue:race.stroke];
        
        NSString *timestd = [TimeStandard getTimeStandardForMHSAAWithDistance:[race.distance intValue] stroke:nStroke gender:self.gender time:ftime];
        
        if ([timestd hasPrefix:@"STATE"]) {
            cuts->states++;
            continue;
        }
        
        timestd = [TimeStandard getTimeStandardForMHSAAWithDistance:[race.distance intValue] stroke:nStroke gender:self.gender time:ftime];
        
        if ([timestd hasPrefix:@"MISCA"]) {
            //NSLog(@"JO Cut: %@ %@ : %@ : %@",self.lastname, race.distance,race.stroke,race.time);
            cuts->miscas++;
        }
    }
}

// TODO MOVE TO TIMESTDUSS class
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

    dateOfJOMeet = [df dateFromString:JO_DATE];
    dateOfStateMeet = [df dateFromString:STATE12U_DATE]; // TODO Use 13 Over if needed
    dateOfSectionalsMeet = [df dateFromString: SECTIONALS_DATE];
    dateOfNationalsMeet = [df dateFromString: NATIONALS_DATE];
    [df release];

    for (int k=0;k<[times count];k++) {
        RaceResult* race = [times objectAtIndex:k];

        float ftime = [TimeStandard getFloatTimeFromStringTime:race.time];
        int nStroke = [Swimmers intStrokeValue:race.stroke];
        
        NSString *timestd = [TimeStandard getTimeStandardWithAge:[self ageAtDate:dateOfStateMeet] distance:[race.distance intValue] stroke:nStroke gender:self.gender time:ftime];
        
        if ([timestd hasPrefix:@"Q1"]) {
            cuts->states++;
            continue;
        }
        
        timestd = [TimeStandard getTimeStandardWithAge:[self ageAtDate:dateOfJOMeet] distance:[race.distance intValue] stroke:nStroke gender:self.gender time:ftime];
        
        if ([timestd hasPrefix:@"Q2"]) {
            //NSLog(@"JO Cut: %@ %@ : %@ : %@",self.lastname, race.distance,race.stroke,race.time);
            cuts->jos++;
        }
    }
}

// TODO 004
- (NSArray*)allResults 
{
    NSMutableArray* all_requested_times = [NSMutableArray array];
    NSArray*        all_sorted_requested_times = nil;
    NSSet*          raceSet = self.races;
    NSArray *       times = [raceSet allObjects];
    
    int distances[] = { 25, 50, 100, 200, 400, 500, 800, 1000, 1650 };
    NSArray* strokes = [[Swimming sharedInstance] getStrokes];
    
    for (int i=0;i<sizeof(distances)/sizeof(distances[0]);i++) {
        for (int j=0;j<[strokes count]; j++) {
            RaceResult* race = nil;
            for (int k=0;k<[times count];k++) {
                race = [times objectAtIndex:k];
                
                if ([race.distance intValue] != distances[i])
                    continue;
                if ([Swimmers intStrokeValue:race.stroke] != [Swimmers intStrokeValue:[strokes objectAtIndex:j]])
                    continue;
            }
            if (race != nil) {
                [all_requested_times addObject:race];
            }
        }
    }
    
    all_sorted_requested_times = [all_requested_times sortedArrayUsingSelector:@selector(compareByDistance:)];        
    
    NSLog(@"allResults:%@ times %08x, strokes %08x",self.firstname,(unsigned int)times,(unsigned int)strokes);
    NSLog(@"allResults:%@ returning %08x",self.firstname,(unsigned int)all_sorted_requested_times);
    return all_sorted_requested_times;
}

- (NSArray*) allResultsByDate 
{
    NSSortDescriptor* sortDescriptor1;
    NSSortDescriptor* sortDescriptor2;
    NSSortDescriptor* sortDescriptor3;
    NSArray *sortDescriptors;
    
    sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];  
    sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"meet" ascending:YES];  
    sortDescriptor3 = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];  
    sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];   
    return [self.races sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSArray*)personalBests {
    NSMutableArray* all_requested_times = [NSMutableArray array];
    NSArray*        all_sorted_requested_times = nil;
    NSSet*          raceSet = self.races;
    NSArray *       times = [raceSet allObjects];
    
    int distances[] = { 25, 50, 100, 200, 400, 500, 1000, 1650 };
    NSArray* strokes = [[Swimming sharedInstance] getStrokes];
    
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

    //NSLog(@"personalBests: releasing %08x",(unsigned int)all_requested_times);
    //[all_requested_times release];
    
    //NSLog(@"personalBests:%@ times %08x, strokes %08x",self.firstname,(unsigned int)times,(unsigned int)strokes);
    //NSLog(@"personalBests:%@ returning %08x",self.firstname,(unsigned int)all_sorted_requested_times);
    // using singleton instance now - no need to release 
    // [strokes release];
    return all_sorted_requested_times;
}

// an array of (unique) stroke names for which this athlete has results
- (NSArray*) allStrokesWithResults
{
    //NSSet*          raceSet = self.races;
    //NSArray *       times = [raceSet allObjects];
    
    // TODO We should be able to do a query against the DB for this....something like
    // select distinct(stroke) from raceSet 
    
    // for now, return everything
    return [NSArray arrayWithObjects:@"Fly", @"Back", @"Breast", @"Free", @"IM", nil];
}

- (NSArray*) allDistancesForStroke:(int)stroke
{
    NSMutableArray* distances = [NSMutableArray array];
    NSString* strokeString = [[Swimming getStrokes] objectAtIndex:stroke-1];
    for (RaceResult* r in self.races) {
        if ([r.stroke isEqualToString:strokeString]) {
            [distances addObject:r.distance];
        }
    }
    // Get a unique set of distances
    NSSet *uniqueDistances = [NSSet setWithArray:distances];
    // Then sort that
    //NSArray* sorted = [uniqueDistances sortedArrayUsingDescriptors:<#(NSArray *)#> arra sortUsingSelector: @selector(compare];
   
    // TODO
    return NULL;    // todo 
}

@end
