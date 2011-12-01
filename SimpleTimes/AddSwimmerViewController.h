//
//  AddSwimmerViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface AddSwimmerViewController : UIViewController {

    IBOutlet UITextField* firstname;
    IBOutlet UITextField* lastname;
    IBOutlet UIButton* addbutton;
    NSString* selectedLastName;
    UITableViewController* rvController;
}

@property (nonatomic, retain) UITextField* firstname;
@property (nonatomic, retain) UITextField* lastname;
@property (nonatomic, retain) UIButton* addbutton;
@property (nonatomic, retain) NSString* selectedLastName;
@end
