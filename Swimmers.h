//
//  Swimmers.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Swimmers : NSObject {
    NSMutableArray *_athletes;  
    NSArray *_athletesCD;
    int _count;
}

@property (retain) NSMutableArray *athletes;
@property (retain) NSArray *athletesCD;

-(void)loadWithContext:(NSManagedObjectContext *)context;
-(void)load;
-(int) count;

#ifdef DEBUG
+(void) seedTestDataUsingContext:(NSManagedObjectContext *)context ;
+(void) deleteAllUsingContext:(NSManagedObjectContext *)context;
#endif

@end
