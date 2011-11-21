//
//  RootViewController.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
    NSMutableArray *_allTimes; 
    NSMutableArray *_allSplits; 
    NSMutableArray *_allRaceIds;
    NSOperationQueue *_queue;
    NSMutableArray *_athletes;
    NSMutableArray *_strokes;
    NSMutableArray *_distances;
    int _selectedRace;
    int _selectedAthlete;
    int _selectedStroke;
    int _selectedDistance;
    NSString *_currentTitle;
    NSMutableArray* _IMStrokes;
    int _viewstate;
    int _rows;
}

@property (retain) NSMutableArray *allTimes;
@property (retain) NSMutableArray *allSplits;
@property (retain) NSMutableArray *allRaceIds;
@property (retain) NSOperationQueue *queue;
@property (retain) NSMutableArray *athletes;
@property (retain) NSMutableArray *strokes;
@property (retain) NSMutableArray *distances;
@property (retain) NSMutableArray *IMStrokes;
@property int selectedRace;
@property int selectedAthlete;
@property int selectedStroke;
@property int selectedDistance;
@property (retain) NSString *CurrentTitle;
@property int viewstate;
@property int rows;

- (IBAction) EditTable:(id)sender;

@end
