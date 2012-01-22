//
//  USASwimmingDBProxy.h
//

#import <Foundation/Foundation.h>
//#include "Swimmer.h"

@interface USASwimmingDBProxy : NSObject {
}

- (NSString*)enumAllAthletes:(NSString*)lastnamefirstletter;
- (NSArray *)getAllTimesForAthlete:(int)athleteId;
- (NSArray *)getAllTimesForAthlete:(int)athleteId:(int)stroke:(int)distance;
- (NSArray *)findAthlete:(NSString*)lastname;
- (NSArray *)findAthlete:(NSString*)lastname:(NSString*)firstname;


- (NSString *)extractElementFromString:(NSString*)source:(NSString*)prefix:(NSString*)postfix;
- (NSString *) getAthleteTable:(NSString *)srcString ;
- (NSString *) getTimesTable:(NSString*)srcString ;

@end
