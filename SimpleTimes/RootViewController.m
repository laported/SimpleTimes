//
//  RootViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "RootViewController.h"
#import "AddSwimmerViewController.h"
#import "RaceResult.h"
#import "Split.h"
#import "../Dataproviders/TeamManagerDBProxy.h"
#import "USASwimmingDBProxy.h"
#import "TimeStandard.h"
#import "DownloadTimesMI.h"
#import "SplitCD.h"
#import "SVProgressHUD.h"
#import "RecentRacesViewController.h"
#import "CutsViewController.h"
#import "TimeStandardUssScy.h"

#define ASYNC_REFRESH

#define SECTION_USS_SCY 0
#define SECTION_MHSAA   1
#define SECTION_USS_LCM 2
#define SECTION_USS_SCM 3

#define STROKE_PERSONAL_BEST 99
#define STROKE_RECENT        98
#define STROKE_CUTS          97
#define STROKE_FIRST_META    STROKE_CUTS

#define TAG_CUTPROGRESS      1234

@implementation RootViewController

@synthesize allTimes = _allTimes;
@synthesize allRaceIds = _allRaceIds;
@synthesize strokes = _strokes;
@synthesize distances = _distances;
@synthesize queue = _queue;
@synthesize selectedAthleteCD = _selectedAthleteCD;
@synthesize theSwimmers = _theSwimmers;
@synthesize theMHSAASwimmers = _theMHSAASwimmers;
@synthesize selectedStroke = _selectedStroke;
@synthesize selectedDistance = _selectedDistance;
@synthesize tmDatabaseSelected = _tmDatabaseSelected;
@synthesize currentTitle = _currentTitle;
@synthesize selectedRace = _selectedRace;
@synthesize selectedSection = _selectedSection;
@synthesize IMStrokes = _IMStrokes;
@synthesize viewstate = _viewstate;
@synthesize rows = _rows;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize asController = _asController;
@synthesize getbdayController = _getbdayController;

// VIEWSTATEs
#define VS_ATHLETES     1
#define VS_STROKES      2
#define VS_DISTANCE     3
#define VS_RESULTS      4
#define VS_SPLITS       5
#define VS_ADDSWIMMER   6
#define VS_GETBIRTHDATE 7

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assert( self.managedObjectContext != nil );
    
    if (nil == self.currentTitle) {
        self.title = @"Swimmers";
        self.viewstate = VS_ATHLETES;
        self.theSwimmers = [[Swimmers alloc] init];
        [self.theSwimmers loadAllWithContext:self.managedObjectContext withResultsHavingCourse:@"SCY"];
        self.theMHSAASwimmers = [[Swimmers alloc] init];
        [self.theMHSAASwimmers loadAllWithContext:self.managedObjectContext withResultsHavingCourse:@"MHSAA"];        
    } else {
        self.title = self.currentTitle;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.alpha = 0.7;
    
    // TODO: This should be a class var not an ivar
    self.IMStrokes = [NSArray arrayWithObjects:@"Fly",@"Back",@"Breast",@"Freestyle", nil];
    
    if (self.viewstate == VS_ATHLETES) {
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];
        [self.navigationItem setLeftBarButtonItem:addButton];
        
        for (int i=0;i<[self.theSwimmers count];i++) {
            int insertIdx = 0; 
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:SECTION_USS_SCY]] withRowAnimation:UITableViewRowAnimationRight];
        }
        for (int i=0;i<[self.theMHSAASwimmers count];i++) {
            int insertIdx = 0; 
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:SECTION_MHSAA]] withRowAnimation:UITableViewRowAnimationRight];
        }
        
    } else if (self.selectedStroke == 0) {
        self.strokes =  [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:@"Personal Best", @"99", nil],
                        [NSArray arrayWithObjects:@"All Times", @"98", nil],
                        [NSArray arrayWithObjects:@"Cut List", @"97", nil],
                        [NSArray arrayWithObjects:@"Freestyle", @"1", nil],
                        [NSArray arrayWithObjects:@"Backstroke", @"2", nil],
                        [NSArray arrayWithObjects:@"Breaststroke", @"3", nil],
                        [NSArray arrayWithObjects:@"Fly", @"4", nil],
                        [NSArray arrayWithObjects:@"IM", @"5", nil],
                        nil];
    } else if ((self.selectedDistance == 0) && (self.selectedStroke < STROKE_FIRST_META)) {
        switch (self.selectedStroke) {
            case 1: // Free
                self.distances = [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:@"25", @"25", nil],
                        [NSArray arrayWithObjects:@"50", @"50", nil],
                        [NSArray arrayWithObjects:@"100", @"100", nil],
                        [NSArray arrayWithObjects:@"200", @"200", nil],
                        [NSArray arrayWithObjects:@"500", @"500", nil],
                        [NSArray arrayWithObjects:@"1000", @"1000", nil],
                        [NSArray arrayWithObjects:@"1650", @"1650", nil],
                        nil];
                break;
            case 5: // IM
                self.distances = [NSArray arrayWithObjects:
                                  [NSArray arrayWithObjects:@"100", @"100", nil],
                                  [NSArray arrayWithObjects:@"200", @"200", nil],
                                  [NSArray arrayWithObjects:@"400", @"400", nil],
                                  nil];
                break;
            default: // Fly, Breast, Back
                self.distances = [NSArray arrayWithObjects:
                                  [NSArray arrayWithObjects:@"25", @"25", nil],
                                  [NSArray arrayWithObjects:@"50", @"50", nil],
                                  [NSArray arrayWithObjects:@"100", @"100", nil],
                                  [NSArray arrayWithObjects:@"200", @"200", nil],
                                  nil];
                break;
        }
   } else {
       if (self.selectedRace != nil) {
           //self.allTimes = [NSMutableArray array];
           self.queue = [[[NSOperationQueue alloc] init] autorelease];
       } else if (self.selectedStroke == STROKE_PERSONAL_BEST) {
           // Get a list of best times for each stroke
           self.allTimes = [NSMutableArray array];
           self.queue = [[[NSOperationQueue alloc] init] autorelease];
           [self refreshAllBestTimes];
       } else {
           // getting data for a particular stroke and distance
           self.allTimes = [NSMutableArray array];
           self.queue = [[[NSOperationQueue alloc] init] autorelease];
           [self refresh];
       }
    }
    
}

