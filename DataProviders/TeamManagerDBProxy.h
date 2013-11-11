//
//  TeamManagerDBProxy.h
//  simpletimes
//
//  Created by David LaPorte on 7/2/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define MI_SWIM_DB    "upload%5CMichiganSwimmingLSCOfficeCopy.mdb"
//%7B = '{'
#define MI_SWIM_DB    "upload%5CMichiganSwimmingLSC%7B.mdb"
#define MISCA_SWIM_DB "upload%5CMHSAAMISCAOfficeCopy.mdb"

@interface TeamManagerDBProxy : NSObject {
    NSString* _dbName;
}

- (id) initWithDBName:(NSString *)dbName;

- (NSArray *) getAllTimesForAthlete:(int)athleteId;

#define STROKE_ALL   0
#define DISTANCE_ALL 0
- (NSArray *) getAllTimesForAthlete:(int)athleteId:(int)stroke:(int)distance;

- (NSArray *) getSplitsForRace:(int)raceId;
- (NSArray *) findAthlete:(NSString*)lastname;
- (NSArray *) findAthlete:(NSString*)lastname:(NSString*)firstname;


- (NSString *) extractElementFromString:(NSString*)source:(NSString*)prefix:(NSString*)postfix;
- (NSString *) getAthleteTable:(NSString *)srcString ;
- (NSString *) getTimesTable:(NSString*)srcString ;
- (NSString *) getSplitsTable:(NSString *)srcString;

@end
