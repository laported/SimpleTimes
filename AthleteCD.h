//
//  AthleteCD.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AthleteCD : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * club;
@property (nonatomic, retain) NSDate * birthdate;
@property (nonatomic, retain) NSNumber * miswimid;
@property (nonatomic, retain) NSString * gender;

@end