/* 
 * timesDownloaded
 *
 * Invoked asynchronously in two situations:
 * 1. When the user adds a new swimmer (self.selectedCD will be nil)
 * 2. When the user selects the 'Refresh' button for a paricular swimmer
 */
- (void)timesDownloaded:(NSArray*)times
{
    int numadded;
    
    if (self.viewstate == VS_ATHLETES) {
        // adding results for new swimmer
        numadded = [Swimmers updateAllRaceResultsForAthlete:_addedAthleteCD withResults:times inContext:self.managedObjectContext];
        
        // reload
        [self.theSwimmers release];
        self.theSwimmers = [[Swimmers alloc] init];        
        [self.theSwimmers loadAllWithContext:self.managedObjectContext withResultsHavingCourse:@"SCY"];
        [self.theMHSAASwimmers release];
        [self.theMHSAASwimmers loadAllWithContext:self.managedObjectContext withResultsHavingCourse:@"MHSAA"];
        
        [self.tableView reloadData];
    } else {
        // Updating results for swimmer
        numadded = [Swimmers updateAllRaceResultsForAthlete:self.selectedAthleteCD withResults:times inContext:self.managedObjectContext];
        [self refresh];
    }
        
    [self.queue release];

    NSTimeInterval nsti = 3.5;
    if (numadded > 0) {
        NSString* msg = [NSString stringWithFormat:@"Added %d new race times",numadded];
        [SVProgressHUD dismissWithSuccess:msg afterDelay:nsti];
    } else {
        [SVProgressHUD dismissWithSuccess:@"No new race times found" afterDelay:nsti];
    }
}

