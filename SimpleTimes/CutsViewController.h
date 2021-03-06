//
//  CutsViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/15/12.
//  Copyright (c) 2012 David LaPorte. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AthleteCD.h"
#import "CutsViewDataItem.h"

@interface CutsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> 
{
    UITableView* myTableView;
    NSMutableArray*  _cutlist;        // array of CutsViewDataItem* objects
    AthleteCD* _athlete;
}

@property (retain) UITableView* myTableView;

- (id) initWithAthlete:(AthleteCD*)athlete standard:(int)standard;

@end
