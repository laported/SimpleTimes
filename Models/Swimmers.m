//
//  Swimmers.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Swimmers.h"
#import "AthleteCD.h"
#import "SplitCD.h"
#import "Split.h"
#import "TeamManagerDBProxy.h"

@implementation Swimmers

@synthesize athletesCD = _athletesCD;

-(void)loadWithContext:(NSManagedObjectContext *)context {
    
    // Load all AthleteCD objects from the store
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AthleteCD" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    self.athletesCD = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Swimmers:loadWithContext() athletesCD=%08x, fetchRequest=%08x",(unsigned int)self.athletesCD,(unsigned int)fetchRequest);
    
    [fetchRequest release];
    
}

-(void) loadAllWithContext:(NSManagedObjectContext*)context withResultsHavingCourse:(NSString*)course
{
    // Load all AthleteCD objects from the store
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"ANY races.course MATCHES[c] %@",course];
    [fetchRequest setPredicate:filter];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AthleteCD" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    self.athletesCD = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Swimmers:loadWithContext() athletesCD=%08x, fetchRequest=%08x",(unsigned int)self.athletesCD,(unsigned int)fetchRequest);
    
    [fetchRequest release];
}

-(int) count {
    return [self.athletesCD count];
}

+(BOOL) isSameRaceInDB:(RaceResult*)r1 asMIRace:(RaceResultMI*)r2 {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components1 = [calendar components:flags fromDate:r1.date];
    NSDate* dateOnly1 = [calendar dateFromComponents:components1];
    
    NSDateComponents* components2 = [calendar components:flags fromDate:r2.date];
    NSDate* dateOnly2 = [calendar dateFromComponents:components2];
    
    // TODO: Any releases needed for calendar stuff???? 
    //NSLog(@"Comparing %@ to %@",dateOnly1,dateOnly2);
    if ([dateOnly1 compare:dateOnly2] != NSOrderedSame)
        return FALSE;
    
    //NSLog(@"Comparing '%@' to '%@'",r1.meet,r2.meet);
    if (![r1.meet isEqualToString:r2.meet])
        return FALSE;
    
    //NSLog(@"Comparing '%@' to '%@'",r1.stroke,r2.stroke);
    if (![r1.stroke isEqualToString:r2.stroke])
        return FALSE;
    
    if ([r1.distance intValue] != r2.distance)
        return FALSE;
    
    return TRUE;
}

+(BOOL) isRaceInStore:(RaceResultMI*)race inContext:(NSManagedObjectContext *)context athlete:(AthleteCD*)athlete 
{    
    BOOL isInStore = FALSE;
    // athlete.races is a list of all the athlete's races    
    NSSet *raceSet = athlete.races;
    NSArray *raceArray = [raceSet allObjects];
    
    for (RaceResult *raceDB in raceArray) {
        if ([self isSameRaceInDB:raceDB asMIRace:race]) {
            isInStore = TRUE;
            break;
        }
    }
  
    return isInStore;
}

