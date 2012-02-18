//
//  CutsViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/15/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "CutsViewController.h"
#import "RaceResult.h"

@implementation CutsViewController

@synthesize myTableView;

- (id) initWithAthlete:(AthleteCD*)athlete
{
    self = [super init];//[super initWithNibName:@"CutsViewController" bundle:nil];
    if (self) {
        CGRect viewBounds = [ [ UIScreen mainScreen ] applicationFrame ];
         viewBounds.origin.y = 0.0;
        UIView *backgroundView = [[UIView alloc] initWithFrame:viewBounds];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UnderWater-Portrait-iPhone.png"]];
        [self.view addSubview:backgroundView];
        [backgroundView release];
        
        self.myTableView = [[[UITableView alloc] initWithFrame:viewBounds style:UITableViewStyleGrouped] autorelease];
        [self.myTableView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:self.myTableView];
        
        self.view.backgroundColor = [UIColor clearColor];
        self.myTableView.alpha = 0.7;
        [self.myTableView setDataSource:self];
        [self.myTableView setDelegate:self];
        
        _cutlists = [NSArray array];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return [_cutlists count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    CutsViewDataItem* item = [_cutlists objectAtIndex:section];
    return [item.cuts count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    CutsViewDataItem* item = [_cutlists objectAtIndex:section];
    if (item != nil) {
        return item.standard;
    }
    return @"Unknown time standard";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    /*
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
    */
    cell.textLabel.text = @"TODO";
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
