//
//  RaceResult.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RaceResultMI : NSObject {
    NSString* _time;
    NSString* _stroke;     
    NSString* _course;
    int _age;
    int _powerpoints;
    NSString* _standard;
    
    int _distance;
    BOOL _shortcourse; /* deprecated */
    NSDate* _date;
    NSString* _meet;
    NSArray* _splits;
    int _key;           // this is the key value we use to download the splits data from the MI website
    NSString* _tmDatabase;
}

@property (copy) NSString* meet;
@property (copy) NSDate*   date;
@property (copy) NSString* stroke;
@property        int       key;
@property (copy) NSString* time;
@property        int       distance;
@property        BOOL      shortcourse; /* deprectaed */
@property (copy) NSString* course;
@property        int       age;
@property        int       powerpoints;
@property (copy) NSString* standard;
@property (nonatomic, retain) NSArray* splits;
@property (copy) NSString* tmDatabase;

- (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSString*)stroke distance:(int)distance shortcourse:(BOOL)shortcourse course:(NSString*)course age:(int)age powerpoints:(int)powerpoints standard:(NSString*)standard splits:(NSArray*)splits db:(NSString*)db;

- (void) setSplitsKey:(int)key;
- (BOOL)hasSplits;

@end
