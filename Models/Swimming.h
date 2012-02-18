//
//  Swimming.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/2/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Swimming : NSObject {
    
}

@property (readonly) NSArray* strokes;
@property (readonly) NSArray* distances;

+ (id)sharedInstance;
- (NSArray*) getStrokes;
- (NSArray*) getDistances;

@end