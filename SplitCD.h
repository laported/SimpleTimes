//
//  SplitCD.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/10/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RaceResult;

@interface SplitCD : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * cumulative;
@property (nonatomic, retain) RaceResult *race;

@end
