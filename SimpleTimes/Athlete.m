//
//  Athlete.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Athlete.h"


@implementation Athlete

@synthesize lastname=_lastname;
@synthesize firstname=_firstname;
@synthesize club=_club;
@synthesize key=_key;
@synthesize age=_age;
@synthesize gender=_gender;

- (id)initWithLastName:(NSString*)lastName firstName:(NSString*)firstName club:(NSString*)club key:(int)key {
    if ((self = [super init])) {
        _firstname = [firstName copy];
        _lastname = [lastName copy];
        _club = [club copy];
        _key = key;
    }
    return self;
}

- (void)dealloc {
    [_firstname release];
    _firstname = nil;
    [_lastname release];
    _lastname = nil;
    [_club release];
    _club = nil;
    [_gender release];
    _gender = nil;
    _key = 0;
    _age = 0;
    [super dealloc];
}

@end
