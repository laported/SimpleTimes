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
}

@property (retain) NSMutableArray *athletes;

-(void)loadWithContext:(NSManagedObjectContext *)context;
-(void)load;

#ifdef DEBUG
+(void) seedTestDataUsingContext:(NSManagedObjectContext *)context ;
#endif

@end
