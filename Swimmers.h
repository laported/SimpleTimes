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
    NSMutableArray* _athletes;  
    NSArray*        _athletesCD;
    int             _count;
}

@property (retain) NSMutableArray *athletes;
@property (retain) NSArray *athletesCD;

-(void) loadWithContext:(NSManagedObjectContext *)context;
-(int)  count;

#ifdef DEBUG
+(void) seedTestDataUsingContext:(NSManagedObjectContext *)context ;
+(void) deleteAllUsingContext:(NSManagedObjectContext *)context;
#endif

// Int values 1 = Freestyle, 2 = Back, 3 = Breast, 4 = Fly, 5 = IM
+ (int)intStrokeValue:(NSString*)stroke;

-(BOOL) isSameRaceInDB:(RaceResult*)r1 asMIRace:(RaceResultMI*)r2 ;

-(void) updateAllRaceResultsForAthlete:(AthleteCD*)athlete inContext:(NSManagedObjectContext *)context;

@end
