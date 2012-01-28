//
//  AddSwimmerViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/25/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "AddSwimmerResult.h"

@interface AddSwimmerViewController : UIViewController {

    IBOutlet UITextField* firstname;
    IBOutlet UITextField* lastname;
    IBOutlet UIButton* addbutton;
    IBOutlet UILabel *status;
    IBOutlet UIActivityIndicatorView *progressIndicator;
    IBOutlet UITableView *athletes;
    NSString* selectedLastName;
    NSMutableArray *_multipleResults; // array of AddSwimmeResult
    UITableViewController* rvController;
    int _miSwimId;
    NSString* _gender;
    NSString* _club;
    NSDate* _birthdate;
    bool _madeSelection;
    
}

- (IBAction)addButtonSelected:(id)sender;
- (void)    setPropertiesFromSwimmer:(AddSwimmerResult*)swimmer;

@property (nonatomic) int                  miSwimId;
@property (nonatomic, retain) NSString*    gender;
@property (nonatomic, retain) NSString*    club;
@property (nonatomic, retain) UITextField* firstname;
@property (nonatomic, retain) UITextField* lastname;
@property (nonatomic, retain) UIButton*    addbutton;
@property (nonatomic, retain) NSString*    selectedLastName;
@property (nonatomic, retain) UILabel*     status;
@property (nonatomic, retain) UITableView* athletes;
@property (nonatomic, retain) UIActivityIndicatorView* progressIndicator;
@property (nonatomic, retain) NSDate*      birthdate;
@property (nonatomic) bool                 madeSelection;
@end
