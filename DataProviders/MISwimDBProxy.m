//
//  MISwimDBProxy.m
//  simpletimes
//
//  Created by David LaPorte on 7/2/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import "MISwimDBProxy.h"
#import "ASIHTTPRequest.h"
#import "ROHTMLTable.h"
#import "AthleteCD.h"
#import "RaceResultMI.h"
#import "Split.h"
#import "AddSwimmerResult.h"

NSString* const findByLastName = @"http://www.sports-tek.com/TMOnline/aATHLETE.asp?aGroup=&SubGroup=&Class=&SEX=M&TEAM=&thePage=1&PageSize=2000&Letter=%C&SEARCH=%@&DB=upload%%5CMichiganSwimmingLSCOfficeCopy.mdb";

NSString* const AthletesQuery = @"http://www.sports-tek.com/TMOnline/aATHLETE.asp?aGroup=&SubGroup=&Class=&SEX=&TEAM=&thePage=1&PageSize=2000&Letter=%C&SEARCH=&DB=upload%%5CMichiganSwimmingLSCOfficeCopy.mdb";

NSString* const AthleteQuery = @"http://www.sports-tek.com/TMOnline/aATHLETE.asp?aGroup=&SubGroup=&Class=&SEX=&TEAM=&thePage=1&PageSize=2000&SEARCH=%@&DB=upload%%5CMichiganSwimmingLSCOfficeCopy.mdb";

NSString* const AllTimesQuery = @"http://www.sports-tek.com/TMOnline/aATHRESULTSWithPSMR.ASP?db=upload%%5CMichiganSwimmingLSCOfficeCopy.mdb&ATH=%d&FASTEST=&PageSize=2000";

NSString* const FastestTimesQuery = @"http://www.sports-tek.com/TMOnline/aATHRESULTSWithPSMR.ASP?db=upload%%5CMichiganSwimmingLSCOfficeCopy.mdb&ATH=%d&FASTEST=1";

NSString* const SplitsQuery = @"http://www.sports-tek.com/TMOnline/aSPLITS.asp?db=upload%%5CMichiganSwimmingLSCOfficeCopy.mdb&RESULT=%d";

NSString* const cachedResultsFileStringFormat        = @"%d.%d.%d.times.table.html";
NSString* const cachedSplitsFileStringFormat         = @"%d.splits.table.html";
NSString* const cachedFastestResultsFileStringFormat = @"%d.fastest.times.table.html";
NSString* const cachedAthleteFileStringFormat        = @"%@.%@.html";

// Query for all times with a given stroke and distance
NSString* const AllTimesQuery2 = @"http://www.sports-tek.com/TMOnline/aATHRESULTSWithPSMR.ASP?db=upload%%5CMichiganSwimmingLSCOfficeCopy.mdb&ATH=%d&Stroke=%d&Distance=%d&Course=Y&Fastest=&MEET=&Sort=intStroke&STD=true";

// http://www.sports-tek.com/TMOnline/aATHRESULTSWithPSMR.ASP?db=upload\MichiganSwimmingLSCOfficeCopy.mdb&ATH=11657&
// Stroke=1&Distance=100&Course=Y&Fastest=&MEET=&Sort=intStroke

//http://www.sports-tek.com/TMOnline/aATHRESULTSWithPSMR.ASP?ATH=11657&Stroke=1&Distance=100&Course=Y&Fastest=&MEET=&STD//=false&DB=upload\MichiganSwimmingLSCOfficeCopy.mdb

/* Splits link
 http://www.sports-tek.com/TMOnline/aSPLITS.asp?db=upload/\MichiganSwimmingLSCOfficeCopy.mdb&RESULT=1297319&ATHLETE=Mathew LaPorte&STROKE=Free&DISTANCE=100
 
 <TD align=right  width="31" class="trow" id="noprint"><a href="" onClick="javascript:split_window=window.open('aSPLITS.asp?db=upload/\MichiganSwimmingLSCOfficeCopy.mdb&RESULT=1297319&ATHLETE=Mathew LaPorte&STROKE=Free&DISTANCE=100','SPLIT_WINDOW','scrollbars=yes,width=600,height=150,menu=false,resizable=yes');split_window.focus(); return false">Splits</a></TD>
 */

@implementation MISwimDBProxy

