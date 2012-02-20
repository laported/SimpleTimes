//
//  EnterRaceResultsiPhoneViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/19/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterRaceResultsiPhoneViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (retain) IBOutlet UIPickerView* pickerView;
@property (retain) IBOutlet UITextField* time;
@property                   int stroke;
@property                   int distance;

@end