- (void)onRefresh:(id)sender {

#ifdef ASYNC_REFRESH
    self.queue = [[NSOperationQueue alloc] init];
    
    [SVProgressHUD showWithStatus:@"Checking for updated times"];
    
    // download all times and populate the database
    DownloadTimesMI* dtm = [[DownloadTimesMI alloc] initWithAthlete:self.selectedAthleteCD andListener:self andTmDB:self.tmDatabaseSelected];
    [self.queue addOperation:dtm];
    [dtm release];
    
#else
    [self.theSwimmers updateAllRaceResultsForAthlete:self.selectedAthleteCD inContext:self.managedObjectContext];

    // update the display
    //[self refresh];
#endif
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* Are we coming back from the 'Add Swimmer' dialog ? */
    if ((self.viewstate == VS_ADDSWIMMER) && (self.selectedSection != SECTION_MHSAA)) {
        
        // Did the user pick a swimmer??
        if (self.asController.madeSelection) {
            // Do we have a birthdate? (MI Swim provider does not supply it)
            if (self.asController.birthdate == NULL) {
                self.viewstate = VS_GETBIRTHDATE;
                // Do we have a birthdate?
                // Push a new view controller for birthdate selection here
                self.getbdayController = [[GetBirthdayViewController alloc] initWithNibName:@"GetBirthdayViewController" bundle:[NSBundle mainBundle]];
                [self.navigationController pushViewController:self.getbdayController animated:YES];
            } else {
                // MHSAA doesn't need a birthday 
            }
        } else {
            // nothing selected
            self.viewstate = VS_ATHLETES;
        }
        
    } else if ((self.viewstate == VS_GETBIRTHDATE) || ((self.viewstate == VS_ADDSWIMMER) && (self.selectedSection == SECTION_MHSAA))) {
        self.viewstate = VS_ATHLETES;
        NSLog(@"firstname: %@ lastname: %@ miID:%d",self.asController.firstname.text,self.asController.lastname.text,self.asController.miSwimId);
        // 1. Add swimmer name to list of athletes
        // 2. Lookup swimmer online
        // 3. Download times        
        AthleteCD *ath1 = [NSEntityDescription
                           insertNewObjectForEntityForName:@"AthleteCD" 
                           inManagedObjectContext:self.managedObjectContext];
        ath1.firstname = self.asController.firstname.text;
        ath1.lastname = self.asController.lastname.text;
        ath1.club = self.asController.club; 
        ath1.birthdate = self.getbdayController.selectedDate;
        ath1.miswimid = [[NSNumber alloc] initWithInt:self.asController.miSwimId];
        ath1.gender = self.asController.gender;
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [SVProgressHUD showWithStatus:@"Downloading race results..." maskType:SVProgressHUDMaskTypeBlack];        
        
        // save ath record for use in the timesDownloaded callback
        _addedAthleteCD = ath1;
        self.tmDatabaseSelected = self.asController.database;
        
#ifdef ASYNC_REFRESH
        self.queue = [[NSOperationQueue alloc] init];
        
        // download all times into the database for the new swimmer
        DownloadTimesMI* dtm = [[DownloadTimesMI alloc] initWithAthlete:ath1 andListener:self andTmDB:self.tmDatabaseSelected];
        [self.queue addOperation:dtm];
        [dtm release];
        
#else
        // download all times and populate the database
        [self.theSwimmers updateAllRaceResultsForAthlete:ath1 inContext:self.managedObjectContext];
        [self.theSwimmers loadWithContext:self.managedObjectContext]; 
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
#endif
        
    } else if (self.viewstate == VS_STROKES) {
       /* Add a Reload button that will re-download results from the web */
       // Initialize the UIButton
       UIImage *buttonImage = [UIImage imageNamed:@"reload_v2.png"];
       UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
       [aButton setImage:buttonImage forState:UIControlStateNormal];
       aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
       
       // Initialize the UIBarButtonItem
       UIBarButtonItem* aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
       
       // Set the Target and Action for aButton
       [aButton addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventTouchUpInside];

        self.navigationItem.rightBarButtonItem = aBarButtonItem;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait) ||
           (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
           (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.viewstate == VS_ATHLETES) {
        int kSections = 0;
        if ([self.theSwimmers count] > 0) kSections++;
        if ([self.theMHSAASwimmers count] > 0) kSections++;
        if (self.editing) kSections = 4;
        return kSections; // possibly USS SCY, MHSAA, USS LCM, USS SCM
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_USS_SCY) { // SCY
        self.rows = 0;
        switch (self.viewstate) {
            case VS_ATHLETES:
                self.rows = [self.theSwimmers count];
                NSLog(@"numRows: %d",self.rows);
                break;
            case VS_STROKES:
                self.rows = [self.strokes count];
                break;
            case VS_DISTANCE:
                self.rows = [self.distances count];
                break;
            case VS_RESULTS:
                self.rows = [_allTimes count];
                break;
            case VS_SPLITS:
                self.rows = [self.selectedRace.splits count];
                break;
            default:
                NSLog(@"ERROR: numberOfRowsInSection UNKNOWN!!! for viewstate=%d",self.viewstate);
                break;
        }
        if(self.editing) { 
            self.rows++;
            //NSLog(@"Editing=true, numRows: %d",self.rows);
        }
        return self.rows;
    } else if (section == SECTION_USS_LCM) {
        return 0;  // todo
    } else if (section == SECTION_MHSAA) {
        int kRows = [self.theMHSAASwimmers count];
        if (self.editing) {
            kRows++;
        }
        return kRows;
    } else {    // SECTION_USS_SCM
        return 0; // todo
    }
}

- (NSString*) cutsWithStars:(int)numStars andPrefix:(NSString*)prefix
{
    NSString *aStar = @"\u2605";
    NSString *stars = prefix;
    for (int i=0;i<numStars;i++)
    {
        stars = [stars stringByAppendingString:aStar];
    }
    return stars;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    int theSection = self.viewstate == VS_ATHLETES ? section : self.selectedSection; 
    if (self.viewstate == VS_SPLITS) {
        return self.selectedRace.meet;
    } else {
        if(theSection == SECTION_USS_SCY)
            return @"USS Short Course Yards";
        else if (theSection == SECTION_USS_LCM)
            return @"USS Long Course Meters";
        else if (theSection == SECTION_MHSAA)
            return @"Michigan High School";
        else
            return @"USS Short Course Meters";
    }
}

-(void) showCutProgessInCell:(UITableViewCell *)cell forRace:(RaceResult*)race
{
    if (self.selectedSection == SECTION_USS_SCY) {
        int nStroke = [Swimmers intStrokeValue:race.stroke];
        float ftime = [TimeStandard getFloatTimeFromStringTime:race.time];
        float fQ1 = [TimeStandardUssScy q1TimeForEvent:[race.distance intValue] stroke:nStroke gender:self.selectedAthleteCD.gender birthday:self.selectedAthleteCD.birthdate];
        float fQ2 = [TimeStandardUssScy q2TimeForEvent:[race.distance intValue] stroke:nStroke gender:self.selectedAthleteCD.gender birthday:self.selectedAthleteCD.birthdate];
        float fB = [TimeStandardUssScy bTimeForEvent:[race.distance intValue] stroke:nStroke gender:self.selectedAthleteCD.gender birthday:self.selectedAthleteCD.birthdate];
        float fCutProgress = 0.0;
        if ((ftime > fQ2) && (ftime <= fB)) {
            // 0.0====Q1=====Q2===ftime==B=====
            fCutProgress = (fB - ftime) / (fB - fQ2);
        } else if ((ftime > fQ1) && (ftime <= fQ2)) {
            // 0.0====Q1==ftime===Q2=====B=====
            fCutProgress = (fQ2 - ftime) / (fQ2 - fQ1);
        } 
        if (fCutProgress > 0) {
            UIProgressView* cutPV = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            cutPV.frame = CGRectMake(280,10, 125,50);
            cutPV.progress = fCutProgress;
            cutPV.tag = TAG_CUTPROGRESS;
            [cell.contentView addSubview:cutPV];
            [cutPV release];
        }
    } else {
        // TODO
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
        (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) 
    {
        // We are in portrait orientation. Make sure we clear any exiting progress bar in this cell
        UIView* progress = nil;
        while((progress = [self.tableView viewWithTag:TAG_CUTPROGRESS]) != nil) {
            [progress removeFromSuperview];
        }
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RaceResult *race;
    AthleteCD* athlete;
    NSArray* splits;
    SplitCD *split;
    CUTS cuts;
    MHSAACUTS mhsaacuts;
    NSSortDescriptor* sortDescriptor;
    NSArray *sortDescriptors;
    int kMHSAARows = [self.theMHSAASwimmers count];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UITableViewCellStyle style;
        if (self.viewstate == VS_RESULTS) {
            style = UITableViewCellStyleValue2;
        } else if (self.viewstate == VS_SPLITS) {
            style = UITableViewCellStyleValue1;
        } else {
            style = UITableViewCellStyleSubtitle;
        }
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Are we in edit mode????
    //NSLog(@"cellForRowAtIndexPath/self.rows=%d, indexPath=%d",self.rows,indexPath.row);
    if (self.editing && (indexPath.section == SECTION_USS_SCY) && (indexPath.row == (self.rows-1))) {
        NSLog(@"%@",@"cellForRowAtIndexPath/'Add new Swimmer'");
        cell.textLabel.text = @"Add new swimmer";
        cell.detailTextLabel.text = @"";
        return cell;
    } if (self.editing && (indexPath.section == SECTION_MHSAA) && (indexPath.row == kMHSAARows)) {
        cell.textLabel.text = @"Add new swimmer";
        cell.detailTextLabel.text = @"";
        return cell;
    } else {
        switch (self.viewstate) {
            case VS_ADDSWIMMER:
            case VS_ATHLETES:
                // We are displaying the athlete list
                if (indexPath.section == SECTION_USS_SCY) {
                    athlete = [self.theSwimmers.athletesCD objectAtIndex:indexPath.row];
                    [athlete countCuts:&cuts];
                    if (cuts.jos > 0 || cuts.states > 0 || cuts.sectionals > 0 || cuts.nationals > 0) {
                        NSString* jos = cuts.jos > 0 ? [self cutsWithStars:cuts.jos andPrefix:@"JO "] : @"";
                        NSString* states = cuts.states > 0 ? [self cutsWithStars:cuts.states andPrefix:@"ST "] : @"";
                        NSString* sectionals = cuts.sectionals > 0 ? [self cutsWithStars:cuts.sectionals andPrefix:@"SE "] : @"";
                        NSString* nationals = cuts.nationals > 0 ? [self cutsWithStars:cuts.nationals andPrefix:@"NA "] : @"";
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",athlete.firstname, athlete.lastname, athlete.club]; 
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",nationals,sectionals,states,jos];
                        //cell.detailTextLabel.textColor = [UIColor colorWithRed:218.0/255.0 green:165.0/255.0 blue:32.0/255.0 alpha:1.0];
                        cell.detailTextLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:18.0/255.0 alpha:1.0];
                    } else {
                        cell.detailTextLabel.text = athlete.club; 
                    }
               } else if (indexPath.section == SECTION_MHSAA) {
                   athlete = [self.theMHSAASwimmers.athletesCD objectAtIndex:indexPath.row];
                   [athlete countCutsMHSAA:&mhsaacuts];
                   if (mhsaacuts.miscas > 0 || cuts.states > 0) {
                       NSString* miscas = mhsaacuts.miscas > 0 ? [self cutsWithStars:mhsaacuts.miscas andPrefix:@"MISCA "] : @"";
                       NSString* states = mhsaacuts.states > 0 ? [self cutsWithStars:mhsaacuts.states andPrefix:@"STATE "] : @"";
                       cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",athlete.firstname, athlete.lastname, athlete.club]; 
                       cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",states,miscas];
                       cell.detailTextLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:18.0/255.0 alpha:1.0];
                   } else {
                       cell.detailTextLabel.text = athlete.club; 
                   }
                }
                //NSLog(@"cellForRowAtIndexPath/last=%@,first=%@",athlete.lastname,athlete.firstname);
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",athlete.firstname, athlete.lastname];    
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case VS_STROKES:
                // We are displaying the stroke list
                cell.textLabel.text = [[self.strokes objectAtIndex:indexPath.row] objectAtIndex:0];       
                cell.detailTextLabel.text = @""; 
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case VS_DISTANCE:
                // We are displaying the stroke list
                cell.textLabel.text = [[self.distances objectAtIndex:indexPath.row] objectAtIndex:0];       
                cell.detailTextLabel.text = @"Short course yards"; 
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case VS_RESULTS:
                race = [_allTimes objectAtIndex:indexPath.row];
                
                NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                NSString *raceDateString = [dateFormatter stringFromDate:race.date];
                float ftime = [TimeStandard getFloatTimeFromStringTime:race.time];
                int nStroke = [Swimmers intStrokeValue:race.stroke];
                NSString *timestd = self.selectedSection == SECTION_MHSAA ? 
                    [TimeStandard getTimeStandardForMHSAAWithDistance:[race.distance intValue] stroke:nStroke gender:self.selectedAthleteCD.gender time:ftime] 
                    : 
                    [TimeStandard getTimeStandardWithAge:[self.selectedAthleteCD ageAtDate:race.date] distance:[race.distance intValue] stroke:nStroke gender:self.selectedAthleteCD.gender time:ftime];
                cell.detailTextLabel.numberOfLines = 2;
                cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
            
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@\n%@ %@", [race.distance intValue], race.stroke, race.time, timestd]; 
                //NSLog(@"Dist: %@ splitskey:%d splits count:%d",race.distance,[race.splitskey intValue],[race.splits count]);
                NSString* meetShort = [race shortenMeetName];
                cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@", raceDateString, meetShort];
                if (([race.distance intValue]>50) && (([race.splits count] > 0) || ([race.splitskey intValue] > 0))) { 
                   cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone; 
                }
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;//  WordWrap; 
                UIDeviceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
                if (UIDeviceOrientationIsLandscape(o)) {
                    [self showCutProgessInCell:cell forRace:(RaceResult*)race];
                }
                break;
                
            case VS_SPLITS:                
                sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];  
                sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];   
                splits = [self.selectedRace.splits sortedArrayUsingDescriptors:sortDescriptors];
                //splits = [unsortedSplits sortedArrayUsingSelector:@selector(compareByDistance:)];        

                split = [splits objectAtIndex:indexPath.row];
                int splitDistance = (indexPath.row+1)*(self.selectedDistance/[splits count]);
                /* Is this an IM???? */
                if (self.selectedStroke == 5) {
                    // IM: Add the current stroke for this split
                    int stroke_index = (splitDistance-1)/(self.selectedDistance/4);
                    assert( stroke_index < 4 );
                    NSString* stroke = [self.IMStrokes objectAtIndex:stroke_index];
                    //NSLog(@"%d, %d, %@, %@",[splits count],indexPath.row,stroke,split);
                    cell.textLabel.text = [NSString stringWithFormat:@"%d : %@  (%@)", (indexPath.row+1)*(self.selectedDistance/[splits count]), split.cumulative, stroke]; 
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%d : %@", splitDistance, split.cumulative];
                }
                // If these are 25 splits, combine into 50s as well
                if ((self.selectedDistance / 25 == [self.selectedRace.splits count]) && (indexPath.row % 2)) {
                    NSUInteger lastrow = indexPath.row-1;
                    
                    SplitCD* lastSplit = [splits objectAtIndex:lastrow];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%3.2f)", split.time, [split.time floatValue] + [lastSplit.time floatValue]]; 
                } else {
                    cell.detailTextLabel.text = split.time;
                }
                break;
                
            default:
                NSLog(@"ERROR: cellForRowAtIndexPath UNKNOWN!!! for viewstate=%d",self.viewstate);
                cell.textLabel.text = @"Internal Error :(";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Details: cellForRowAtIndexPath/%d",self.viewstate];
                break;
                
        }
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSString*) courseStringFromSection:(int)section
{
    switch (section) {
        case SECTION_MHSAA:
            return @"MHSAA";
        case SECTION_USS_LCM:
            return @"LCM";
        case SECTION_USS_SCM:
            return @"SCM";
        case SECTION_USS_SCY:
            return @"SCY";
        default:
            assert(false);
    }
    return @"SCY";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootViewController *rvController;
    RaceResult* race;
    
    // Alloc the next view controller
    switch (self.viewstate) {
        case VS_ATHLETES:
            // We are on the "List of Athletes" table. 
            // Get ready to display this athlete's times
            rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
            
            //Increment the Current View
            rvController.managedObjectContext = self.managedObjectContext;
            NSLog(@"VS_ATHLETES->VS_STROKES: %@",self.managedObjectContext);
            rvController.viewstate = VS_STROKES;
            rvController.theSwimmers = self.theSwimmers;
            rvController.theMHSAASwimmers = self.theMHSAASwimmers;
            rvController.selectedSection = indexPath.section;
            if (indexPath.section == SECTION_MHSAA) {
                rvController.tmDatabaseSelected = [NSString stringWithCString:MISCA_SWIM_DB encoding:NSUTF8StringEncoding];
                rvController.selectedAthleteCD = [self.theMHSAASwimmers.athletesCD objectAtIndex:indexPath.row];
            } else {
                rvController.tmDatabaseSelected = [NSString stringWithCString:MI_SWIM_DB encoding:NSUTF8StringEncoding];
                rvController.selectedAthleteCD = [self.theSwimmers.athletesCD objectAtIndex:indexPath.row];
            }
            rvController.currentTitle = rvController.selectedAthleteCD.firstname;
            
            //Push the new table view on the stack
            [self.navigationController pushViewController:rvController animated:YES];
            [rvController release];
            break;
            
        case VS_STROKES:
            // We are on the "List of strokes" table.
            // We either want to display a list of distances (If selecting single stroke,
            // or we want to display a list of all best times 
            // Get ready to display this distance
            
            self.selectedStroke = [[[self.strokes objectAtIndex:indexPath.row] objectAtIndex:1] intValue];
            if (self.selectedStroke == STROKE_RECENT) {
                NSString* c = [self courseStringFromSection:indexPath.section];
                RecentRacesViewController* recent = [[RecentRacesViewController alloc] initWithAthlete:self.selectedAthleteCD andContext:self.managedObjectContext course:c];
                [self.navigationController pushViewController:recent animated:YES];
                [recent release];
            } else if (self.selectedStroke == STROKE_CUTS) {
                CutsViewController* cuts = [[CutsViewController alloc] initWithAthlete:self.selectedAthleteCD];
                [self.navigationController pushViewController:cuts animated:YES];
                [cuts release];
            } else {    

                //Prepare to tableview.
                rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
                
                //Increment the Current View
                rvController.selectedStroke = self.selectedStroke;
                rvController.managedObjectContext = self.managedObjectContext;
                rvController.selectedAthleteCD = self.selectedAthleteCD;
                rvController.selectedSection = self.selectedSection;
                rvController.tmDatabaseSelected = self.tmDatabaseSelected;
                if (rvController.selectedStroke < STROKE_FIRST_META) {
                    NSLog(@"VS_STROKES->VS_DISTANCE: %@",self.managedObjectContext);
                    rvController.currentTitle = @"Distance";
                    rvController.viewstate = VS_DISTANCE;
                } else if (rvController.selectedStroke == STROKE_PERSONAL_BEST) {
                    rvController.currentTitle = @"Personal Best";
                    NSLog(@"VS_STROKES->VS_RESULTS: %@",self.managedObjectContext);
                    rvController.viewstate = VS_RESULTS;
                } else {
                    assert( false );
                }
                
                //Push the new table view on the stack
                [self.navigationController pushViewController:rvController animated:YES];            
                [rvController release];
            }
            break;
            
        case VS_DISTANCE:
            // We are on the "List of distances" table.
            // We want to transition next to the results for this stroke and distance
            // Get ready to display this distance
            //Prepare to tableview.
            rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
            
            //Increment the Current View
            rvController.selectedDistance = [[[self.distances objectAtIndex:indexPath.row] objectAtIndex:1] intValue];
            rvController.managedObjectContext = self.managedObjectContext;
            rvController.selectedStroke = self.selectedStroke;
            rvController.selectedAthleteCD = self.selectedAthleteCD;
            rvController.viewstate = VS_RESULTS;
            rvController.selectedSection = self.selectedSection;
            rvController.tmDatabaseSelected = self.tmDatabaseSelected;
            NSLog(@"VS_DISTANCE->VS_RESULTS: %@",self.managedObjectContext);
            
            //Set the title;
            rvController.currentTitle = @"Times";            
            //Push the new table view on the stack
            [self.navigationController pushViewController:rvController animated:YES];
            
            [rvController release];
            break;

        case VS_RESULTS:
            // Split data available for this result??
            
            race = [self.allTimes objectAtIndex:indexPath.row];
            if ([race.distance intValue] > 50) {
                // Get ready to show splits data
                rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
                
                // Increment the Current View
                rvController.selectedDistance = [race.distance intValue];
                rvController.selectedStroke = [Swimmers intStrokeValue:race.stroke];
                rvController.selectedAthleteCD = self.selectedAthleteCD;
                rvController.selectedRace = race; //[race.splitskey intValue];
                rvController.tmDatabaseSelected = self.tmDatabaseSelected;
                self.selectedRace = race;
                rvController.managedObjectContext = self.managedObjectContext;
                rvController.selectedSection = self.selectedSection;
                NSLog(@"VS_RESULTS->VS_SPLITS: %@",self.managedObjectContext);
                //Set the title;
                rvController.currentTitle = @"Split Times";
                rvController.viewstate = VS_SPLITS;
                
                [self loadSplitTimes]; 

                //Push the new table view on the stack
                [self.navigationController pushViewController:rvController animated:YES];            
                [rvController release];
            }
            break;
            
        case VS_SPLITS:
        default:
            // nothing to do here
            break;
    }
}

