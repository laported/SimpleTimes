//
//  SwimmerPickerController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/10/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
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
