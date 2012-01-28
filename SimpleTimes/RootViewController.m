//
//  RootViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import "RootViewController.h"
#import "AddSwimmerViewController.h"
#import "RaceResult.h"
#import "Split.h"
#import "MISwimDBProxy.h"
#import "USASwimmingDBProxy.h"
#import "TimeStandard.h"
#import "DownloadTimesMI.h"
#import "SVProgressHUD.h"

#define ASYNC_REFRESH

@implementation RootViewController

@synthesize allTimes = _allTimes;
@synthesize allSplits = _allSplits;
@synthesize allRaceIds = _allRaceIds;
@synthesize strokes = _strokes;
@synthesize distances = _distances;
@synthesize queue = _queue;
@synthesize selectedAthleteCD = _selectedAthleteCD;
@synthesize theSwimmers = _theSwimmers;
@synthesize selectedStroke = _selectedStroke;
@synthesize selectedDistance = _selectedDistance;
@synthesize CurrentTitle = _currentTitle;
@synthesize selectedRace = _selectedRace;
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
    
    if (nil == self.CurrentTitle) {
        self.title = @"Swimmers";
        self.viewstate = VS_ATHLETES;
        self.theSwimmers = [[Swimmers alloc] init];
        [self.theSwimmers loadWithContext:self.managedObjectContext];        
    } else {
        self.title = self.CurrentTitle;
    }
    
    // TODO: This should be a class var not an ivar
    self.IMStrokes = [NSArray arrayWithObjects:@"Fly",@"Back",@"Breast",@"Freestyle", nil];
    
    if (self.viewstate == VS_ATHLETES) {
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];
        [self.navigationItem setLeftBarButtonItem:addButton];
        
        for (int i=0;i<[self.theSwimmers count];i++) {
            int insertIdx = 0; 
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        }
        
    } else if (self.selectedStroke == 0) {
        self.strokes = [NSArray arrayWithObjects:
                       [NSArray arrayWithObjects:@"Personal Best", @"99", nil],
                       [NSArray arrayWithObjects:@"Freestyle", @"1", nil],
                       [NSArray arrayWithObjects:@"Backstroke", @"2", nil],
                       [NSArray arrayWithObjects:@"Breaststroke", @"3", nil],
                       [NSArray arrayWithObjects:@"Fly", @"4", nil],
                       [NSArray arrayWithObjects:@"IM", @"5", nil],
                       nil];
    } else if ((self.selectedDistance == 0) && (self.selectedStroke < 99)) {
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
       if (self.selectedRace > 0) {
           // Get a list of best times for each stroke
           self.allTimes = [NSMutableArray array];
           self.queue = [[[NSOperationQueue alloc] init] autorelease];
           [self refreshSplitTimes];
       } else if (self.selectedStroke == 99) {
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
        [self.tableView reloadData];
    } else {
        // Updating results for single swimmer
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
    DownloadTimesMI* dtm = [[DownloadTimesMI alloc] initWithAthlete:self.selectedAthleteCD:self];
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
    /* Are we coming back from the 'Add Swimmer' dialog ? */
    if (self.viewstate == VS_ADDSWIMMER) {
        
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
                assert( false );    // TODO: Recode if we support other data providers
            }
        } else {
            // nothing selected
            self.viewstate = VS_ATHLETES;
        }
        
    } else if (self.viewstate == VS_GETBIRTHDATE) {
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
        
        // reload
        [self.theSwimmers release];
        self.theSwimmers = [[Swimmers alloc] init];        
        [self.theSwimmers loadWithContext:self.managedObjectContext]; 

#ifdef ASYNC_REFRESH
        self.queue = [[NSOperationQueue alloc] init];
        
        // download all times into the database for the new swimmer
        DownloadTimesMI* dtm = [[DownloadTimesMI alloc] initWithAthlete:ath1:self];
        [self.queue addOperation:dtm];
        [dtm release];
        
        // TODO 20120123 
        // ------------- Need to debug adding new swimer asynchronously
        
#else
        // download all times and populate the database
        [self.theSwimmers updateAllRaceResultsForAthlete:ath1 inContext:self.managedObjectContext];
        [self.theSwimmers loadWithContext:self.managedObjectContext]; 
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
#endif
        
    } else if (self.viewstate == VS_STROKES) {
        UIBarButtonItem* button = [[[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(onRefresh:)] autorelease];
        self.navigationItem.rightBarButtonItem = button;
    }
    [super viewWillAppear:animated];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
            self.rows = [_allSplits count];
            break;
        default:
            NSLog(@"ERROR: numberOfRowsInSection UNKNOWN!!! for viewstate=%d",self.viewstate);
            break;
    }
    if(self.editing) { 
        self.rows++;
        NSLog(@"Editing=true, numRows: %d",self.rows);
    }
    return self.rows;
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RaceResult *race;
    AthleteCD* athlete;
    Split *split;
    CUTS cuts;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Are we in edit mode????
    NSLog(@"cellForRowAtIndexPath/self.rows=%d, indexPath=%d",self.rows,indexPath.row);
    if (self.editing && (indexPath.row == (self.rows-1))) {
        NSLog(@"%@",@"cellForRowAtIndexPath/'Add new Swimmer'");
        cell.textLabel.text = @"Add new swimmer";
         cell.detailTextLabel.text = @"";
        return cell;
    } else {
        switch (self.viewstate) {
            case VS_ATHLETES:
                // We are displaying the athlete list
                athlete = [self.theSwimmers.athletesCD objectAtIndex:indexPath.row];
                [athlete countCuts:&cuts];
                NSLog(@"cellForRowAtIndexPath/last=%@,first=%@",athlete.lastname,athlete.firstname);
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",athlete.firstname, athlete.lastname];    
                if (cuts.jos > 0 || cuts.states > 0 || cuts.sectionals > 0 || cuts.nationals > 0) {
                    NSString* jos = cuts.jos > 0 ? [self cutsWithStars:cuts.jos andPrefix:@"JO"] : @"";
                    NSString* states = cuts.states > 0 ? [self cutsWithStars:cuts.states andPrefix:@"ST"] : @"";
                    NSString* sectionals = cuts.sectionals > 0 ? [self cutsWithStars:cuts.sectionals andPrefix:@"SE"] : @"";
                    NSString* nationals = cuts.nationals > 0 ? [self cutsWithStars:cuts.nationals andPrefix:@"NA"] : @"";
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",athlete.firstname, athlete.lastname, athlete.club]; 
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",nationals,sectionals,states,jos];
                    //cell.detailTextLabel.textColor = [UIColor colorWithRed:218.0/255.0 green:165.0/255.0 blue:32.0/255.0 alpha:1.0];
                } else {
                    cell.detailTextLabel.text = athlete.club; 
                }
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
                NSString *timestd = [TimeStandard getTimeStandardWithAge:[self.selectedAthleteCD ageAtDate:race.date] distance:[race.distance intValue] stroke:nStroke gender:self.selectedAthleteCD.gender time:ftime];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%d %@ - %@ %@", [race.distance intValue], race.stroke, race.time, timestd];       
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", raceDateString, race.meet];
                if ([race.splitskey intValue] > 0) { 
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                break;
                
            case VS_SPLITS:
                split = [_allSplits objectAtIndex:indexPath.row];
                /* Is this an IM???? */
                if (self.selectedStroke == 5) {
                    // IM: Add the current stroke for this split
                    int divisor = self.selectedDistance / 4;
                    int stroke_index = ([split.distance intValue]-1) / divisor;
                    // 100 IMs will probably not have splits on the 25s, so we may need
                    // to adjust the display to show combined strokes
                    if (([split.distance intValue] == 100) && ([_allSplits count] == 2)) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@  (%@ + %@)", split.distance, split.time_cumulative,[self.IMStrokes objectAtIndex:stroke_index],[self.IMStrokes objectAtIndex:stroke_index+1]]; 
                    } else {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@  (%@)", split.distance, split.time_cumulative,[self.IMStrokes objectAtIndex:stroke_index]]; 
                    }
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", split.distance, split.time_cumulative];
                }
                // If these are 25 splits, combine into 50s as well
                if ((self.selectedDistance / 25 == [_allSplits count]) && (indexPath.row % 2)) {
                    NSUInteger lastrow = indexPath.row-1;
                    
                    Split* lastSplit = [_allSplits objectAtIndex:lastrow];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%3.2f)", split.time_split, [split.time_split floatValue] + [lastSplit.time_split floatValue]]; 
                } else {
                    cell.detailTextLabel.text = split.time_split;
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
            rvController.selectedAthleteCD = [self.theSwimmers.athletesCD objectAtIndex:indexPath.row];
            rvController.managedObjectContext = self.managedObjectContext;
            NSLog(@"VS_ATHLETES->VS_STROKES: %@",self.managedObjectContext);
            rvController.CurrentTitle = rvController.selectedAthleteCD.firstname;
            rvController.viewstate = VS_STROKES;
            rvController.theSwimmers = self.theSwimmers;
            
            //Push the new table view on the stack
            [self.navigationController pushViewController:rvController animated:YES];
            [rvController release];
            break;
            
        case VS_STROKES:
            // We are on the "List of strokes" table.
            // We either want to display a list of distances (If selecting single stroke,
            // or we want to display a list of all best times 
            // Get ready to display this distance
            //Prepare to tableview.
            rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
            
            //Increment the Current View
            rvController.selectedStroke = [[[self.strokes objectAtIndex:indexPath.row] objectAtIndex:1] intValue];
            rvController.managedObjectContext = self.managedObjectContext;
            rvController.selectedAthleteCD = self.selectedAthleteCD;
            if (rvController.selectedStroke < 99) {
                NSLog(@"VS_STROKES->VS_DISTANCE: %@",self.managedObjectContext);
                rvController.CurrentTitle = @"Distance";
                rvController.viewstate = VS_DISTANCE;
            } else {
                rvController.CurrentTitle = @"Top Times";
                NSLog(@"VS_STROKES->VS_RESULTS: %@",self.managedObjectContext);
                rvController.viewstate = VS_RESULTS;
            }
            
            //Push the new table view on the stack
            [self.navigationController pushViewController:rvController animated:YES];            
            [rvController release];
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
            NSLog(@"VS_DISTANCE->VS_RESULTS: %@",self.managedObjectContext);
            
            //Set the title;
            rvController.CurrentTitle = @"Times";            
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
                rvController.selectedRace = [race.splitskey intValue];
                rvController.managedObjectContext = self.managedObjectContext;
                NSLog(@"VS_RESULTS->VS_SPLITS: %@",self.managedObjectContext);
                //Set the title;
                rvController.CurrentTitle = @"Split Times";
                rvController.viewstate = VS_SPLITS;
                
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
    for (int i=0;i<[best_times count];i++) {
        
        RaceResult *race = [best_times objectAtIndex:i];
        
        int insertIdx = 0;                    
        [_allTimes insertObject:race atIndex:insertIdx];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }

}
- (void)refreshSplitTimes {
    MISwimDBProxy* proxy = [[[MISwimDBProxy alloc] init] autorelease];
    //USASwimmingDBProxy* proxy = [[[USASwimmingDBProxy alloc] init] autorelease];
    
    NSArray *splits = [proxy getSplitsForRace:self.selectedRace]; 
    _allSplits = [[NSMutableArray alloc] init]; //[NSMutableArray array];
    NSLog(@"Number of Split results: %d",[splits count]);
    for (int i=0;i<[splits count];i++) {
        int insertIdx = 0; 
        Split* split = [splits objectAtIndex:i];
        if (self.selectedDistance / 25 == [splits count]) {
            // MI Website can sometimes give splits on the 25s (i.e.
            // at pools like Liv Rec Center) but report them as 50s
            // Correct this here
            split.distance = [NSString stringWithFormat:@"%d",([splits count]-i)*25];
        }
        [_allSplits insertObject:split atIndex:insertIdx];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
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
        
        // TODO Add an 'Are you sure?' dialog
        AthleteCD* ath = [self.theSwimmers.athletesCD objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:ath];
        NSError *error;         
        if (![self.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error series %@, %@", error, [error userInfo]);
            
        }

        // remove from the data store
        [self.theSwimmers loadWithContext:self.managedObjectContext];
        
        // ----------
        // todo: remove results from data store and cached document results??
        // ----------
        
        // remove from the table view
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        //[tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Push a new view controller for athlete selection here
        self.asController = [[AddSwimmerViewController alloc] initWithNibName:@"AddSwimmerViewController" bundle:[NSBundle mainBundle]];
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
    if (self.editing && indexPath.row == (self.rows-1)) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (IBAction) EditTable:(id)sender {
    UITableView* tableView = (UITableView*)[self view];
    if(self.editing)
    {
        NSString* title = [self.theSwimmers count] == 0 ? @"Add Swimmer" : @"Edit";
        [super setEditing:NO animated:NO];
        [tableView setEditing:NO animated:NO];
        [tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:title];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
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
    [_allSplits release];
    _allSplits = nil;
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
