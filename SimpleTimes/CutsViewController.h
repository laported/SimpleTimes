//
//  CutsViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/15/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AthleteCD.h"
#import "CutsViewDataItem.h"

@interface CutsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> 
{
    UITableView* myTableView;
    NSArray*  _cutlist;        // array of CutsViewDataItem* objects
}

@property (retain) UITableView* myTableView;

- (id) initWithAthlete:(AthleteCD*)athlete;
- (NSArray*) allocCutListFor:(AthleteCD*)athlete;

@end
