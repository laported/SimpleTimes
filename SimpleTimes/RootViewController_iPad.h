//
//  RootViewController_iPad.h
//  SimpleTimes
//
//  Created by David LaPorte on 1/30/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailSwimmerViewController.h"
#import "Swimmers.h"
#import "AddSwimmerViewController.h"
#import "GetBirthdayViewController.h"

@interface RootViewController_iPad : UITableViewController {
    int _viewstate;
    AthleteCD* _addedAthleteCD;
}

@property (nonatomic, retain) IBOutlet DetailSwimmerViewController *detailSwimmerViewController;
@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain) Swimmers* theSwimmers;
@property (retain, nonatomic) AddSwimmerViewController* asViewController; 
@property (retain, nonatomic) GetBirthdayViewController* getbdayController;
@property (retain, nonatomic) NSOperationQueue* queue;
@property int selectedRow;

@end
