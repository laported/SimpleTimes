//
//  ROHTMLTable.m
//  Read-Only HTML Table
//
//  Created by David LaPorte on 10/27/11.
//  Copyright 2011 David LaPorte. All rights reserved.
//

#import "ROHTMLTable.h"

#define EL_UNKNOWN      0
#define EL_TABLE        1
#define EL_THEAD        2
#define EL_TBODY        3
#define EL_TFOOT        4
#define EL_TR           5
#define EL_TH           6
#define EL_TD           7
#define EL_TABLE_CLOSE  8
#define EL_THEAD_CLOSE  9
#define EL_TBODY_CLOSE  10
#define EL_TFOOT_CLOSE  11
#define EL_TR_CLOSE     12
#define EL_TH_CLOSE     13
#define EL_TD_CLOSE     14
#define EL_A            15
#define EL_A_CLOSE      16
#define EL_FONT         17
#define EL_FONT_CLOSE   18
#define EL_COMMENT      19


@implementation ROHTMLTable

- (void) initFromString:(NSString*)table {

    scanner  = [NSScanner scannerWithString:table];
    rowLinks = [[NSMutableArray alloc] init];

    [scanner setCaseSensitive:NO];
     
    [self parseTable];
}

- (int) numRows {
    return nrows;
}

- (int) numCols {
    return ncols;
}

- (NSString*) rowLink:(int)row {
    int c = [rowLinks count];
    if (row == -1) {
        row = -1;//set breakpoint here
    }
    return (row < c) ? (NSString*)[rowLinks objectAtIndex:row] : @"";
}

- (NSString*) cell:(int)row:(int)col {
    int r = [rows count];
    if (row < r) {
        NSArray* cols = [rows objectAtIndex:row];
        int c = [cols count];
        return (col < c) ? (NSString*)[cols objectAtIndex:col] : @"";
    } else {
        NSLog(@"Row bounds error in ROHTMLTable(%d rows) cell:row:%d:col:%d",r,row,col);
        return @"";
    }
}

- (int) getElement {
    NSString* el;
    [scanner scanUpToString:@"<" intoString:nil];
    [scanner scanUpToString:@">" intoString:&el];
    [scanner scanString:@">" intoString:nil];
    
    if ([el compare:@"<a" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,2)] == NSOrderedSame) {
        [rowLinks addObject:el];  // this is a hack to store the links
        return EL_A;
    }
    if ([el compare:@"</a" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,3)] == NSOrderedSame) {
        return EL_A_CLOSE;
    }
    if ([el compare:@"<font" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,5)] == NSOrderedSame) {
        return EL_FONT;
    }
    if ([el compare:@"</font" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,6)] == NSOrderedSame) {
        return EL_FONT_CLOSE;
    }
    if ([el compare:@"<tr" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,3)] == NSOrderedSame) {
        return EL_TR;
    }
    if ([el compare:@"<th" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,3)] == NSOrderedSame) {
        return EL_TH;
    }
    if ([el compare:@"<td" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,3)] == NSOrderedSame) {
        return EL_TD;
    }
    if ([el compare:@"<!--" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,4)] == NSOrderedSame) {
        return EL_COMMENT;
    }
    if ([el compare:@"</tr" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,4)] == NSOrderedSame) {
        return EL_TR_CLOSE;
    }
    if ([el compare:@"</th" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,4)] == NSOrderedSame) {
        return EL_TH_CLOSE;
    }
    if ([el compare:@"</td" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,4)] == NSOrderedSame) {
        return EL_TD_CLOSE;
    }
    //NSRange r1 = [el rangeOfString:@"<table" options:(NSAnchoredSearch|NSCaseInsensitiveSearch)];
    if ([el compare:@"<table" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,6)] == NSOrderedSame) {
        return EL_TABLE;
    }
    //NSRange r2 = [el rangeOfString:@"</table" options:(NSAnchoredSearch|NSCaseInsensitiveSearch)];
    if ([el compare:@"</table" options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0,7)] == NSOrderedSame) {
        return EL_TABLE_CLOSE;
    }
    
    NSLog(@"Unknown element: %@\n",el);
    return EL_UNKNOWN;
}

- (NSString *) getText {
    if ([[scanner string] characterAtIndex:[scanner scanLocation]] == '<')
        return NULL;
    NSString* text;
    BOOL bscan = [scanner scanUpToString:@"<" intoString:&text];
    if (![scanner isAtEnd])
        [scanner setScanLocation:[scanner scanLocation]-1];
    return (bscan == YES) ? text : @"";
}

- (void)parseTable
{
    int             element;
    NSString*       text;
    Boolean         intable = true;
    Boolean         inTD = false;
    Boolean         gotRowLink = false;
    NSMutableArray* cols;
    
    rows = [[NSMutableArray alloc] init];
    nrows = 0;
    ncols = 0;
    int currcols = 0;
    
    while (intable) {
        element = [self getElement];
        switch (element) {
            case EL_TR:
                currcols = 0;
                cols = [[NSMutableArray alloc] init]; 
                [rows addObject:cols];
                gotRowLink = NO;
                break;
            case EL_TR_CLOSE:
                nrows++;
                break;
            case EL_TD:
            case EL_TH:
                text = [self getText];
                [cols addObject:text==NULL?@"":text];
                inTD = YES;
                //NSLog(@"%d,%d: %@\n",row,col,text);
                break;
            case EL_TD_CLOSE:
            case EL_TH_CLOSE:
                currcols++;
                if (currcols > ncols)
                    ncols = currcols;
                inTD = NO;
                break;
            case EL_TABLE:
            case EL_FONT:
            case EL_FONT_CLOSE:
            case EL_A:
            case EL_A_CLOSE:
            case EL_COMMENT:
                break;
            case EL_TABLE_CLOSE:
                intable = false;
                break;
            case EL_UNKNOWN:
                NSLog(@"PARSE ERROR: Location = %d\n",[scanner scanLocation]);
                break;
        }
    }
    
}

@end


