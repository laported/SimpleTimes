//
//  RaceResult.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 * RaceResultTeamManager
 * ---------------------
 * This model class represents the swim race result data provided by 
 * Hy-Tek's 'Team Stats Online' websites
 *
 * http://www.hy-tekltd.com/swim/tmonline.html
 *
 */
@interface RaceResultTeamManager : NSObject {
    NSString* _time;
    NSString* _stroke;     
    NSString* _course;
    int       _age;
    int       _powerpoints;
    NSString* _standard;    
    int       _distance;
    NSDate*   _date;
    NSString* _meet;
    NSArray*  _splits;
    int       _key;           // this is the key value we use to download the splits data from the MI website
    NSString* _tmDatabase;
}

@property (copy)   NSString* meet;
@property (copy)   NSDate*   date;
@property (copy)   NSString* stroke;
@property (copy)   NSString* time;
@property (copy)   NSString* course;
@property (copy)   NSString* standard;
@property (retain) NSArray* splits;
@property (copy)   NSString* tmDatabase;
@property          int       key;
@property          int       distance;
@property          BOOL      shortcourse; /* deprectaed */
@property          int       age;
@property          int       powerpoints;

- (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSString*)stroke distance:(int)distance course:(NSString*)course age:(int)age powerpoints:(int)powerpoints standard:(NSString*)standard splits:(NSArray*)splits db:(NSString*)db;

- (void) setSplitsKey:(int)key;
- (BOOL)hasSplits;

@end
