//
//  AthleteCD.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AthleteCD.h"


@implementation AthleteCD
@dynamic firstname;
@dynamic lastname;
@dynamic club;
@dynamic birthdate;
@dynamic miswimid;
@dynamic gender;

-(int) ageAtDate:(NSDate*)date {
    // TODO
    NSLog(@"ageAtDateString: age=%@ date=%@",self.birthdate,date);
    NSInteger years = [[[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                       fromDate: self.birthdate
                                                         toDate: date
                                                        options: 0] year];
    NSLog(@"returning %d",years);
    return (int)years;
}

@end
