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

@implementation RootViewController

@synthesize allTimes = _allTimes;
@synthesize athletes = _athletes;
@synthesize queue = _queue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"Times";
    //self.allTimes = [NSMutableArray array];
    //[self addRows];  
    
    selectedAthlete = 0;
    
    self.title = @"Times";
    self.allTimes = [NSMutableArray array];
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    self.athletes = [NSArray arrayWithObjects:@"11655",  // benjamin
                                              //@"11657",  // matthew
                                              //@"11656",  // kelly
                                              nil];    
    [self refresh];    
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
    return [_allTimes count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    RaceResult *race = [_allTimes objectAtIndex:indexPath.row];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *raceDateString = [dateFormatter stringFromDate:race.date];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d %@ - %@", race.distance, race.stroke, race.time];       
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", raceDateString, race.meet];
    
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
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

- (void)addRows {  
    /*
    RaceResult *race1 = [[[RaceResult alloc] initWithTime:34.54 
                                                    meet:@"DCAC Red White & Blue" 
                                                    date:[NSDate date]
                                                  stroke:@"Fly"
                                                distance:50
                                             shortcourse:YES] autorelease];
    
    RaceResult *race2 = [[[RaceResult alloc] initWithTime:224.58 
                                                     meet:@"DCAC Red White & Blue" 
                                                     date:[NSDate date]
                                                   stroke:@"Freestyle"
                                                 distance:200
                                              shortcourse:YES] autorelease];
    
    RaceResult *race3 = [[[RaceResult alloc] initWithTime:624.00 
                                                     meet:@"DCAC Red White & Blue" 
                                                     date:[NSDate date]
                                                   stroke:@"Freestyle"
                                                 distance:500
                                              shortcourse:YES] autorelease];

    [_allTimes insertObject:race1 atIndex:0];
    [_allTimes insertObject:race2 atIndex:0];
    [_allTimes insertObject:race3 atIndex:0];    
     */
}

// Add new method
- (void)refresh {
    MISwimDBProxy* proxy = [[[MISwimDBProxy alloc] init] autorelease];
    
    for (NSString *athlete in _athletes) {
        
        NSArray* times = [proxy getAllTimesForAthlete:(int)[athlete intValue]];
        
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
    [_queue release];
    _queue = nil;
    [_athletes release];
    _athletes = nil;
}

@end
