//
//  AllTimesViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/4/12.
//  Copyright (c) 2012 David LaPorte. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AthleteCD.h"
#import "RaceResult.h"

@interface AllTimesViewController : UIViewController
{
    AthleteCD* _athlete;
    NSArray* _races;
    NSMutableArray* _labels;
}

- (void) setAthlete:(AthleteCD *)a;

@end

