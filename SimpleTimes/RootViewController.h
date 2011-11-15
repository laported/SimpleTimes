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
    NSDictionary *_athletes;
    int selectedAthlete;
}

@property (retain) NSMutableArray *allTimes;
@property (retain) NSOperationQueue *queue;
@property (retain) NSDictionary *athletes;

@end