- (int)saveFile:(NSString*)file text:(NSString*)text
{
    NSArray  *myPathList =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath     =  [myPathList  objectAtIndex:0];
    NSError  **err;
    int rc = 0;
    
    myPath = [myPath stringByAppendingPathComponent:file];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath])        
    {
        [[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];        
        [text writeToFile:myPath atomically:NO encoding:NSUTF8StringEncoding error:err];        
    }
    else        
    {
        NSLog(@"Cannot overwrite existing files");     
        rc = -1;
    }
    return rc;
}

- (NSString*)loadFile:(NSString*)filename
{
    NSArray  *myPathList =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath     =  [myPathList  objectAtIndex:0];
    NSError  **err;
    NSString *text = NULL;
    
    myPath = [myPath stringByAppendingPathComponent:filename];
    NSLog(@"%@", myPath);
    if([[NSFileManager defaultManager] fileExistsAtPath:myPath]) {        
        text = [NSString stringWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:err];
    } 
    else {
        NSLog(@"MISwimDBProxy: loadFile(%@) failed.",filename);
    }
    return text;
}

#define ONLINETESTING

- (NSArray*)getAllTimesForAthlete:(int)athleteId {
    return [self getAllTimesForAthlete:athleteId :0 :0];
}

/* Need to pull out the RESULT= value from text like this:
   <a href="" onClick="javascript:split_window=window.open('aSPLITS.asp?db=upload/\MichiganSwimmingLSCOfficeCopy.mdb&RESULT=1127490&ATHLETE=Kelly LaPorte&STROKE=Free&DISTANCE=500','SPLIT_WINDOW','scrollbars=yes,width=600,height=150,menu=false,resizable=yes');split_window.focus(); return false"
*/
- (int) getSplitsKey:(NSString*)splitsLink {
    NSScanner* scanner = [NSScanner scannerWithString:splitsLink];  
    [scanner scanUpToString:@"RESULT=" intoString:nil];
    if (![scanner isAtEnd]) {
        NSString* key;
        [scanner setScanLocation:[scanner scanLocation]+7];
        [scanner scanUpToString:@"&" intoString:&key];
        return [key intValue];
    } else {
        return 0;
    }
}

/* Need to pull out the RESULT= value from text like this:
 <a href="aATHRESULTSWithPSMR.ASP?db=upload\MichiganSwimmingLSCOfficeCopy.mdb&ATH=13356&FASTEST=1">
 */
- (NSString*) getMiId:(NSString*)idLink {
    NSScanner* scanner = [NSScanner scannerWithString:idLink];  
    [scanner scanUpToString:@"ATH=" intoString:nil];
    if (![scanner isAtEnd]) {
        NSString* key;
        [scanner setScanLocation:[scanner scanLocation]+4];
        [scanner scanUpToString:@"&" intoString:&key];
        return key;
    } else {
        return 0;
    }
}

- (NSArray *)getSplitsForRace:(int)raceId {

    NSMutableArray* all_splits = [NSMutableArray array];
    NSArray *sorted_results = nil;
    BOOL requestOK = YES;
    NSString* response = NULL;
    
#if defined (ONLINETESTING)
    NSString *sQueryUrl;
    sQueryUrl = [NSString stringWithFormat:SplitsQuery,raceId];
    NSLog(@"%@", sQueryUrl);
    NSURL *urlQuery = [NSURL URLWithString:sQueryUrl];
    
    // Grab the splits from the website
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlQuery];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        response = [request responseString];
        NSLog(@"%@", response);
    } else {
        // try to load from local cache
        response = [self loadFile:[NSString stringWithFormat:cachedSplitsFileStringFormat,raceId]];
        requestOK = ([response length] > 0);
    }
#else
    response = [self loadFile:[NSString stringWithFormat:cachedSplitsFileStringFormat,raceId]];
