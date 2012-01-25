//
//  DownloadTimesMI.m
//  SimpleTimes
//
//  Created by David LaPorte on 1/22/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "DownloadTimesMI.h"
#import "MISwimDBProxy.h"

@implementation DownloadTimesMI

@synthesize theAthlete;
@synthesize listener;

- (id)initWithAthlete:(AthleteCD*)athlete:(id)AndListener 
{
    if (![super init]) return nil;
    NSLog(@"MI Id: %d",[[athlete miswimid] intValue]);
    [self setTheAthlete:athlete];
    [self setListener:AndListener];
    return self;
}

- (void)dealloc {
    [theAthlete release];
    theAthlete = nil;
    [listener release];
    listener = nil;
    [super dealloc];
}

- (void)main 
{
    MISwimDBProxy* proxy = [[[MISwimDBProxy alloc] init] autorelease];

    NSLog(@"+DownloadTimesMI: id=%d",[[theAthlete miswimid] intValue]);
    NSArray* times = [proxy getAllTimesForAthlete:[[theAthlete miswimid] intValue]];
    NSLog(@"-DownloadTimesMI: id=%d",[[theAthlete miswimid] intValue]);

    [self.listener performSelectorOnMainThread:@selector(timesDownloaded:)
                                                      withObject:times
                                                   waitUntilDone:YES];
}

@end
