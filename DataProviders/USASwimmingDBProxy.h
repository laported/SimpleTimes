//
//  USASwimmingDBProxy.h
//

#import <Foundation/Foundation.h>
//#include "Swimmer.h"

@interface USASwimmingDBProxy : NSObject {
}

- (NSString*) enumAllAthletes:(NSString*)lastnamefirstletter;
- (NSArray *) getAllTimesForAthlete:(int)athleteId;
- (NSArray *) getAllTimesForAthlete:(int)athleteId stroke:(int)stroke distance:(int)distance;
- (NSArray *) findAthlete:(NSString*)lastname;
- (NSArray *) findAthlete:(NSString*)lastname firstname:(NSString*)firstname;


- (NSString *) extractElementFromString:(NSString*)source prefix:(NSString*)prefix postfix:(NSString*)postfix;
- (NSString *) getAthleteTable:(NSString *)srcString ;
- (NSString *) getTimesTable:(NSString*)srcString ;

@end
