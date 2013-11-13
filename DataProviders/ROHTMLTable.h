//
//  ROHTMLTable.h
//
//  Created by David LaPorte on 10/27/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 
 */
@interface ROHTMLTable : NSObject {

    NSScanner* scanner;
    NSMutableArray* rows;  // Each row is an array of columns
    
    NSMutableArray* rowLinks; // This contains specific data to parse the MI Swim RESULTS tables
                              // it contains the innerHTML of the first <td> element in a row
    int nrows;
    int ncols;
}

- (void)      initFromString:(NSString*)table;
- (NSString*) cell:(int)row col:(int)col;
- (NSString*) rowLink:(int)row;
- (int)       numRows;
- (int)       numCols;
- (void)      parseTable;

@end
