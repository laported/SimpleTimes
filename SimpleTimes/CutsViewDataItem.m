//
//  CutsViewDataItem.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/16/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "CutsViewDataItem.h"

@implementation CutsViewDataItem

@synthesize standard;
@synthesize cuts = _cuts;

-(id) initWithStandard:(NSString*)std
{
    self = [super init];
    if (self) {
        self.standard = std;
        _cuts = [NSMutableArray array];
        [_cuts retain];
    }
    return self;
}

-(void) dealloc
{
    standard = nil;
    [_cuts release];
    _cuts = nil;
}

-(void) addCut:(NSString*)cut 
{
    [_cuts addObject:cut];
}

@end