#endif
    
    if (requestOK == YES) {    
        // Extract the <TABLE> element containing the times
        NSString *table = [self getSplitsTable:response];
#if defined (ONLINETESTING)
        if ([table length] > 0) {
            // cache the results locally
            [self saveFile:[NSString stringWithFormat:cachedSplitsFileStringFormat,raceId] text:table];
        }
#endif
        
        // Parse the table
        ROHTMLTable* parser = [[ROHTMLTable alloc] init];
        [parser initFromString:table];
        //NSLog(table);
        
        // Row 1 = Headers
        // Row 2 = Cumulative Splits
        // Row 3 = splits - could be 50s or 25s        
        for (int i=0;i<[parser numCols];i++) {
            Split* split = [[[Split alloc] initWithDistance:[parser cell:0 :i]
                                            time_cumulative:[parser cell:1 :i]
                                                 time_split:[parser cell:2 :i]] autorelease];
            [all_splits addObject:split];
            NSLog(@"%@", [parser cell:2 :i]);
        }
    }     
    
    sorted_results = [all_splits sortedArrayUsingSelector:@selector(compareByDistance:)];        

    // RETURN ARRAY OF RaceResult Objects
    return sorted_results;
}

- (NSArray *)getAllTimesForAthlete:(int)athleteId:(int)stroke:(int)distance {

    NSMutableArray* all_times = [NSMutableArray array];
    NSArray*        sorted_results = nil;
    BOOL            requestOK = YES;
    NSString*       response = NULL;
    
#if defined (ONLINETESTING)
    NSString *sQueryUrl;
    if (stroke == 0 && distance == 0)
        sQueryUrl = [NSString stringWithFormat:AllTimesQuery,athleteId];
    else
        sQueryUrl = [NSString stringWithFormat:AllTimesQuery2,athleteId,stroke,distance];
    NSLog(@"%@", sQueryUrl);
    NSURL *urlQuery = [NSURL URLWithString:sQueryUrl];
    
    // Grab the times from the website
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlQuery];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        response = [request responseString];
    } else {
        // try to load from local cache
        response = [self loadFile:[NSString stringWithFormat:cachedResultsFileStringFormat,athleteId,stroke,distance]];
        requestOK = ([response length] > 0);
    }
#else
    response = [self loadFile:[NSString stringWithFormat:cachedResultsFileStringFormat,athleteId,stroke,distance]];
    requestOK = ([response length] > 0);
#endif
    if (requestOK == YES) {    
        // Extract the <TABLE> element containing the times
        //[self saveFile:@"TestTimes.html" text:response];
        NSString *table = [self getTimesTable:response];
        if ((nil != table) && [table length] > 0) {
            // cache the results locally
            [self saveFile:[NSString stringWithFormat:cachedResultsFileStringFormat,athleteId,stroke,distance] text:table ];
        }
        if (table == nil) {
            [self saveFile:@"error.html" text:response];
            return all_times;
        }
        // Parse the table
        ROHTMLTable* parser = [[ROHTMLTable alloc] init];
        [parser initFromString:table];
        //NSLog(table);
        
        // Column defs
        // 0 Link to splits data
        // 1 Distance
        // 2 Stroke
        // 3 P/F ?????
        // 4 Time
        // 5 Place
        // 6 Points
        // 7 Date
        // 8 Meet
        
        ///// temp hack ---------------------------------------------------------
        if (athleteId == 11657) {
            // add matthew's HS times
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd/yyyy"];
            NSDate *myDate = [df dateFromString:@"01/26/2012"];
            
            RaceResultMI* r = [[[RaceResultMI alloc] initWithTime:@"5:12.75"
                                                             meet:@"SHS @ Novi HS" 
                                                             date:myDate
                                                           stroke:@"Free"
                                                         distance:500
                                                      shortcourse:YES    // todo
                                                           course:@"SCY"
                                                              age:14     // todo
                                                      powerpoints:0
                                                         standard:@"Q1"
                                                              key:0
                                ] autorelease];
            [all_times addObject:r];
            RaceResultMI* r2 = [[[RaceResultMI alloc] initWithTime:@"2:00.95"
                                                              meet:@"SHS @ Novi HS" 
                                                              date:myDate
                                                            stroke:@"Free"
                                                          distance:200
                                                       shortcourse:YES    // todo
                                                            course:@"SCY"
                                                               age:14     // todo
                                                       powerpoints:0
                                                          standard:@"Q2"
                                                               key:0
                                 ] autorelease];
            [all_times addObject:r2];
            NSDate *myDate2 = [df dateFromString:@"01/24/2012"];
            RaceResultMI* r3 = [[[RaceResultMI alloc] initWithTime:@"57.22"
                                                              meet:@"SHS v Churchill HS" 
                                                              date:myDate2
                                                            stroke:@"Free"
                                                          distance:100
                                                       shortcourse:YES    // todo
                                                            course:@"SCY"
                                                               age:14     // todo
                                                       powerpoints:0
                                                          standard:@"Q2"
                                                               key:0
                                 ] autorelease];
            [all_times addObject:r3];
        }
        ///// temp hack ---------------------------------------------------------
        
        for (int i=0;i<[parser numRows];i++) {
            //NSLog(@"Meet: %@ / %@\n",[parser cell:i :7],[parser cell:i :8]);
            //NSLog(@"   %@ %@ %@\n\n",[parser cell:i :1],[parser cell:i :2],[parser cell:i :4]);
            //NSLog(@"Splits: %@",[parser rowLink:i]);
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd/yyyy"];
            NSDate *myDate = [df dateFromString:[parser cell:i :7]];
            
            if (myDate != nil) {
               int dist = [[parser cell:i :1] intValue];
               RaceResultMI* race = [[[RaceResultMI alloc] initWithTime:[parser cell:i :4]
                                                               meet:[parser cell:i :8] 
                                                               date:myDate
                                                             stroke:[parser cell:i :2]
                                                           distance:dist
                                                        shortcourse:YES    // todo
                                                             course:@"SCY"
                                                                age:10     // todo
                                                            powerpoints:[[parser cell:i :6] intValue]
                                                           standard:@"??"
                                                                key:((dist > 50) ? [self getSplitsKey:[parser rowLink:i]] : 0)
                                    ] autorelease];
            
               [all_times addObject:race];
            }
        
        }
        // new and shiny sorted array
        sorted_results = [all_times sortedArrayUsingSelector:@selector(compareByTime:)];        
    }     
   
    // RETURN ARRAY OF RaceResult Objects sorted by time
    
    return sorted_results;
}

