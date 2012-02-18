//
//  RecentRacesViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/16/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "RecentRacesViewController.h"
#import "Swimmers.h"
#import "TimeStandard.h"

@implementation RecentRacesViewController

@synthesize athlete;
@synthesize results;
@synthesize myTableView;

- (id) initWithAthlete:(AthleteCD*)a
{
    CGRect viewBounds = [ [ UIScreen mainScreen ] applicationFrame ];
    viewBounds.origin.y = 0.0;
    self = [super init]; 
    
    //self = [super initWithStyle:UITableViewStyleGrouped];// initWithFrame:viewBounds];
    if (self) {
        self.athlete = a; 
        self.results = [a allResultsByDate];
        
        BOOL* isPersonalBest;       // array of booleans

        /* Go once through the list in chronological order marking races that were personal bests at the time */
        isPersonalBest = malloc(sizeof(Boolean)* [self.results count]);
        float besttime[5][8];
        for (int i=0;i<5;i++) {
            for (int j=0;j<8;j++) {
                besttime[i][j] = 99999999999999;
            }
        }
        if (NULL != isPersonalBest) {
            for (int i=[self.results count]-1;i>=0;i--) {
                RaceResult* race = [self.results objectAtIndex:i];
                int distidx = [TimeStandard distanceIndex:[race.distance intValue]];    // 0-based
                int nStroke = [Swimmers intStrokeValue:race.stroke]-1;  // 1-based
                assert(distidx < 8);
                assert(nStroke < 5);
                float ftime = [TimeStandard getFloatTimeFromStringTime:race.time];
                //NSLog(@"%@ %@ %@ %@",race.date,race.stroke,race.distance,race.time);
                if (ftime < besttime[nStroke][distidx]) {
                    besttime[nStroke][distidx] = ftime;
                    isPersonalBest[i] = YES;
                    //NSLog(@"^^^^PERSONAL BEST^^^^ %d",i);
                } else {
                    isPersonalBest[i] = NO;
                }
            }
        }
        
        /* And again grouping results by meet */
        NSString* meetCurrent = nil;
        _meets = [[NSMutableArray alloc] init];
        _personalbests = [[NSMutableArray alloc] init];
        NSMutableArray* racesForMeet;
        NSMutableArray* personalBestsForMeet;
        int k = 0;
        int m = 0;
        for (RaceResult* r in self.results) {
            if (![meetCurrent isEqualToString:r.meet]) {
                // new meet
                //NSLog(@"MEET %d---%@",m++,r.meet);
                racesForMeet = [[NSMutableArray alloc] init];
                personalBestsForMeet = [[NSMutableArray alloc] init];
                [_meets addObject:racesForMeet];
                [_personalbests addObject:personalBestsForMeet];
                meetCurrent = r.meet;
            }
            //NSLog(@"[%d] %@ %@ %@ PB:%d",k,r.date,r.distance,r.time,isPersonalBest[k]?1:0);
            [racesForMeet addObject:r];
            [personalBestsForMeet addObject:[NSNumber numberWithBool:isPersonalBest[k]?YES:NO]];
            k++;
        }

        if (isPersonalBest != NULL) {
            free(isPersonalBest);
        }
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:viewBounds];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UnderWater-Portrait-iPhone.png"]];
        [self.view addSubview:backgroundView];
        [backgroundView release];
        
        self.myTableView = [[[UITableView alloc] initWithFrame:viewBounds style:UITableViewStyleGrouped] autorelease];
        [self.myTableView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:self.myTableView];
        
        self.view.backgroundColor = [UIColor clearColor];
        self.myTableView.alpha = 0.7;
        self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.myTableView setDataSource:self];
        [self.myTableView setDelegate:self];
    }
    
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"All Times";
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (self.editing) ? [_meets count] + 1 : [_meets count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.editing && section == 0) {
        return 0;
    } else if (self.editing) {
        section--;
    }
    NSMutableArray* r = [_meets objectAtIndex:section];
    return [r count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    int ridx = (self.editing) ? section-1 : section;
    if (self.editing && section == 0) {
        return @"Add New Meet";
    } else {
        NSMutableArray* races = [_meets objectAtIndex:ridx];
        if (races != nil) {
            RaceResult* race = [races objectAtIndex:0];
            if (race != nil) {
                return [race shortenMeetName];
            }
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
    NSNumber* pb = nil;
    NSMutableArray* personalBests = [_personalbests objectAtIndex:indexPath.section]; 
    if (personalBests != nil) {
        pb = [personalBests objectAtIndex:indexPath.row];
    } 
    //NSLog(@"Section %d %@",indexPath.section,[race shortenMeetName]);
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *raceDateString = [dateFormatter stringFromDate:race.date];
    
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;

    if ([race.powerpoints intValue] > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@\n%@  (%d Points) %@", [race.distance intValue], race.stroke, race.time, [race.powerpoints intValue], [pb boolValue] ? @"\u263A" : @""];
    } else {
        // If this race was a personal best, add a smiley :)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@\n%@ %@", [race.distance intValue], race.stroke, race.time, [pb boolValue] ? @"\u263A" : @""];
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
