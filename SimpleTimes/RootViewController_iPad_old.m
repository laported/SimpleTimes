//
//  RootViewController_iPad.m
//  SimpleTimes
//
//  Created by David LaPorte on 1/30/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "RootViewController_iPad_old.h"
#import "AddSwimmerViewController.h"
#import "SVProgressHUD.h"
#import "DownloadTimesMI.h"

@implementation RootViewController_iPad_old

@synthesize detailSwimmerViewController;
@synthesize managedObjectContext;
@synthesize theSwimmers;
@synthesize selectedRow;
@synthesize asViewController;
@synthesize getbdayController;
@synthesize queue;

// VIEWSTATEs
#define VS_ATHLETES     1
#define VS_ADDSWIMMER   2
#define VS_GETBIRTHDATE 3

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _viewstate = VS_ATHLETES;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    assert( self.managedObjectContext != nil );
    
    self.title = @"Swimmers";
    self.theSwimmers = [[Swimmers alloc] init];
    [self.theSwimmers loadWithContext:self.managedObjectContext];  
    
    for (int i=0;i<[self.theSwimmers count];i++) {
        int insertIdx = 0; 
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
    self.selectedRow = 0;
    if ([self.theSwimmers count] > 0) {
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
    }
    //self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    if (_viewstate == VS_ATHLETES) {
        // adding results for new swimmer
        numadded = [Swimmers updateAllRaceResultsForAthlete:_addedAthleteCD withResults:times inContext:self.managedObjectContext];
    } else {
        // Updating results for single swimmer
        NSIndexPath* path = [self.tableView indexPathForSelectedRow];
        numadded = [Swimmers updateAllRaceResultsForAthlete:[self.theSwimmers.athletesCD objectAtIndex:path.row] withResults:times inContext:self.managedObjectContext];
    }
    [self.tableView reloadData];
    [self.queue release];
    
    NSTimeInterval nsti = 3.5;
    if (numadded > 0) {
        NSString* msg = [NSString stringWithFormat:@"Added %d new race times",numadded];
        [SVProgressHUD dismissWithSuccess:msg afterDelay:nsti];
    } else {
        [SVProgressHUD dismissWithSuccess:@"No new race times found" afterDelay:nsti];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /* Are we coming back from the 'Add Swimmer' dialog ? */
    if (_viewstate == VS_ADDSWIMMER) {
        
        // Did the user pick a swimmer??
        if (self.asViewController.madeSelection) {
            // Do we have a birthdate? (MI Swim provider does not supply it)
            if (self.asViewController.birthdate == NULL) {
                _viewstate = VS_GETBIRTHDATE;
                // Do we have a birthdate?
                // Push a new view controller for birthdate selection here
                self.getbdayController = [[GetBirthdayViewController alloc] initWithNibName:@"GetBirthdayViewController" bundle:[NSBundle mainBundle]];
                [self.navigationController pushViewController:self.getbdayController animated:YES];
            } else {
                assert( false );    // TODO: Recode if we support other data providers
            }
        } else {
            // nothing selected
            _viewstate = VS_ATHLETES;
        }
        
    } else if (_viewstate == VS_GETBIRTHDATE) {
        _viewstate = VS_ATHLETES;
        NSLog(@"firstname: %@ lastname: %@ miID:%d",self.asViewController.firstname.text,self.asViewController.lastname.text,self.asViewController.miSwimId);
        // 1. Add swimmer name to list of athletes
        // 2. Lookup swimmer online
        // 3. Download times        
        AthleteCD *ath1 = [NSEntityDescription
                           insertNewObjectForEntityForName:@"AthleteCD" 
                           inManagedObjectContext:self.managedObjectContext];
        ath1.firstname = self.asViewController.firstname.text;
        ath1.lastname = self.asViewController.lastname.text;
        ath1.club = self.asViewController.club; 
        ath1.birthdate = self.getbdayController.selectedDate;
        ath1.miswimid = [[NSNumber alloc] initWithInt:self.asViewController.miSwimId];
        ath1.gender = self.asViewController.gender;
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
        
        self.queue = [[NSOperationQueue alloc] init];
        
        // download all times into the database for the new swimmer
        DownloadTimesMI* dtm = [[DownloadTimesMI alloc] initWithAthlete:ath1:self];
        [self.queue addOperation:dtm];
        [dtm release];
        
    } else {
        if ([self.theSwimmers count] > 0) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [self.theSwimmers count];
    if(self.editing) { 
        rows++;
        NSLog(@"Editing=true, numRows: %d",rows);
    }
    return rows;
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

-(NSString*) shortenMeetName:(NSString*)longname
{
    NSString* shortname;
    if ([longname hasPrefix:@"201"] || [longname hasPrefix:@"200"]) {
        shortname = [longname substringWithRange:NSMakeRange(5, [longname length]-5)];
    } else {
        shortname = longname;
    }
    return shortname;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AthleteCD* athlete;
    CUTS cuts;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Are we in edit mode????
    if (self.editing && (indexPath.row == [self.theSwimmers count])) {
        cell.textLabel.text = @"Add new swimmer";
        cell.detailTextLabel.text = @"";
        return cell;
    } else {
        athlete = [self.theSwimmers.athletesCD objectAtIndex:indexPath.row];
        [athlete countCuts:&cuts];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",athlete.firstname, athlete.lastname];    
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
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.backgroundColor = [UIColor clearColor];
        //cell.contentView.backgroundColor = [UIColor clearColor];
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
        _viewstate = VS_ADDSWIMMER;
        self.asViewController = [[AddSwimmerViewController alloc] initWithNibName:@"AddSwimmerViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:self.asViewController animated:YES];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [detailSwimmerViewController setAthlete:[self.theSwimmers.athletesCD objectAtIndex:indexPath.row]];

}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // No editing style if not editing or the index path is nil.
    if (self.editing == NO || !indexPath) return UITableViewCellEditingStyleNone;
    // Determine the editing style based on whether the cell is a placeholder for adding content or already
    // existing content. Existing content can be deleted.
    if (self.editing && indexPath.row == [self.theSwimmers count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (IBAction) EditTable:(id)sender {
    UITableView* tableView = (UITableView*)[self view];
    if(self.editing)    // are we coming FROM the editing state???
    {
        NSString* title = [self.theSwimmers count] == 0 ? @"Add Swimmer" : @"Edit";
        [super setEditing:NO animated:NO];
        [tableView setEditing:NO animated:NO];
        [tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:title];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [tableView setEditing:YES animated:YES];
        [tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
}

@end