/* TODO: Need to refactor this code and eliminate duplicate code with this func
   and previous func
 */
- (NSArray *)getFastestTimesForAthlete:(int)athleteId {
    
    NSMutableArray* all_times = [NSMutableArray array];
    NSArray*        sorted_results = nil;
    BOOL            requestOK = YES;
    NSString*       response = NULL;
    
#if defined (ONLINETESTING)
    NSString *sQueryUrl = [NSString stringWithFormat:FastestTimesQuery,athleteId];
    NSLog(@"%@", sQueryUrl);
    NSURL *urlQuery = [NSURL URLWithString:sQueryUrl];
    
    // Grab the times from the website
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlQuery];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        response = [request responseString];
    } else // try to load from local cache
#else
    response = [self loadFile:[NSString stringWithFormat:cachedFastestResultsFileStringFormat,athleteId]];
#endif    
    requestOK = ([response length] > 0);
    if (requestOK == YES) {    
        // Extract the <TABLE> element containing the times
        //[self saveFile:@"TestTimes.html" text:response];
        NSString *table = [self getTimesTable:response];
        if ([table length] > 0) {
            // cache the results locally
            [self saveFile:[NSString stringWithFormat:cachedFastestResultsFileStringFormat,athleteId] text:table ];
        }
        
        // Parse the table
        ROHTMLTable* parser = [[ROHTMLTable alloc] init];
        [parser initFromString:table];
        //NSLog(@"%@", table);
        
        // Column defs
        // 0 Link to splits data
        // 1 Distance
        // 2 Stroke
        // 3 P/F ?????
        // 4 Time
        // 5 Place
        // 6 Points
        // 7 Date
        // 8 Meet
        for (int i=0;i<[parser numRows];i++) {
            //NSLog(@"Meet: %@ / %@\n",[parser cell:i :7],[parser cell:i :8]);
            //NSLog(@"   %@ %@ %@\n\n",[parser cell:i :1],[parser cell:i :2],[parser cell:i :4]);
            //NSLog(@"Splits: %@",[parser rowLink:i]);
                  
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd/yyyy"];
            NSDate *myDate = [df dateFromString:[parser cell:i :7]];
            
            if (myDate != nil) {
                int dist = [[parser cell:i :1] intValue];
                RaceResultMI* race = [[[RaceResultMI alloc] 
                    initWithTime:[parser cell:i :4]
                            meet:[parser cell:i :8] 
                            date:myDate
                          stroke:[parser cell:i :2]
                        distance:dist
                     shortcourse:YES
                          course:@"SCY"
                             age:10
                     powerpoints:0
                        standard:@"??"
                             key:((dist > 50) ? [self getSplitsKey:[parser rowLink:i]] : 0)
                    ] autorelease];
                
                [all_times addObject:race];
            }
            
        }
        // new and shiny sorted array
        sorted_results = [all_times sortedArrayUsingSelector:@selector(compareByDistance:)];        
    }     
    
    // RETURN ARRAY OF RaceResultMI Objects sorted by time
    return sorted_results;
}

