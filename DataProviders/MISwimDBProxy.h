//
//  MISwimDBProxy.h
//  simpletimes
//
//  Created by David LaPorte on 7/2/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISwimDBProxy : NSObject {
}

- (NSArray *) getAllTimesForAthlete:(int)athleteId;
- (NSArray *) getAllTimesForAthlete:(int)athleteId:(int)stroke:(int)distance;
- (NSArray *) getSplitsForRace:(int)raceId;
- (NSArray *) findAthlete:(NSString*)lastname;
- (NSArray *) findAthlete:(NSString*)lastname:(NSString*)firstname;


- (NSString *) extractElementFromString:(NSString*)source:(NSString*)prefix:(NSString*)postfix;
- (NSString *) getAthleteTable:(NSString *)srcString ;
- (NSString *) getTimesTable:(NSString*)srcString ;
- (NSString *) getSplitsTable:(NSString *)srcString;

@end