// ------------------------------------------------------
// refresh
//
// get list of race results from the data store and place into
// the view
//
- (void)refresh {

    NSSet *raceSet = self.selectedAthleteCD.races;
    NSArray *times = [raceSet allObjects];
    NSMutableArray* all_requested_times = [NSMutableArray array];
    NSArray* all_sorted_requested_times = nil;

    NSLog(@"Number of results: %d",[times count]);
    for (int i=0;i<[times count];i++) {

        RaceResult *race = [times objectAtIndex:i];
        if ([race.distance intValue] != self.selectedDistance)
            continue;
        if ([Swimmers intStrokeValue:race.stroke] != self.selectedStroke)
            continue;
        
        [all_requested_times addObject:race];
    }
    
    all_sorted_requested_times = [all_requested_times sortedArrayUsingSelector:@selector(compareByTime:)];        

    for (RaceResult* race in all_sorted_requested_times) {
        int insertIdx = 0;                    
        [_allTimes insertObject:race atIndex:insertIdx];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
    
    //[all_requested_times release];
}

- (void)refreshAllBestTimes {
    NSArray* best_times = [self.selectedAthleteCD personalBests];
    for (int i=[best_times count]-1;i>=0;i--) {
        
        RaceResult *race = [best_times objectAtIndex:i];
        
        int insertIdx = 0;                    
        [_allTimes insertObject:race atIndex:insertIdx];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }

}

- (void)loadSplitTimes {
    
    RaceResult* race = self.selectedRace;
    // Need to download splits??
    //NSLog(@"splits: %@ splitskey: %@",race.splits,race.splitskey);
    if (([race.splits count] == 0) && (race.splitskey > 0)) {
        
        TeamManagerDBProxy* proxy = [[[TeamManagerDBProxy alloc] initWithDBName:self.tmDatabaseSelected] autorelease];
        NSArray* splits = [proxy getSplitsForRace:[race.splitskey intValue]]; 
        if ([splits count] > 0) {
            NSMutableSet* set1 = [[NSMutableSet alloc] initWithCapacity:[splits count]];
            for (Split*sMI in splits) {
                SplitCD* s = (SplitCD*)[NSEntityDescription insertNewObjectForEntityForName:@"SplitCD" inManagedObjectContext:self.managedObjectContext];
                s.distance   = [[NSNumber alloc] initWithInt:[sMI.distance intValue]];
                s.time       = sMI.time_split;
                s.cumulative = sMI.time_cumulative;
                [set1 addObject:s];
            }
            race.splits = set1;
            
            // Store splits in DB
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"Saving changes to splits failed: %@", saveError);
            } 
        }
        
    }
    
}

