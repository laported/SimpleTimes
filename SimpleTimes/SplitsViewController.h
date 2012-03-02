//
//  SplitsViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/24/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaceResult.h"

@interface SplitsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _splits;
    UITableView* myTableView;
    NSManagedObjectContext* _context;
    NSString* _addedSplit;
}

@property (retain) UITableView* myTableView;
@property (retain) RaceResult* race;

- (void) initializeData;
- (id) initWithRace:(RaceResult*)race andContext:(NSManagedObjectContext*)context ;
- (IBAction) EditTable:(id)sender;

@end
