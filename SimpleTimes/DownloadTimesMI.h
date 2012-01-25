//
//  DownloadTimesMI.h
//  SimpleTimes
//
//  Created by David LaPorte on 1/22/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AthleteCD.h"

@interface DownloadTimesMI : NSOperation {
    AthleteCD* theAthlete;
    id listener;
}

@property(retain) AthleteCD* theAthlete;
@property(retain) id         listener;

- (id)initWithAthlete:(AthleteCD*)athlete:(id)AndListener;

@end
