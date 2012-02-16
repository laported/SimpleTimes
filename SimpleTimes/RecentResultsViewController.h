//
//  RecentResultsViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/15/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AthleteCD.h"
#import "RaceResult.h"

@interface RecentResultsViewController : UITableViewController //UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _meets;
    //UITableView* myTableView;
}

//@property (retain) UITableView* myTableView;
@property (retain) AthleteCD* athlete;
@property (retain) NSArray* results;

- (id) initWithAthlete:(AthleteCD*)athlete andContext:(NSManagedObjectContext*)context;

@end
