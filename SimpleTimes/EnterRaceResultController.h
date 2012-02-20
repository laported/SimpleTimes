//
//  EnterRaceResultController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/1/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Swimming.h"
#import "AthleteCD.h"

@interface EnterRaceResultController : UIViewController <UITextFieldDelegate> {
    Swimming* _swimming;
    AthleteCD* _athlete;
    NSManagedObjectContext* _moc;
    int _distance_index;
    int _distance;
    float _cumulative;
    int _stroke_index;
}

@property (nonatomic, retain) IBOutlet UIPickerView* distancePicker;
@property (nonatomic, retain) IBOutlet UIPickerView* strokePicker;
@property (nonatomic, retain) IBOutlet UIDatePicker* datePicker;
@property (nonatomic, retain) IBOutlet UITextField* meet;
@property (nonatomic, retain) IBOutlet UILabel* projectedFinish;
@property (nonatomic, retain) IBOutlet UILabel* joCutTime;

- (id)initWithAthlete:(AthleteCD*)athlete andContext:(NSManagedObjectContext*)moc;

- (IBAction)savePressed:(id)sender;
@end
