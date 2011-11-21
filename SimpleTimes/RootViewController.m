//
//  RootViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "RaceResult.h"
#import "Split.h"
#import "MISwimDBProxy.h"
#import "USASwimmingDBProxy.h"

@implementation RootViewController

@synthesize allTimes = _allTimes;
@synthesize allSplits = _allSplits;
@synthesize athletes = _athletes;
@synthesize allRaceIds = _allRaceIds;
@synthesize strokes = _strokes;
@synthesize distances = _distances;
@synthesize queue = _queue;
@synthesize selectedAthlete = _selectedAthlete;
@synthesize selectedStroke = _selectedStroke;
@synthesize selectedDistance = _selectedDistance;
@synthesize CurrentTitle = _currentTitle;
@synthesize selectedRace = _selectedRace;
@synthesize IMStrokes = _IMStrokes;
@synthesize viewstate = _viewstate;

// VIEWSTATEs
#define VS_ATHLETES 1
#define VS_STROKES  2
#define VS_DISTANCE 3
#define VS_RESULTS  4
#define VS_SPLITS   5

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (nil == self.CurrentTitle) {
        self.title = @"Select Swimmer";
        self.viewstate = VS_ATHLETES;
    } else {
        self.title = self.CurrentTitle;
    }
    
    // TODO: This should be a class var not an ivar
    self.IMStrokes = [NSArray arrayWithObjects:@"Fly",@"Back",@"Breast",@"Freestyle", nil];
    
    if (self.selectedAthlete == 0) {
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];
        [self.navigationItem setLeftBarButtonItem:addButton];
        
        self.athletes = [NSArray arrayWithObjects:
                         [NSArray arrayWithObjects:@"Benjamin LaPorte", @"11655", nil],
                         [NSArray arrayWithObjects:@"Matthew LaPorte", @"11657", nil],
                         [NSArray arrayWithObjects:@"Kelly LaPorte", @"11656", nil],
                         nil];
    
        for (int i=0;i<[self.athletes count];i++) {
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

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.viewstate) {
        case VS_ATHLETES:
            return [self.athletes count];
        case VS_STROKES:
            return [self.strokes count];
        case VS_DISTANCE:
            return [self.distances count];
        case VS_RESULTS:
            return [_allTimes count];
        case VS_SPLITS:
            return [_allSplits count];
        default:
            NSLog(@"ERROR: numberOfRowsInSection UNKNOWN!!! for viewstate=%d",self.viewstate);
            return 0;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RaceResult *race;
    Split *split;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (self.viewstate) {
        case VS_ATHLETES:
            // We are displaying the athlete list
            cell.textLabel.text = [[self.athletes objectAtIndex:indexPath.row] objectAtIndex:0];       
            cell.detailTextLabel.text = @""; //[[self.athletes objectAtIndex:indexPath.row] objectAtIndex:1];
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
            
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@ - %@", race.distance, race.stroke, race.time];       
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
            rvController.selectedAthlete = [[[self.athletes objectAtIndex:indexPath.row] objectAtIndex:1] intValue];
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
            rvController.selectedAthlete = self.selectedAthlete;
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
            rvController.selectedStroke = self.selectedStroke;
            rvController.selectedAthlete = self.selectedAthlete;
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
                rvController.selectedAthlete = self.selectedAthlete;
                rvController.selectedRace = race.key;
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
    
    NSArray* times = [proxy getAllTimesForAthlete:self.selectedAthlete:self.selectedStroke:self.selectedDistance];
        
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
    
    NSArray* times = [proxy getFastestTimesForAthlete:self.selectedAthlete]; // todo
    
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

- (IBAction) EditTable:(id)sender{
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        // TODO [tblSimpleTable setEditing:NO animated:NO];
        // TODO [tblSimpleTable reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        //TODO[tblSimpleTable setEditing:YES animated:YES];
        //TODO[tblSimpleTable reloadData];
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
    [_athletes release];
    _athletes = nil;
    [_IMStrokes release];
    _IMStrokes = nil;
}

@end
