//
//  SwimmerPickerController.h
//  SimpleTimes
//
//  This class provides functionality that lets the
//  user choose from a list of swimmers (presented as a
//  popover view)
//
//  Created by David LaPorte on 2/10/12.
//  Copyright (c) 2012 David LaPorte. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AthleteCD.h"

@protocol SwimmerPickerDelegate
- (void)swimmerSelected:(AthleteCD *)swimmer;
@end

@interface SwimmerPickerController : UITableViewController {
    id<SwimmerPickerDelegate> _delegate;
    NSManagedObjectContext* _moc;
    NSMutableArray* _swimmer_list;
}

// Designated initializer
- (id)initWithNSManagedObjectContext:(NSManagedObjectContext*)moc;

@property (nonatomic, assign) id<SwimmerPickerDelegate> delegate;

@end