+(void) storeRace:(RaceResultMI *)raceMI forAthlete:(AthleteCD*)athlete inContext:(NSManagedObjectContext*)context downloadSplits:(BOOL)downloadSplits 
{
    RaceResult *race = (RaceResult *)[NSEntityDescription insertNewObjectForEntityForName:@"RaceResult" inManagedObjectContext:context];
    race.time        = raceMI.time;
    race.stroke      = raceMI.stroke;
    race.course      = raceMI.course;
    race.standard    = raceMI.standard;
    race.meet        = raceMI.meet;
    race.date        = raceMI.date;
    race.splitskey   = [NSNumber numberWithInt:raceMI.key];
    race.powerpoints = [NSNumber numberWithInt:raceMI.powerpoints]; 
    race.distance    = [NSNumber numberWithInt:raceMI.distance];
    race.athlete     = athlete;
    
    if (raceMI.key > 0 && (raceMI.splits == nil) && downloadSplits) {
        TeamManagerDBProxy* proxy = [[[TeamManagerDBProxy alloc] initWithDBName:raceMI.tmDatabase] autorelease];
        raceMI.splits = [proxy getSplitsForRace:raceMI.key];
    }
    NSMutableSet* set1 = [[NSMutableSet alloc] initWithCapacity:[raceMI.splits count]];
    for (Split*sMI in raceMI.splits) {
        SplitCD* s = (SplitCD*)[NSEntityDescription insertNewObjectForEntityForName:@"SplitCD" inManagedObjectContext:context];
        s.distance   = [[NSNumber alloc] initWithInt:[sMI.distance intValue]];
        s.time       = sMI.time_split;
        s.cumulative = sMI.time_cumulative;
        [set1 addObject:s];
    }
    race.splits = set1;
    
    NSError *error;
    
    // here's where the actual save happens, and if it doesn't we print something out to the console
    if (![context save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }
}

-(void) updateAllRaceResultsForAthlete:(AthleteCD*)athlete fromTMDatabase:(NSString*)db inContext:(NSManagedObjectContext *)context {
    // algorithm for fetching from TM Online website:
    //
    // with the athlete id:
    //   getAllTimesForAthlete()
    //   for (time in times[] do) {
    //      Race key will be 'meet date' + 'meet name'
    //      if (notInDB()) {
    //         createDBRecord()
    //         insertDBRecord()
    //      }
    //   }
    TeamManagerDBProxy* proxy = [[[TeamManagerDBProxy alloc] initWithDBName:db] autorelease];    
    NSArray* times = [proxy getAllTimesForAthlete:[athlete.miswimid intValue]];
    [Swimmers updateAllRaceResultsForAthlete:athlete withResults:times inContext:context];
}

+(int) updateAllRaceResultsForAthlete:(AthleteCD*)athlete withResults:(NSArray*)times inContext:(NSManagedObjectContext *)context 
{
    int added = 0;
    for (RaceResultMI *result in times) {
        // Is this in the DB already????
        if (![self isRaceInStore:result inContext:context athlete:athlete]) {
            [self storeRace:result forAthlete:athlete inContext:context downloadSplits:NO];
            added++;
        }
    }
    return added;
}

+(int) intStrokeValue:(NSString*)stroke {
    if ([stroke isEqualToString:@"Free"])
        return 1;
    
    if ([stroke isEqualToString:@"Back"])
        return 2;
    
    if ([stroke isEqualToString:@"Breast"])
        return 3;
    
    if ([stroke isEqualToString:@"Fly"])
        return 4;
    
    if ([stroke isEqualToString:@"IM"])
        return 5;
    
    NSLog(@"OOPS!! Could not convert stroke to int value!!!!: %@",stroke);
    assert(false);
}

/*
/// @deprecated
-(void)load {
    
    // TODO: for now, hard code the athlete selection
    Athlete* a1 = [[Athlete alloc] initWithLastName:@"LaPorte" firstName:@"Benjamin" club:@"LCSC" key:11655];
    a1.age = 11;
    a1.gender = @"m";
    
    Athlete* a2 = [[Athlete alloc] initWithLastName:@"LaPorte" firstName:@"Matthew" club:@"LCSC" key:11657];
    a2.age = 14;
    a2.gender = @"m";
    
    Athlete* a3 = [[Athlete alloc] initWithLastName:@"LaPorte" firstName:@"Kelly" club:@"LCSC" key:11656];
    a3.age = 16;
    a3.gender = @"f";
    
    self.athletes = [NSMutableArray arrayWithObjects:
                     a1,a2,a3,nil];
    
}
*/
#ifdef DEBUG
+(void) deleteAllUsingContext:(NSManagedObjectContext *)context {
    NSFetchRequest * fetch = [[[NSFetchRequest alloc] init] autorelease];
    [fetch setEntity:[NSEntityDescription entityForName:@"AthleteCD" inManagedObjectContext:context]];
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    for (id a in result)
        [context deleteObject:a];
}

+(void) seedTestDataUsingContext:(NSManagedObjectContext *)context {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    /*
    AthleteCD *ath1 = [NSEntityDescription
                       insertNewObjectForEntityForName:@"AthleteCD" 
                       inManagedObjectContext:context];
    ath1.firstname = @"Benjamin";
    ath1.lastname = @"LaPorte";
    ath1.club = @"LCSC";
    ath1.birthdate = [dateFormatter dateFromString:@"01-29-2000"];
    ath1.miswimid = [[NSNumber alloc] initWithInt:11655];
    ath1.gender = @"m";
    */
    AthleteCD *ath2 = [NSEntityDescription
                       insertNewObjectForEntityForName:@"AthleteCD" 
                       inManagedObjectContext:context];
    ath2.firstname = @"Matt";
    ath2.lastname = @"LaPorte";
    ath2.club = @"LSTEV";
    ath2.birthdate = [dateFormatter dateFromString:@"07-10-1997"];
    ath2.miswimid = [[NSNumber alloc] initWithInt:342];
    ath2.gender= @"m";
    /*
    AthleteCD *ath3 = [NSEntityDescription
                       insertNewObjectForEntityForName:@"AthleteCD" 
                       inManagedObjectContext:context];
    ath3.firstname = @"Kelly";
    ath3.lastname = @"LaPorte";
    ath3.club = @"LCSC";
    ath3.birthdate = [dateFormatter dateFromString:@"07-23-1995"];
    ath3.miswimid = [[NSNumber alloc] initWithInt:11656];
    ath3.gender = @"f";
    */
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
   
    [dateFormatter release];
}
#endif

@end