- (NSArray *)findAthlete:(NSString*)lastname {
    return [self findAthlete:lastname:@""];
}

- (NSArray *)findAthlete:(NSString*)lastname:(NSString*)firstname {
    
    NSMutableArray* all_athletes = [NSMutableArray array];
    NSMutableArray* all_unmatched_athletes = [NSMutableArray array];
    /* MI website removes single-quotes in names. E.g. O'Dowd becomes ODowd */ 
    NSString* first_sanitized = [firstname stringByReplacingOccurrencesOfString:@"'"withString:@""];
    NSString* last_sanitized = [lastname stringByReplacingOccurrencesOfString:@"'"withString:@""];
    NSString *sQuery = [NSString stringWithFormat:AthleteQuery,last_sanitized];
    NSString *sQueryUrl = sQuery; 
    NSLog(@"%@", sQueryUrl);
    NSURL *urlQuery = [NSURL URLWithString:sQueryUrl];
    
    NSLog(@"%@", [urlQuery query]);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlQuery];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSString *table = [self getAthleteTable:response];
        //NSLog(@"%@", table);
        
        // Parse the table
        ROHTMLTable* parser = [[ROHTMLTable alloc] init];
        [parser initFromString:table];
        
        // Search results are last-name only, so we need to parse the results
        // and match the first name
        for (int i=0;i<[parser numRows];i++) {
            NSString* first = [parser cell:i :2];
            NSString* last = [parser cell:i :1];
            NSString* clubshort = [parser cell:i :8];
            NSString* clublong = [parser cell:i :9];
            NSString* gender = [[parser cell:i :4] lowercaseString];
            NSString* dob = @""; // Get DOB from user later - it's not exposed by the MI Swim website
            NSString* miId = @"";
            if (i > 0) {
                miId = [self getMiId:[parser rowLink:i-1]]; // -1 beacuse header row does not have a link assoc w/it
            }
            if( ([firstname length] == 0) || [first_sanitized caseInsensitiveCompare:first] == NSOrderedSame ) {
                if (([first caseInsensitiveCompare:@"first"] == NSOrderedSame) &&
                    ([last caseInsensitiveCompare:@"last"] == NSOrderedSame))
                    continue; // skip header row if exists
                
                NSLog(@"match row %d first %@ last %@ Club %@ %@ link %@",i,first,last,clubshort,clublong,[parser rowLink:i-1]);
                if ([miId length] < 2) {
                    for (int jj=0;jj<[parser numRows];jj++) {
                        NSLog(@"link %d %@",jj,[parser rowLink:jj]);
                    }
                }
                AddSwimmerResult* asr = [[AddSwimmerResult alloc] initWithFirst:first last:lastname miId:miId  clubshort:clubshort clublong:clublong gender:gender birthdate:dob];
                NSLog(@"first: %@",asr.first);
                [all_athletes addObject:asr];
            } else {
                NSLog(@"NO MATCH: %@",first);
                AddSwimmerResult* asru = [[AddSwimmerResult alloc] initWithFirst:first last:lastname miId:miId  clubshort:clubshort clublong:clublong gender:gender birthdate:dob];
                NSLog(@"first: %@",asru.first);
                [all_unmatched_athletes addObject:asru];
            }
        }
    } else {
        // Log error;
    }
    return [all_athletes count] > 0 ? all_athletes : all_unmatched_athletes;
}

