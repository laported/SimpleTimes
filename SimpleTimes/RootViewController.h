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
#import "RaceResult.h"
#import "AthleteCD.h"

@class AddSwimmerViewController;
@class GetBirthdayViewController;

@interface RootViewController : UITableViewController {
    NSMutableArray *_allTimes; 
    NSMutableArray *_allRaceIds;
    NSMutableArray *_allStrokes;
    NSMutableArray *_allDistances;
    NSOperationQueue *_queue;
    Swimmers *_theSwimmers;
    Swimmers *_theMHSAASwimmers;
    NSMutableArray *_strokes;
    NSMutableArray *_distances;
    RaceResult* _selectedRace;
    NSString* _tmDatabaseSelected;
    AthleteCD* _selectedAthleteCD;
    AthleteCD* _addedAthleteCD;
    int _selectedSection;
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
@property (retain) NSMutableArray *allRaceIds;
@property (retain) NSOperationQueue *queue;
@property (retain) NSMutableArray *strokes;
@property (retain) NSMutableArray *distances;
@property (retain) NSMutableArray *IMStrokes;
@property (retain) NSString* tmDatabaseSelected;
@property (retain) RaceResult* selectedRace;
@property (retain) AthleteCD* selectedAthleteCD;
@property (retain) Swimmers* theSwimmers;
@property (retain) Swimmers* theMHSAASwimmers;
@property int selectedStroke;
@property int selectedDistance;
@property (retain) NSString *currentTitle;
@property int viewstate;
@property int rows;
@property int selectedSection;
@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain) AddSwimmerViewController* asController;
@property (retain) GetBirthdayViewController* getbdayController;

- (IBAction) EditTable:(id)sender;
// onRefresh is invoked when the refresh button is pressed
- (void) onRefresh:(id)sender ;
// refresh is for updating the view
- (void) refresh ;
- (void) loadSplitTimes ;
- (void) refreshAllBestTimes;
- (void) completeEditing;

@end
