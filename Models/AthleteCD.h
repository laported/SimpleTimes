//
//  AthleteCD.h
//  SimpleTimes
//
//  Created by David LaPorte on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RaceResult;

@interface AthleteCD : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString* club;
@property (nonatomic, retain) NSString* lastname;
@property (nonatomic, retain) NSString* gender;
@property (nonatomic, retain) NSNumber* miswimid;
@property (nonatomic, retain) NSDate*   birthdate;
@property (nonatomic, retain) NSString* firstname;
@property (nonatomic, retain) NSSet*    races;

struct tCuts {
    int jos;
    int states;
    int sectionals;
    int nationals;
    //    tCuts(int j, int st, int se, int n) {
    //        jos = j;
    //        states = st;
    //        sectionals = se;
    //        nationals = n;
    //    }
} ;
typedef struct tCuts CUTS;
typedef CUTS* PCUTS;

struct tMhsaaCuts {
    int miscas;
    int states;
} ;
typedef struct tMhsaaCuts MHSAACUTS;
typedef MHSAACUTS* PMHSAACUTS;

- (int)      ageAtDate:(NSDate*)date ;
- (void)     countCuts:(PCUTS)cuts;
- (void)     countCutsMHSAA:(PMHSAACUTS)cuts;
- (NSArray*) allResults;              // and array of all available RaceResult objects
- (NSArray*) allResultsByDate ;
- (NSArray*) allResultsSinceDate:(NSDate*)date ;
//- (int)      countOfRacesWithStroke:(int)stroke andDistance:(int)distance;
- (NSArray*) personalBests;           // an array of RaceResult objects
- (NSArray*) personalBestsSinceDate:(NSDate*)date;  // an array of RaceResult objects
- (NSArray*) allStrokesWithResults;   // an array of (unique) stroke names for which this athlete has results
- (NSArray*) allDistancesForStroke:(int)stroke;

@end
