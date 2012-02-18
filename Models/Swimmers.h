//
//  Swimmers.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/27/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AthleteCD.h"
#import "RaceResult.h"
#import "RaceResultMI.h"

@interface Swimmers : NSObject {
    NSArray*        _athletesCD;
}

@property (retain) NSArray *athletesCD;

- (void) loadWithContext:(NSManagedObjectContext *)context;
-(void) loadAllWithContext:(NSManagedObjectContext*)context withResultsHavingCourse:(NSString*)course;
- (int)  count;

#ifdef DEBUG
+ (void) seedTestDataUsingContext:(NSManagedObjectContext *)context ;
+ (void) deleteAllUsingContext:(NSManagedObjectContext *)context;
#endif

+ (int)  updateAllRaceResultsForAthlete:(AthleteCD*)athlete withResults:(NSArray*)times inContext:(NSManagedObjectContext *)context ;

// Int values 1 = Freestyle, 2 = Back, 3 = Breast, 4 = Fly, 5 = IM
+ (int)  intStrokeValue:(NSString*)stroke;
+ (BOOL) isRaceInStore:(RaceResultMI*)race inContext:(NSManagedObjectContext *)context athlete:(AthleteCD*)athlete;
+ (void) storeRace:(RaceResultMI *)raceMI forAthlete:(AthleteCD*)athlete inContext:(NSManagedObjectContext*)context downloadSplits:(BOOL)splits;

+ (BOOL) isSameRaceInDB:(RaceResult*)r1 asMIRace:(RaceResultMI*)r2 ;

- (void) updateAllRaceResultsForAthlete:(AthleteCD*)athlete fromTMDatabase:(NSString*)db inContext:(NSManagedObjectContext *)context;

@end
