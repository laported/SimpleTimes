//
//  RootViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSwimmerViewController.h"
#import "GetBirthdayViewController.h"

#import "Swimmers.h"
#import "AthleteCD.h"

@class AddSwimmerViewController;
@class GetBirthdayViewController;

@interface RootViewController : UITableViewController {
    NSMutableArray *_allTimes; 
    NSMutableArray *_allSplits; 
    NSMutableArray *_allRaceIds;
    NSMutableArray *_allStrokes;
    NSMutableArray *_allDistances;
    NSOperationQueue *_queue;
    Swimmers *_theSwimmers;
    NSMutableArray *_strokes;
    NSMutableArray *_distances;
    int _selectedRace;
    AthleteCD* _selectedAthleteCD;
    AthleteCD* _addedAthleteCD;
    int _selectedStroke;
    int _selectedDistance;
    NSString *_currentTitle;
    NSMutableArray* _IMStrokes;
    int _viewstate;
    int _rows;
    AddSwimmerViewController* _asController;
    GetBirthdayViewController* _getbdayController;
    NSManagedObjectContext* _managedObjectContext;
}

@property (retain) NSMutableArray *allTimes;
@property (retain) NSMutableArray *allSplits;
@property (retain) NSMutableArray *allRaceIds;
@property (retain) NSOperationQueue *queue;
@property (retain) NSMutableArray *strokes;
@property (retain) NSMutableArray *distances;
@property (retain) NSMutableArray *IMStrokes;
@property int selectedRace;
@property (retain) AthleteCD* selectedAthleteCD;
@property (retain) Swimmers* theSwimmers;
@property int selectedStroke;
@property int selectedDistance;
@property (retain) NSString *CurrentTitle;
@property int viewstate;
@property int rows;
@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain) AddSwimmerViewController* asController;
@property (retain) GetBirthdayViewController* getbdayController;

- (IBAction) EditTable:(id)sender;
// onRefresh is invoked when the refresh button is pressed
- (void)onRefresh:(id)sender ;
// refresh is for updating the view
- (void)refresh ;
- (void)refreshSplitTimes ;
- (void)refreshAllBestTimes;

@end
