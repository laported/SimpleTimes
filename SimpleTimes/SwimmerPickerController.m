//
//  SwimmerPickerController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/10/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import "SwimmerPickerController.h"
#import "Swimmers.h"

@implementation SwimmerPickerController

@synthesize delegate = _delegate;

- (id)initWithNSManagedObjectContext:(NSManagedObjectContext*)moc
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _moc = moc;
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
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    _swimmer_list = [NSMutableArray array];
    Swimmers* sw = [[Swimmers alloc] init];
    [sw loadWithContext:_moc]; 
    for (AthleteCD* a in sw.athletesCD) {
        [_swimmer_list addObject:a];
    }
    [_swimmer_list retain];

    self.contentSizeForViewInPopover = CGSizeMake(240.0, 40*([_swimmer_list count]+1));
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_swimmer_list release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_swimmer_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    AthleteCD* a = [_swimmer_list objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", a.firstname, a.lastname];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate != nil) {
        AthleteCD *a = [_swimmer_list objectAtIndex:indexPath.row];
        [_delegate swimmerSelected:a];
    }
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
