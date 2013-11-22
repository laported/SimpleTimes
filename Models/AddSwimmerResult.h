//
//  AddSwimmerResult.h
//  SimpleTimes
//
//  Created by David LaPorte on 12/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddSwimmerResult : NSObject {
    NSString* _first;
    NSString* _last;
    NSString* _miId;
    NSString* _clubshort;
    NSString* _clublong;
    NSString* _gender;
    NSString* _birthdate;
}

@property (copy) NSString* first;
@property (copy) NSString* last;
@property (copy) NSString* miId;
@property (copy) NSString* clubshort;
@property (copy) NSString* clublong;
@property (copy) NSString* gender;
@property (copy) NSString* birthdate;

- (id)initWithFirst:(NSString*)first last:(NSString*)last miId:(NSString*)miId  clubshort:(NSString*)clubshort clublong:(NSString*)clublong gender:(NSString*)gender birthdate:(NSString*)birthdate;

@end
