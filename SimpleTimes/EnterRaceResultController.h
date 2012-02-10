//
//  EnterRaceResultController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/1/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Swimming.h"

@interface EnterRaceResultController : UIViewController {
    Swimming* _swimming;
    int _distance_index;
    int _stroke_index;
}

@property (nonatomic, retain) IBOutlet UIPickerView* distancePicker;
@property (nonatomic, retain) IBOutlet UIPickerView* strokePicker;
@property (nonatomic, retain) IBOutlet UIDatePicker* datePicker;
@property (nonatomic, retain) IBOutlet UITextField* meet;
@end
