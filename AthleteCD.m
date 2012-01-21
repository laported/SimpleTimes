//
//  AthleteCD.m
//  SimpleTimes
//
//  Created by David LaPorte on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AthleteCD.h"


@implementation AthleteCD
@dynamic club;
@dynamic lastname;
@dynamic gender;
@dynamic miswimid;
@dynamic birthdate;
@dynamic firstname;
@dynamic races;

-(int) ageAtDate:(NSDate*)date {
    NSLog(@"ageAtDateString: age=%@ date=%@",self.birthdate,date);
    NSInteger years = [[[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                       fromDate: self.birthdate
                                                         toDate: date
                                                        options: 0] year];
    NSLog(@"returning %d",years);
    return (int)years;
}

@end
