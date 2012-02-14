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
#import "SwimmerPickerController.h"

@interface DetailSwimmerViewController : UIViewController <SwimmerPickerDelegate>
{
    AthleteCD* _athlete;
    CUTS _cuts;
    TopTimesViewController* _topTimes;
    NSOperationQueue* _queue;
    NSManagedObjectContext* _moc;
    SwimmerPickerController *_swimmerPicker;
    UIPopoverController *_swimmerPickerPopover;
}
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel* labelTitle;
@property (retain, nonatomic) IBOutlet UILabel* labelCuts;

@property (nonatomic, retain) SwimmerPickerController *swimmerPicker;
@property (nonatomic, retain) UIPopoverController *swimmerPickerPopover;

- (IBAction) refreshPressed:(id)sender;
- (IBAction) pickerPressed:(id)sender;

- (id)initWithAthlete:(AthleteCD*)athlete andContext:(NSManagedObjectContext*)moc;

@end
