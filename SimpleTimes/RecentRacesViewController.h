//
//  RecentRacesViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/16/12.
//  Copyright (c) 2012 David LaPorte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AthleteCD.h"
#import "RaceResult.h"
#import "AddMeetViewController.h"
#import "EnterRaceResultsiPhoneViewController.h"

@interface RecentRacesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _meets;
    NSMutableArray* _personalbests;
    
    NSString* _addedMeet;
    
    UITableView* myTableView;
    AddMeetViewController* _amvc;
    EnterRaceResultsiPhoneViewController* _errvc;
    NSManagedObjectContext* _context;
    NSString* _course;
    
    NSString* _meetToAddRaceTo;
    NSDate* _dateToAddRaceTo;
    int _state;

}

@property (retain) UITableView* myTableView;
@property (retain) AthleteCD* athlete;
@property (retain) NSArray* results;


- (id) initWithAthlete:(AthleteCD*)athlete andContext:(NSManagedObjectContext*)context course:(NSString*)course;
- (IBAction) EditTable:(id)sender;

@end
