//
//  DetailSwimmerViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 1/29/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AthleteCD.h"
#import "TopTimesViewController.h"
#import "Swimmers.h"

@interface DetailSwimmerViewController : UIViewController
{
    AthleteCD* _athlete;
    CUTS _cuts;
    TopTimesViewController* _topTimes;
    Swimmers* _swimmers;
    NSManagedObjectContext* _moc;
}
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel* labelTitle;
@property (retain, nonatomic) IBOutlet UILabel* labelCuts;
@property (retain, nonatomic) IBOutlet UIPageControl* pageControl;

- (IBAction)changePage:(id)sender;
- (id)initWithAthlete:(AthleteCD*)athlete;

- (void) setAthlete:(AthleteCD*) a;
- (void) setMOC:(NSManagedObjectContext *)managedObjectContext;

@end
