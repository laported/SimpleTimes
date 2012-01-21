//
//  Split.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/20/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Split : NSObject {
    NSString* _distance;
    NSString* _time_cumulative;
    NSString* _time_split;
}

@property (copy) NSString* distance;
@property (copy) NSString* time_cumulative;
@property (copy) NSString* time_split;

- (id)initWithDistance:(NSString*)distance time_cumulative:(NSString*)time_cumulative time_split:(NSString*)time_split
;

@end
