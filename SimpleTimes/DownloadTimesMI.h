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
    AthleteCD* _theAthlete;
    id _theListener;
    NSString* _theDB;
}

@property(retain) AthleteCD* theAthlete;
@property(retain) id         theListener;
@property(retain) NSString*  theDB;

- (id)initWithAthlete:(AthleteCD*)athlete andListener:(id)listener andTmDB:(NSString*)db;

@end