/* -- ASI Completion delegates
 
 TODO
 
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    RSSEntry *entry = [[[RSSEntry alloc] initWithBlogTitle:request.url.absoluteString
                                              articleTitle:request.url.absoluteString
                                                articleUrl:request.url.absoluteString
                                               articleDate:[NSDate date]] autorelease];    
    int insertIdx = 0;                    
    [_allEntries insertObject:entry atIndex:insertIdx];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]]
                          withRowAnimation:UITableViewRowAnimationRight];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}
 --------------------------------------------------*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableView* tableView = (UITableView*)[self view];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Delete at %d",indexPath.row);
        
        AthleteCD* ath = nil;
        // TODO Add an 'Are you sure?' dialog
        if (indexPath.section == SECTION_MHSAA) {
            ath = [self.theMHSAASwimmers.athletesCD objectAtIndex:indexPath.row]; 
        } else {
            ath = [self.theSwimmers.athletesCD objectAtIndex:indexPath.row];
        }
        [self.managedObjectContext deleteObject:ath];
        NSError *error;         
        if (![self.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error series %@, %@", error, [error userInfo]);
            
        }

        // reload from the data store
        if (indexPath.section == SECTION_MHSAA) {
            [self.theMHSAASwimmers loadAllWithContext:self.managedObjectContext withResultsHavingCourse:@"MHSAA"];
        } else {
            [self.theSwimmers loadAllWithContext:self.managedObjectContext withResultsHavingCourse:@"SCY"];
        }
        
        // remove from the table view
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSString* db;
        if (indexPath.section == SECTION_MHSAA) {
            db = [NSString stringWithCString:MISCA_SWIM_DB encoding:NSUTF8StringEncoding];
        } else {
            db = [NSString stringWithCString:MI_SWIM_DB encoding:NSUTF8StringEncoding];
        }
        self.selectedSection = indexPath.section;
        // exit edit mode
        [self completeEditing];
        // Push a new view controller for athlete selection here
        self.asController = [[AddSwimmerViewController alloc] initWithDatabaseName:db];
        self.viewstate = VS_ADDSWIMMER;
        [self.navigationController pushViewController:self.asController animated:YES];
    }
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // No editing style if not editing or the index path is nil.
    if (self.editing == NO || !indexPath) return UITableViewCellEditingStyleNone;
    // Determine the editing style based on whether the cell is a placeholder for adding content or already
    // existing content. Existing content can be deleted.
    if (indexPath.section == SECTION_MHSAA) {
        if (self.editing && indexPath.row == [self.theMHSAASwimmers count]) {
            return UITableViewCellEditingStyleInsert;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    } else {
        if (self.editing && indexPath.row == (self.rows-1)) {
            return UITableViewCellEditingStyleInsert;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (void) completeEditing
{
    UITableView* tableView = (UITableView*)[self view];
    NSString* title = [self.theSwimmers count] == 0 ? @"Add Swimmer" : @"Edit";
    [super setEditing:NO animated:NO];
    [tableView setEditing:NO animated:NO];
    [tableView reloadData];
    [self.navigationItem.leftBarButtonItem setTitle:title];
    [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
}

- (IBAction) EditTable:(id)sender {
    UITableView* tableView = (UITableView*)[self view];
    if(self.editing)
    {
        [self completeEditing];
    }
    else
    {
        // start editing mode
        [super setEditing:YES animated:YES];
        [tableView setEditing:YES animated:YES];
        [tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
}

- (void)dealloc
{
    [super dealloc];
    [_allTimes release];
    _allTimes = nil;
    [_queue release];
    _queue = nil;
    //[_selectedAthlete release];
    //_selectedAthlete = nil;
    [_selectedAthleteCD release];
    _selectedAthleteCD = nil;
    // TODO: Crashing here ------------
    // [_managedObjectContext release];
    // _managedObjectContext = nil;
    // --------------------------------
    //[_athletes release];
    //_athletes = nil;
    [_IMStrokes release];
    _IMStrokes = nil;
}

@end
