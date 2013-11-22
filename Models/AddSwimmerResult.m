//
//  AddSwimmerResult.m
//  SimpleTimes
//
//  Created by David LaPorte on 12/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddSwimmerResult.h"

@implementation AddSwimmerResult

@synthesize first=_first;
@synthesize last=_last;
@synthesize miId=_miId;
@synthesize clubshort=_clubshort;
@synthesize clublong=_clublong;
@synthesize gender=_gender;
@synthesize birthdate=_birthdate;

- (id)initWithFirst:(NSString*)thefirst last:(NSString*)thelast miId:(NSString*)themiId  clubshort:(NSString*)theclubshort clublong:(NSString*)theclublong  gender:(NSString*)gender birthdate:(NSString*)birthdate {
    if ((self = [super init])) {
        _first = [thefirst copy];
        _last = [thelast copy];
        _miId = [themiId copy];
        _clubshort = [theclubshort copy];
        _clublong = [theclublong copy];
        _gender = [gender copy];
        _birthdate = [birthdate copy];
    }
    return self;    
}

- (void)dealloc {
    [_first release];
    _first = nil;
    [_last release];
    _last = nil;
    [_miId release];
    _miId = nil;
    [_clubshort release];
    _clubshort = nil;
    [_clublong release];
    _clublong = nil;
    [_gender release];
    _gender = nil;
    [_birthdate release];
    _birthdate = nil;
    [super dealloc];
}

@end
