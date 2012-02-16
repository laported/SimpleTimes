//
//  DownloadTimesMI.m
//  SimpleTimes
//
//  Created by David LaPorte on 1/22/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "DownloadTimesMI.h"
#import "../DataProviders/TeamManagerDBProxy.h"

@implementation DownloadTimesMI

@synthesize theAthlete;
@synthesize theListener;
@synthesize theDB;

- (id)initWithAthlete:(AthleteCD*)athlete andListener:(id)listener andTmDB:(NSString*)db
{
    if (![super init]) return nil;
    NSLog(@"MI Id: %d",[[athlete miswimid] intValue]);
    [self setTheAthlete:athlete];
    [self setTheListener:listener];
    [self setTheDB:db];
    return self;
}

- (void)dealloc {
    [_theAthlete release];
    _theAthlete = nil;
    [_theListener release];
    _theListener = nil;
    [_theDB release];
    _theDB = nil;
    [super dealloc];
}

- (void)main 
{
    TeamManagerDBProxy* proxy = [[[TeamManagerDBProxy alloc] initWithDBName:theDB] autorelease];

    NSLog(@"+DownloadTimesMI: id=%d",[[theAthlete miswimid] intValue]);
    NSArray* times = [proxy getAllTimesForAthlete:[[theAthlete miswimid] intValue]];
    NSLog(@"-DownloadTimesMI: id=%d",[[theAthlete miswimid] intValue]);

    [self.theListener performSelectorOnMainThread:@selector(timesDownloaded:)
                                                      withObject:times
                                                   waitUntilDone:YES];
}

@end
