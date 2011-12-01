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
    int _key;
    NSString* _course;
    int _age;
    int _powerpoints;
    NSString* _standard;
    
    int _distance;
    BOOL _shortcourse; /* deprecated */
    NSDate* _date;
    NSString* _meet;
}

@property (copy) NSString *meet;
@property (copy) NSDate *date;
@property (copy) NSString *stroke;
@property int key;
@property (copy) NSString *time;
@property  int distance;
@property BOOL shortcourse; /* deprectaed */
@property (copy) NSString* course;
@property int age;
@property int powerpoints;
@property (copy) NSString* standard;

// Int values 1 = Freestyle, 2 = Back, 3 = Breast, 4 = Fly, 5 = IM
- (int)intStrokeValue;

- (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSString*)stroke distance:(int)distance shortcourse:(BOOL)shortcourse age:(int)age powerpoints:(int)powerpoints standard:(NSString*)standard
;

- (BOOL)hasSplits;

@end
