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

@implementation RootViewController

@synthesize allTimes = _allTimes;
@synthesize allSplits = _allSplits;
//@synthesize athletes = _athletes;
@synthesize allRaceIds = _allRaceIds;
@synthesize strokes = _strokes;
@synthesize distances = _distances;
@synthesize queue = _queue;
//@synthesize selectedAthlete = _selectedAthlete;
@synthesize selectedAthleteCD = _selectedAthleteCD;
@synthesize selectedStroke = _selectedStroke;
@synthesize selectedDistance = _selectedDistance;
@synthesize CurrentTitle = _currentTitle;
@synthesize selectedRace = _selectedRace;
@synthesize IMStrokes = _IMStrokes;
@synthesize viewstate = _viewstate;
@synthesize rows = _rows;
@synthesize managedObjectContext = _managedObjectContext;

// VIEWSTATEs
#define VS_ATHLETES   1
#define VS_STROKES    2
#define VS_DISTANCE   3
#define VS_RESULTS    4
#define VS_SPLITS     5
#define VS_ADDSWIMMER 6

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assert( self.managedObjectContext != nil );
    
    if (nil == self.CurrentTitle) {
        self.title = @"Select Swimmer";
        self.viewstate = VS_ATHLETES;
        theSwimmers = [[Swimmers alloc] init];
        [theSwimmers loadWithContext:self.managedObjectContext];        
    } else {
        self.title = self.CurrentTitle;
    }
    
    // TODO: This should be a class var not an ivar
    self.IMStrokes = [NSArray arrayWithObjects:@"Fly",@"Back",@"Breast",@"Freestyle", nil];
    
    if (self.viewstate == VS_ATHLETES) {
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];
        [self.navigationItem setLeftBarButtonItem:addButton];
        
        for (int i=0;i<[theSwimmers count];i++) {
            int insertIdx = 0; 
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        }
    } else if (self.selectedStroke == 0) {
        self.strokes = [NSArray arrayWithObjects:
                       [NSArray arrayWithObjects:@"Freestyle", @"1", nil],
                       [NSArray arrayWithObjects:@"Backstroke", @"2", nil],
                       [NSArray arrayWithObjects:@"Breaststroke", @"3", nil],
                       [NSArray arrayWithObjects:@"Fly", @"4", nil],
                       [NSArray arrayWithObjects:@"IM", @"5", nil],
                       [NSArray arrayWithObjects:@"Top times all strokes", @"99", nil],
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

- (void)viewWillAppear:(BOOL)animated
{
    if (self.viewstate == VS_ADDSWIMMER) {
        self.viewstate = VS_ATHLETES;
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
            self.rows = [theSwimmers count];      
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
    if(self.editing) 
        self.rows++;
    return self.rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RaceResult *race;
    AthleteCD* athlete;
    Split *split;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Are we in edit mode????
    NSLog(@"self.rows=%d, indexPath=%d",self.rows,indexPath.row);
    if (self.editing && (indexPath.row == (self.rows-1))) {
        cell.textLabel.text = @"Add new swimmer";
        return cell;
    } else {
        switch (self.viewstate) {
            case VS_ATHLETES:
                // We are displaying the athlete list
                athlete = [theSwimmers.athletesCD objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",athlete.firstname, athlete.lastname];       
                cell.detailTextLabel.text = @""; 
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case VS_STROKES:
                // We are displaying the stroke list
                cell.textLabel.text = [[self.strokes objectAtIndex:indexPath.row] objectAtIndex:0];       
                cell.detailTextLabel.text = @""; //[[self.strokes objectAtIndex:indexPath.row] objectAtIndex:1];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case VS_DISTANCE:
                // We are displaying the stroke list
                cell.textLabel.text = [[self.distances objectAtIndex:indexPath.row] objectAtIndex:0];       
                cell.detailTextLabel.text = @"Short course yards"; //[[self.strokes objectAtIndex:indexPath.row] objectAtIndex:1];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case VS_RESULTS:
                race = [_allTimes objectAtIndex:indexPath.row];
                
                NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                NSString *raceDateString = [dateFormatter stringFromDate:race.date];
                float ftime = [TimeStandard getFloatTimeFromStringTime:race.time];
                int nStroke = [race intStrokeValue];
                NSString *timestd = [TimeStandard getTimeStandardWithAge:[self.selectedAthleteCD ageAtDate:race.date] distance:race.distance stroke:nStroke gender:self.selectedAthleteCD.gender time:ftime];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%d %@ - %@ %@", race.distance, race.stroke, race.time, timestd];       
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", raceDateString, race.meet];
                if ([race hasSplits]) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                break;
            case VS_SPLITS:
                split = [_allSplits objectAtIndex:indexPath.row];
                /* Is this an IM???? */
                if (self.selectedStroke == 5) {
                    // Add the current stroke
                    int divisor = self.selectedDistance / 4;
                    int stroke_index = ([split.distance intValue]-1) / divisor;
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@  (%@)", split.distance, split.time_cumulative,[self.IMStrokes objectAtIndex:stroke_index]]; 
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", split.distance, split.time_cumulative]; 
                }
                cell.detailTextLabel.text = split.time_split;
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
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
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
            rvController.selectedAthleteCD = [theSwimmers.athletesCD objectAtIndex:indexPath.row];
            rvController.managedObjectContext = self.managedObjectContext;
            rvController.CurrentTitle = @"Strokes";
            rvController.viewstate = VS_STROKES;
            
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
                rvController.CurrentTitle = @"Distance";
                rvController.viewstate = VS_DISTANCE;
            } else {
                rvController.CurrentTitle = @"Top Times";
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
            
            //Set the title;
            rvController.CurrentTitle = @"Times";            
            //Push the new table view on the stack
            [self.navigationController pushViewController:rvController animated:YES];
            
            [rvController release];
            break;

        case VS_RESULTS:
            // Split data available for this result??
            
            race = [self.allTimes objectAtIndex:indexPath.row];
            if (race.distance > 50) {
                // Get ready to show splits data
                rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
                
                // Increment the Current View
                rvController.selectedDistance = self.selectedDistance;
                rvController.selectedStroke = self.selectedStroke;
                rvController.selectedAthleteCD = self.selectedAthleteCD;
                rvController.selectedRace = race.key;
                rvController.managedObjectContext = self.managedObjectContext;
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
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

// Add new method
- (void)refresh {
    MISwimDBProxy* proxy = [[[MISwimDBProxy alloc] init] autorelease];
    //USASwimmingDBProxy* proxy = [[[USASwimmingDBProxy alloc] init] autorelease];
    
    NSArray* times = [proxy getAllTimesForAthlete:[self.selectedAthleteCD.miswimid intValue]:self.selectedStroke:self.selectedDistance];
        
    NSLog(@"Number of results: %d",[times count]);
    for (int i=0;i<[times count];i++) {
        //NSLog([all_times objectAtIndex:i]);

        RaceResult *race = [times objectAtIndex:i];
            
        int insertIdx = 0;                    
        [_allTimes insertObject:race atIndex:insertIdx];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
        
        // TODO: ASync
        //NSURL *url = [NSURL URLWithString:feed];
        //ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        //[request setDelegate:self];
        //[_queue addOperation:request];
}

- (void)refreshAllBestTimes {
    MISwimDBProxy* proxy = [[[MISwimDBProxy alloc] init] autorelease];
    //USASwimmingDBProxy* proxy = [[[USASwimmingDBProxy alloc] init] autorelease];
    
    NSArray* times = [proxy getFastestTimesForAthlete:[self.selectedAthleteCD.miswimid intValue]]; // todo
    
    NSLog(@"Number of results: %d",[times count]);
    for (int i=0;i<[times count];i++) {
        //NSLog([all_times objectAtIndex:i]);
        
        RaceResult *race = [times objectAtIndex:i];
        
        int insertIdx = 0;                    
        [_allTimes insertObject:race atIndex:insertIdx];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
    
}

- (void)refreshSplitTimes {
    MISwimDBProxy* proxy = [[[MISwimDBProxy alloc] init] autorelease];
    //USASwimmingDBProxy* proxy = [[[USASwimmingDBProxy alloc] init] autorelease];
    
    NSArray *splits = [proxy getSplitsForRace:self.selectedRace]; 
    //_allSplits = [splits copy];
    _allSplits = [[NSMutableArray alloc] init]; //[NSMutableArray array];
    NSLog(@"Number of Split results: %d",[splits count]);
    for (int i=0;i<[splits count];i++) {
        int insertIdx = 0; 
        Split* split = [splits objectAtIndex:i];
        [_allSplits insertObject:split atIndex:insertIdx];
        //[_allSplits insertObject:[splits objectAtIndex:i] atIndex:insertIdx];
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
        // TODO Add delete method in Swimmers class [theSwimmers.athletes removeObjectAtIndex:indexPath.row];
        NSLog(@"Delete at %d",indexPath.row);
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // TODO: Need to push a new view controller for athlete selection here
        asController = [[AddSwimmerViewController alloc] initWithNibName:@"AddSwimmerViewController" bundle:[NSBundle mainBundle]];
        self.viewstate = VS_ADDSWIMMER;
        [self.navigationController pushViewController:asController animated:YES];
//        [asController release];
  //      asController = nil;
        
        //[self.athletes insertObject:[NSArray arrayWithObjects:@"Babba Booie", @"11655", nil] atIndex:[self.athletes count]];
        //[tableView reloadData];
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

- (IBAction) EditTable:(id)sender{
    UITableView* tableView = (UITableView*)[self view];
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        [tableView setEditing:NO animated:NO];
        [tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
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
    [_managedObjectContext release];
    _managedObjectContext = nil;
    //[_athletes release];
    //_athletes = nil;
    [_IMStrokes release];
    _IMStrokes = nil;
}

@end
