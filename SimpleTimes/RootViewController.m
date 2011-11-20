//
//  RootViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "RaceResult.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (nil == self.CurrentTitle) {
        self.title = @"Select Swimmer";
    } else {
        self.title = self.CurrentTitle;
    }
    
    if (self.selectedAthlete == 0) {
//        MISwimDBProxy* proxy = [[[MISwimDBProxy alloc] init] autorelease];
  //      NSArray* athletes = [proxy getAllAthletesWithLastName:@"Laporte"];
        
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
    if (self.selectedAthlete == 0) {
        return [self.athletes count];
    } else if (self.selectedStroke == 0) {
        return [self.strokes count];
    } else if (self.selectedStroke >= 99) {
        return [_allTimes count];   // all best times
    } else if (self.selectedDistance == 0) {
        return [self.distances count];
    } else if (self.selectedRace > 0) {
        return [_allSplits count];
    } else {
        return [_allTimes count];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (self.selectedAthlete == 0) {
        // We are displaying the athlete list
        cell.textLabel.text = [[self.athletes objectAtIndex:indexPath.row] objectAtIndex:0];       
        cell.detailTextLabel.text = @""; //[[self.athletes objectAtIndex:indexPath.row] objectAtIndex:1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (self.selectedStroke == 0) {
        // We are displaying the stroke list
        cell.textLabel.text = [[self.strokes objectAtIndex:indexPath.row] objectAtIndex:0];       
        cell.detailTextLabel.text = @""; //[[self.strokes objectAtIndex:indexPath.row] objectAtIndex:1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ((self.selectedDistance == 0) && (self.selectedStroke < 99)) {
        // We are displaying the stroke list
        cell.textLabel.text = [[self.distances objectAtIndex:indexPath.row] objectAtIndex:0];       
        cell.detailTextLabel.text = @"Short course yards"; //[[self.strokes objectAtIndex:indexPath.row] objectAtIndex:1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (self.selectedRace > 0) {
        cell.textLabel.text = [_allSplits objectAtIndex:indexPath.row];       
    } else {
        RaceResult *race = [_allTimes objectAtIndex:indexPath.row];
    
        NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *raceDateString = [dateFormatter stringFromDate:race.date];
    
        cell.textLabel.text = [NSString stringWithFormat:@"%d %@ - %@", race.distance, race.stroke, race.time];       
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", raceDateString, race.meet];
        if (race.distance >= 200) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    if (self.selectedAthlete == 0) {
        // Get ready to display this athletes times
        //Prepare to tableview.
        RootViewController *rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
        
        //Increment the Current View
        rvController.selectedAthlete = [[[self.athletes objectAtIndex:indexPath.row] objectAtIndex:1] intValue];
        
        //Set the title;
        rvController.CurrentTitle = @"Strokes";
        
        //Push the new table view on the stack
        [self.navigationController pushViewController:rvController animated:YES];
        
        [rvController release];
    } else if (self.selectedStroke == 0) {
        // Get ready to display this distance
        //Prepare to tableview.
        RootViewController *rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
        
        //Increment the Current View
        rvController.selectedStroke = [[[self.strokes objectAtIndex:indexPath.row] objectAtIndex:1] intValue];
        rvController.selectedAthlete = self.selectedAthlete;
        
        //Set the title;
        if (rvController.selectedStroke < 99)
            rvController.CurrentTitle = @"Distance";
        else
            rvController.CurrentTitle = @"Top Times";
        
        //Push the new table view on the stack
        [self.navigationController pushViewController:rvController animated:YES];
        
        [rvController release];
    } else if ((self.selectedDistance == 0) && (self.selectedStroke < 99)) {
        // Get ready to display this distance
        //Prepare to tableview.
        RootViewController *rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
        
        //Increment the Current View
        rvController.selectedDistance = [[[self.distances objectAtIndex:indexPath.row] objectAtIndex:1] intValue];
        rvController.selectedStroke = self.selectedStroke;
        rvController.selectedAthlete = self.selectedAthlete;
        
        //Set the title;
        rvController.CurrentTitle = @"Times";
        
        //Push the new table view on the stack
        [self.navigationController pushViewController:rvController animated:YES];
        
        [rvController release];
    } else if (self.selectedDistance >= 200) {
        // Get ready to show splits data
        //Prepare to tableview.
        RootViewController *rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
        
        // Increment the Current View
        rvController.selectedDistance = self.selectedDistance;
        rvController.selectedStroke = self.selectedStroke;
        rvController.selectedAthlete = self.selectedAthlete;
        RaceResult* race = [self.allTimes objectAtIndex:indexPath.row];
        rvController.selectedRace = race.key;
        //Set the title;
        rvController.CurrentTitle = @"Split Times";
        
        //Push the new table view on the stack
        [self.navigationController pushViewController:rvController animated:YES];
        
        [rvController release];
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
    _allSplits = [splits copy];
    NSLog(@"Number of results: %d",[splits count]);
    for (int i=0;i<[splits count];i++) {
        int insertIdx = 0;  
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
}

@end
