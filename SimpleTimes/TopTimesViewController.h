//
//  TopTimesViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 1/30/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AthleteCD.h"
#import "RaceResult.h"

@interface TopTimesViewController : UITableViewController
{
    AthleteCD* _athlete;
    NSArray* _races;
}

- (void) setAthlete:(AthleteCD *)a;

@end
