//
//  RaceResult.h
//  SimpleTimes
//
//  Created by David LaPorte on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AthleteCD;

@interface RaceResult : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * stroke;
@property (nonatomic, retain) NSString * course;
@property (nonatomic, retain) NSString * standard;
@property (nonatomic, retain) NSString * meet;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * splitskey;
@property (nonatomic, retain) NSNumber * powerpoints;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) AthleteCD * athlete;
@property (nonatomic, retain) NSSet*    splits;

- (NSComparisonResult)compareByTime:(RaceResult *)otherObject;

@end
