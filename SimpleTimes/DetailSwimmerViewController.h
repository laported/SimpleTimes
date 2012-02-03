//
//  DetailSwimmerViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 1/29/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AthleteCD.h"
#import "TopTimesViewController.h"

@interface DetailSwimmerViewController : UIViewController
{
    AthleteCD* _athlete;
    TopTimesViewController* _topTimes;
}
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel* labelTitle;

- (IBAction)addButtonSelected:(id)sender; 
- (void) setAthlete:(AthleteCD*) a;

@end