/*
 * This code grabs the table showing athlete info. The table looks something like:
 
 <TABLE summary="Athletes" border="0" cellspacing="1" cellpadding="2" bgcolor="#000000" id=FieldTable width="740">
 <TR bgcolor="#6699CC" color="#FFFFFF"> 
 <TH scope="col" width="40" align=center class="TopRow">&nbsp;</Th>
 <TH scope="col" width="100" align=center class="TopRow">Last</Th>
 <TH scope="col" width ="100" align=center class="TopRow">First</TH>
 <TH scope="col" width="27" align=center class="TopRow">Age</TH>
 <TH scope="col" width="27" align=center class="TopRow">Gen</TH>
 <TH scope="col" width="30" align=center class="TopRow">Gr</TH>
 <TH scope="col" width="30" align=center class="TopRow">Sub</TH>
 <TH scope="col" width="30" align=center class="TopRow">YR</TH>
 <th scope="col" width="61" align=center class="TopRow"> &nbsp;&nbsp;Team</th>
 <TH scope="col" width="220" align=center class="TopRow">&nbsp;&nbsp;Full Team Name</TH>
 </TR>
 <!-- Display the data rows. -->
 
 
 
 <TR> 
 <TD align=right bgcolor="#FFFFFF" class="trow" width="40"><a href="aATHRESULTSWithPSMR.ASP?db=upload\MichiganSwimmingLSCOfficeCopy.mdb&ATH=12594&FASTEST=1">Times</a></TD>
 <TD bgcolor="#FFFFFF"  align=left class="trow" width="100">LaPorte</TD>
 <TD   bgcolor="#FFFFFF"  align=left class="trow" width="100">
 Adam</TD>
 <TD  bgcolor="#FFFFFF"  align=RIGHT class="trow" width="27">
 19&nbsp;</TD>
 <TD bgcolor="#FFFFFF"  align=center class="trow" width="27">
 M</TD>
 <TD  bgcolor="#FFFFFF"  align=left class="trow" width="30">
 &nbsp;</TD>
 <TD  bgcolor="#FFFFFF"  align=left class="trow" width="30">
 &nbsp;</TD>
 <TD  bgcolor="#FFFFFF"  align=center class="trow" width="30">
 &nbsp;</TD>
 <TD  bgcolor="#FFFFFF" align=right class="trow" width="61">
 LCSC</TD>
 <TD  bgcolor="#FFFFFF" align=left class="trow" width="220">
 Livonia Community Swim Club</TD>
 </TR>
 ...
 possibly more athlete rows
 */
- (NSString *) getAthleteTable:(NSString *)srcString {
    NSString* prefix = @"<TABLE summary=\"Athletes\"";
    NSString* postfix =  @"</TABLE>";
    NSString* table = [self extractElementFromString:srcString:prefix:postfix];
	return table;
}

- (NSString *) getSplitsTable:(NSString *)srcString {
    NSString* prefix = @"<TABLE summary=\"Splits\"";
    NSString* postfix =  @"</table>";
    NSString* table = [self extractElementFromString:srcString:prefix:postfix];
	return table;
}

- (NSString *)extractElementFromString:(NSString*)source:(NSString*)prefix:(NSString*)postfix {
    NSRange start = [source rangeOfString:prefix options:(NSCaseInsensitiveSearch)];
    NSRange end;
    if (start.location != NSNotFound) {
        // chop off the source string before the match
        start.length = [source length] - start.location;
        NSString* s1 = [source substringWithRange:start]; 
        // search for postfix
        end = [s1 rangeOfString:postfix options:(NSCaseInsensitiveSearch)];
        if (end.location != NSNotFound) {
            // Chop off characters after the postfix
            end.length = end.location + [postfix length];
            end.location = 0;
            NSString* s2 = [s1 substringWithRange:end];
            return s2;
        } else {
            NSLog(@"!!extractElementFromString postfix:'%@' NOT FOUND!!",postfix);
        }
    } else {
        NSLog(@"!!extractElementFromString prefix:'%@' NOT FOUND!!",prefix);
    }
    return NULL;
}
        
// ------------------------------------------------------------------------
// Columns:
// 0 Link to splits data
// 1 Distance
// 2 Stroke
// 3 P/F ?????
// 4 Time
// 5 Place
// 6 Points
// 7 Date
// 8 Meet
//
-(NSString*)getTimesTable:(NSString*)srcString {
    NSString* prefix = @"<TABLE summary=\"Results\" border=\"0\" cellspacing=\"1\"";
    NSString* postfix =  @"</TABLE>";
    NSString* table = [self extractElementFromString:srcString:prefix:postfix];
	return table;
}

@end
