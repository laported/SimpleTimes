//
//  RaceResult.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RaceResult : NSObject {
    NSString* _time;
    NSString* _stroke;
    int _distance;
    BOOL _shortcourse;
    NSDate* _date;
    NSString* _meet;
}

@property (copy) NSString *meet;
@property (copy) NSDate *date;
@property (copy) NSString *stroke;
@property (copy) NSString *time;
@property  int distance;
@property BOOL shortcourse;

- (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSString*)stroke distance:(int)distance shortcourse:(BOOL)shortcourse;


@end
