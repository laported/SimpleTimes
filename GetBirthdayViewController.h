//
//  GetBirthdayViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 1/21/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetBirthdayViewController : UIViewController {
    NSDate* _selectedDate;
}

@property (nonatomic, retain) IBOutlet UITextField *textMM;
@property (nonatomic, retain) IBOutlet UITextField *textDD;
@property (nonatomic, retain) IBOutlet UITextField *textYYYY;
@property (nonatomic, retain) IBOutlet UIButton *buttonOK;
@property (nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property (nonatomic, retain) NSDate* selectedDate;

- (IBAction)onOK:(id)sender ;
- (IBAction)onCancel:(id)sender ;

@end
