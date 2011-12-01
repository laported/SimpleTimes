//
//  Athlete.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Athlete : NSObject {
    NSString* _lastname;
    NSString* _firstname;
    NSString* _club;
    int _age;
    NSString* _gender;
    int _key;
}

@property (copy) NSString *lastname;
@property (copy) NSString *firstname;
@property (copy) NSString *club;
@property (copy) NSString *gender;
@property int key;
@property int age;

- (id)initWithLastName:(NSString*)lastName firstName:(NSString*)firstName club:(NSString*)club key:(int)key
;

@end
