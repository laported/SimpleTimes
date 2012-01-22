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
}

@property(retain) AthleteCD* theAthlete;

- (id)initWithAthlete:(AthleteCD*)athlete;

@end
