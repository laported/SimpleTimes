//
//  AddSwimmerViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/25/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import "AddSwimmerViewController.h"
#import "TeamManagerDBProxy.h"

@implementation AddSwimmerViewController

@synthesize firstname, 
            lastname, 
            addbutton, 
            selectedLastName, 
            progressIndicator, 
            status, 
            athletes;
@synthesize miSwimId      = _miSwimId;
@synthesize gender        = _gender;
@synthesize club          = _club;
@synthesize birthdate     = _birthdate; 
@synthesize madeSelection = _madeSelection;
@synthesize database      = _database;

- (id) initWithDatabaseName:(NSString*)database 
{
    self = [super initWithNibName:@"AddSwimmerViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        _multipleResults = nil;
        _madeSelection = false;
        self.database = database;
    }
    return self;
}

- (void) setPropertiesFromSwimmer:(AddSwimmerResult*)swimmer 
{
    self.firstname.text = swimmer.first;
    self.lastname.text = swimmer.last;
    self.miSwimId = [swimmer.miId intValue];
    self.gender = swimmer.gender;
    self.club = swimmer.clubshort;
    self.birthdate = NULL;  // TODO
}

- (IBAction)addButtonSelected:(id)sender {
    NSArray* array = [NSMutableArray array];
    NSLog(@"Add button pressed. firstname: %@ lastname: %@",firstname.text,lastname.text);
    // enable the progress UIs
    self.status.text = @"Searching...";
    [self.progressIndicator setHidden:NO];
    [self.status setHidden:NO];
    TeamManagerDBProxy* proxy = [[[TeamManagerDBProxy alloc] initWithDBName:_database] autorelease];
    array = [proxy findAthlete:lastname.text:firstname.text];
    if ([array count] == 1) {
        for (AddSwimmerResult* s in array) { 
            //[self setPropertiesFromSwimmer:s];
            self.firstname.text = s.first;
            self.lastname.text = s.last;
            self.miSwimId = [s.miId intValue];
            self.gender = s.gender;
            self.club = s.clubshort;
        }
        _madeSelection = true;
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([array count] > 1) {
        // dismiss the keyboard
        if([self.firstname isFirstResponder]){
            [self.firstname resignFirstResponder];
        }
        
        if([self.lastname isFirstResponder]){
            [self.lastname resignFirstResponder];
        }
        // populate the treeview
        _multipleResults = [NSMutableArray array];
        for (AddSwimmerResult* s in array) {
            int insertIdx = 0; 
            NSLog(@"first: %@ last: %@ miID:%@",s.first,s.last,s.miId);
            [_multipleResults insertObject:s atIndex:insertIdx];
            [self.athletes insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        }    
        [_multipleResults retain];
        self.status.text = @"Select name:";
        [self.progressIndicator setHidden:YES];
    } else {
        // no results found
        self.status.text = @"Not found. Select another name:";
    }
}

- (void)dealloc
{
    [selectedLastName release];
    [addbutton release];
    [status release];
    [progressIndicator release];
    [athletes release];
    [_database release];
    if (_multipleResults != nil)
        [_multipleResults release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_multipleResults count]; 
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
 //   RaceResult *race;
   // AthleteCD* athlete;
   // Split *split;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    AddSwimmerResult* swimmer = [_multipleResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",swimmer.first, swimmer.last];       
    cell.detailTextLabel.text = swimmer.clublong; 
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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
    AddSwimmerResult* swimmer = [_multipleResults objectAtIndex:indexPath.row];

    // TODO: This is crashing w/unknown selector
    // [self setpropertiesFromSwimmer:swimmer];
    
    self.firstname.text = swimmer.first;
    self.lastname.text = swimmer.last;
    self.miSwimId = [swimmer.miId intValue];
    self.gender = swimmer.gender;
    self.club = swimmer.clubshort;
    self.madeSelection = true;
    
    // dismiss this view
    [self.navigationController popViewControllerAnimated:YES];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [status setAlpha:1.00];
    [self.progressIndicator setHidden:YES];
    [self.status setHidden:YES];
}

- (void)viewDidUnload
{
    [addbutton release];
    addbutton = nil;
    [status release];
    status = nil;
    [progressIndicator release];
    progressIndicator = nil;
    [athletes release];
    athletes = nil;
    [_gender release];
    _gender = nil;
    [_club release];
    _club = nil;
    [_database release];
    _database = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
