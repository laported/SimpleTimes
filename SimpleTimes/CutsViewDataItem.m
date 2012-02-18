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
@synthesize cuts;

-(id) initWithStandard:(NSString*)std
{
    self = [super init];
    if (self) {
        self.standard = std;
    }
    return self;
}

-(void) dealloc
{
    standard = nil;
    cuts = nil;
}

@end
