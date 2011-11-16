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
    NSOperationQueue *_queue;
    NSMutableArray *_athletes;
    NSMutableArray *_strokes;
    NSMutableArray *_distances;
    int _selectedAthlete;
    int _selectedStroke;
    int _selectedDistance;
    NSString *_currentTitle;
}

@property (retain) NSMutableArray *allTimes;
@property (retain) NSOperationQueue *queue;
@property (retain) NSMutableArray *athletes;
@property (retain) NSMutableArray *strokes;
@property (retain) NSMutableArray *distances;
@property int selectedAthlete;
@property int selectedStroke;
@property int selectedDistance;
@property (retain) NSString *CurrentTitle;

@end
