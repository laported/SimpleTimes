//
//  SplitsViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/24/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "SplitsViewController.h"
#import "SplitCD.h"
#import "Swimming.h"

@implementation SplitsViewController

@synthesize myTableView;
@synthesize race;

- (id) initWithRace:(RaceResult*)r andContext:(NSManagedObjectContext*)context
{
    CGRect viewBounds = [[ UIScreen mainScreen ] applicationFrame ];
    viewBounds.origin.y = 0.0;
    self = [super init]; 
    
    if (self) {
        self.race = r; 
        
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

- (void) freeData
{
    for (NSMutableArray* a in _splits) {
        [a release];
    }
    [_splits release];
    _splits = nil;
    [_addedSplit release];
    _addedSplit = nil;
}

- (void) initializeData
{    
    [self freeData];
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
    // Do any additional setup after loading the view from its nib.
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* s = [_splits objectAtIndex:section];
    return (self.editing) ? [s count] + 1 : [s count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //int section = indexPath.section;
    Swimming* swimming = [Swimming sharedInstance];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (self.editing) {
        /* TODO */
        return cell;
    } 
    
    SplitCD* split = [_splits objectAtIndex:indexPath.row];
    if (split != nil) {
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];  
        //NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        int splitDistance = (indexPath.row+1)*([self.race.distance intValue]/[_splits count]);
        int raceDistance = [race.distance intValue];
        /* Is this an IM???? */
        if ([self.race.stroke isEqualToString:@"IM"]) {
            // IM: Add the current stroke for this split
            int stroke_index = (splitDistance-1)/(raceDistance/4);
            assert( stroke_index < 4 );
            NSString* stroke = [[swimming getStrokes] objectAtIndex:stroke_index];
            //NSLog(@"%d, %d, %@, %@",[splits count],indexPath.row,stroke,split);
            cell.textLabel.text = [NSString stringWithFormat:@"%d : %@  (%@)", (indexPath.row+1)*(raceDistance/[_splits count]), split.cumulative, stroke]; 
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%d : %@", splitDistance, split.cumulative];
        }
        // If these are 25 splits, combine into 50s as well
        if ((raceDistance / 25 == [race.splits count]) && (indexPath.row % 2)) {
            NSUInteger lastrow = indexPath.row-1;
            
            SplitCD* lastSplit = [_splits objectAtIndex:lastrow];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%3.2f)", split.time, [split.time floatValue] + [lastSplit.time floatValue]]; 
        } else {
            cell.detailTextLabel.text = split.time;
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        /* TODO
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
         ******/
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        /********** TODO
        if ((indexPath.section == 0) && (_addedMeet == nil)) {
            _state = ST_GETTING_MEET_NAME;
            _amvc = [[AddMeetViewController alloc] initWithNibName:@"AddMeetViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:_amvc animated:YES];
        } else {
            NSLog(@"TODO: INSERT Here");
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
        ***********/
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
    /******** TODO
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
     ***********/
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
