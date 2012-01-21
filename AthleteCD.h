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
@property (nonatomic, retain) NSString * club;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * miswimid;
@property (nonatomic, retain) NSDate * birthdate;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSSet* races;

-(int) ageAtDate:(NSDate*)date ;

@end
