//
//  RecentRacesViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/16/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "RecentRacesViewController.h"
#import "Swimmers.h"
#import "Swimming.h"
#import "TimeStandard.h"
#import "RaceResultTeamManager.h"

@implementation RecentRacesViewController

@synthesize athlete;
@synthesize results;
@synthesize myTableView;

#define ST_NORMAL            0
#define ST_GETTING_MEET_NAME 1
#define ST_GETTING_RACE_TIME 2

- (void) freeData
{
    for (NSMutableArray* a in _meets) {
        [a release];
    }
    [_meets release];
    _meets = nil;
    [_addedMeet release];
    _addedMeet = nil;
}

- (void) initializeData
{
    BOOL* isPersonalBest;       // array of booleans
    
    [self freeData];
    
    self.results = [self.athlete allResultsByDate];

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
            NSLog(@"%@ %@ %@ %@",race.date,race.stroke,race.distance,race.time);
            if ([race.distance intValue] == 0) {
                continue;   // bad record in DB during development???
            }
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
}

- (id) initWithAthlete:(AthleteCD*)a andContext:(NSManagedObjectContext*)context course:(NSString*)course
{
    CGRect viewBounds = [ [ UIScreen mainScreen ] applicationFrame ];
    viewBounds.origin.y = 0.0;
    self = [super init]; 
    
    if (self) {
        self.athlete = a; 
        _addedMeet = nil;
        _state = ST_NORMAL;
        _course = course;
        [_course retain];
        
        _context = context;
        [_context retain];
        [self initializeData];
        
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
    [self freeData];
    [_context release];
    [_course release];
    [super dealloc];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_state == ST_GETTING_MEET_NAME) {
        _addedMeet = _amvc.name.text;
        [_addedMeet retain];
        [self EditTable:self];
    } else if (_state == ST_GETTING_RACE_TIME) {
        // store the race result
        // crumb
        NSArray* strokes = [[Swimming sharedInstance] getStrokes];
        RaceResultTeamManager* r = [[[RaceResultTeamManager alloc] initWithTime:_errvc.time.text
                                                                            meet:_meetToAddRaceTo 
                                                                            date:_dateToAddRaceTo
                                                                         stroke:[strokes objectAtIndex:_errvc.stroke]
                                                                        distance:_errvc.distance
                                                                          course:_course
                                                                             age:[TimeStandard ageAtDate:_amvc.date.date dob:self.athlete.birthdate]
                                                                     powerpoints:0
                                                                        standard:@""    // TODO
                                                                          splits:nil
                                                                              db:nil
                                      ] autorelease];
        [Swimmers storeRace:r forAthlete:self.athlete inContext:_context downloadSplits:NO];
        [self initializeData];
        [self.myTableView reloadData];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];

    self.navigationItem.rightBarButtonItem = addButton;
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
    if (self.editing) {
        return [_meets count] + 1;
    } else if (_addedMeet != nil) {
        return [_meets count] + 1;
    } else {
        return [_meets count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ((self.editing && section == 0)) {
        return 1;   // Just a row that lets the user add a new meet, or the newly added meet
    } else if (!self.editing && (_addedMeet != nil) && (section == 0)) {
        return 0;
    } else if (self.editing || _addedMeet != nil) {
        section--;
    }
    NSMutableArray* r = [_meets objectAtIndex:section];
    return (self.editing) ? [r count] + 1 : [r count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.editing && section == 0) {
        return _addedMeet == nil ? @"Add New Meet" : _addedMeet;
    } else if (!self.editing && (_addedMeet != nil) && (section == 0)) {
        return _addedMeet;
    } else {
        if (_addedMeet != nil || self.editing) {
            section--;  // we have a new meet in addition to the _meets list
        }
        NSMutableArray* races = [_meets objectAtIndex:section];
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
    int section = indexPath.section;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (self.editing && section == 0) {
        // In edit mode, the lat row in the section is 'Add race', not an actual result
        cell.detailTextLabel.text = _addedMeet == nil ? @"Add meet" : @"Add race";
        cell.textLabel.text = @"";
        return cell;
    } else if (self.editing || _addedMeet != nil) {
        section--;
    }
    
    RaceResult* race = nil;
    NSMutableArray* races = [_meets objectAtIndex:section];
    if (races != nil && !((self.editing) && (indexPath.row==[races count]))) {
        race = [races objectAtIndex:indexPath.row];
    }
    NSNumber* pb = nil;
    NSMutableArray* personalBests = [_personalbests objectAtIndex:section]; 
    if (personalBests != nil && !((self.editing) && (indexPath.row==[races count]))) {
        pb = [personalBests objectAtIndex:indexPath.row];
    } 
    //NSLog(@"Section %d %@",indexPath.section,[race shortenMeetName]);
    
    if (!((self.editing) && (indexPath.row==[races count]))) {
        NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *raceDateString = [dateFormatter stringFromDate:race.date];
        
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;

        // \u263A = unicode smiley face
        if ([race.powerpoints intValue] > 0) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@\n%@  (%d Points) %@", [race.distance intValue], race.stroke, race.time, [race.powerpoints intValue], [pb boolValue] ? @"\u263A" : @""];
        } else {
            // If this race was a personal best, add a smiley :)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@\n%@ %@", [race.distance intValue], race.stroke, race.time, [pb boolValue] ? @"\u263A" : @""];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", raceDateString];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    } else {
        // In edit mode, the lat row in the section is 'Add race', not an actual result
        cell.detailTextLabel.text = @"Add race";
        cell.textLabel.text = @"";
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


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         RaceResult* race = nil;
         NSMutableArray* races = [_meets objectAtIndex:indexPath.section-1];
         race = [races objectAtIndex:indexPath.row];  
         [_context deleteObject:race];
         NSError *error;
         // here's where the actual save happens, and if it doesn't we print something out to the console
         if (![_context save:&error])
         {
             NSLog(@"Problem saving: %@", [error localizedDescription]);
         } else {
             [self initializeData];
             NSLog(@"indexPath = %@",indexPath);
             [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         }
     }   
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         if ((indexPath.section == 0) && (_addedMeet == nil)) {
             _state = ST_GETTING_MEET_NAME;
             _amvc = [[AddMeetViewController alloc] initWithNibName:@"AddMeetViewController" bundle:[NSBundle mainBundle]];
             [self.navigationController pushViewController:_amvc animated:YES];
         } else {
             _state = ST_GETTING_RACE_TIME;
             _errvc = [[EnterRaceResultsiPhoneViewController alloc] initWithNibName:@"EnterRaceResultsiPhoneViewController" bundle:[NSBundle mainBundle]];
             [self.navigationController pushViewController:_errvc animated:YES];
             [_meetToAddRaceTo release];
             [_dateToAddRaceTo release];
             if (indexPath.section == 0) {  
                 _meetToAddRaceTo = _addedMeet;
                 _dateToAddRaceTo = _amvc.date.date;
             } else {
                 RaceResult* race = nil;
                 NSMutableArray* races = [_meets objectAtIndex:indexPath.section-1];
                 race = [races objectAtIndex:0];  // doesn't matter what race we grab, just need to get access to the meet property
                 _meetToAddRaceTo = race.meet;
                 _dateToAddRaceTo = race.date;
             }
             [_meetToAddRaceTo retain];
             [_dateToAddRaceTo retain];
         }

     }   
 }


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
    NSLog(@"SELECT>>>>> section: %d row: %d",indexPath.section,indexPath.row);
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // No editing style if not editing or the index path is nil.
    if (self.editing == NO || !indexPath) {
        return UITableViewCellEditingStyleNone;
    }

    int section = indexPath.section;
    if (self.editing && section == 0) {
        return UITableViewCellEditingStyleInsert;;
    } else if (self.editing) {
        section--;
    }
    
    NSMutableArray* races = [_meets objectAtIndex:section];

    // Determine the editing style based on whether the cell is a placeholder for adding content or already
    // existing content. Existing content can be deleted.
    if (self.editing && (indexPath.row == [races count])) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];              
    [self.myTableView setEditing:editing animated:animated];
}
    
- (IBAction) EditTable:(id)sender {
    UITableView* tableView = (UITableView*)[self myTableView];
    if (self.editing)
    {
        // ending edit mode
        NSString* title = @"Edit";
        [super setEditing:NO animated:NO];
        [tableView setEditing:NO animated:NO];
        [tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:title];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        // starting editing mode
        [super setEditing:YES animated:YES];
        [tableView setEditing:YES animated:YES];
        [tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
}

@end
