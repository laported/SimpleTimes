//
//  RecentResultsViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/15/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RecentResultsViewController.h"
#import "Swimmers.h"

@implementation RecentResultsViewController

@synthesize athlete;
@synthesize results;
//@synthesize myTableView;

- (id) initWithAthlete:(AthleteCD*)a andContext:(NSManagedObjectContext*)context
{
    /*CGRect viewBounds = [ [ UIScreen mainScreen ] applicationFrame ];
    viewBounds.origin.y = 0.0;*/
    self = [super initWithStyle:UITableViewStyleGrouped];// initWithFrame:viewBounds];
    if (self) {
        self.athlete = a; 
        self.results = [a allResultsByDate];
        NSString* meetCurrent = nil;
        _meets = [[NSMutableArray alloc] init];
        NSMutableArray* racesForMeet;
        for (RaceResult* r in self.results) {
            if (![meetCurrent isEqualToString:r.meet]) {
                // new meet
                //NSLog(@"---------------------------");
                racesForMeet = [[NSMutableArray alloc] init];
                [_meets addObject:racesForMeet];
                meetCurrent = r.meet;
            }
            NSLog(@"%@ %@ %@ %@",r.date,r.meet,r.distance,r.time);
            [racesForMeet addObject:r];
       }
    }
    /*
    UIView *backgroundView = [[UIView alloc] initWithFrame:viewBounds];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UnderWater-Portrait-iPhone.png"]];
    [self.view addSubview:backgroundView];
    [backgroundView release];
     
    self.myTableView = [[[UITableView alloc] initWithFrame:viewBounds style:UITableViewStyleGrouped] autorelease];
    [self.myTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.myTableView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.myTableView.alpha = 0.7;
    */
    return self;
}

-(void) dealloc
{
    for (NSMutableArray* a in _meets) {
        [a release];
    }
    [_meets release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_meets count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSMutableArray* r = [_meets objectAtIndex:section];
    return [r count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSMutableArray* races = [_meets objectAtIndex:section];
    if (races != nil) {
        RaceResult* race = [races objectAtIndex:0];
        if (race != nil) {
            return [race shortenMeetName];
        }
    }
    return @"Unknown meet";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    RaceResult* race = nil;
    NSMutableArray* races = [_meets objectAtIndex:indexPath.section];
    if (races != nil) {
        race = [races objectAtIndex:indexPath.row];
    }
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *raceDateString = [dateFormatter stringFromDate:race.date];

    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    if ([race.powerpoints intValue] > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@\n%@  (%d Points)", [race.distance intValue], race.stroke, race.time, [race.powerpoints intValue]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@\n%@", [race.distance intValue], race.stroke, race.time];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", raceDateString];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
