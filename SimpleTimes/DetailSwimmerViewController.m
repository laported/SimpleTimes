//
//  DetailSwimmerViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 1/29/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailSwimmerViewController.h"
#import "TopTimesViewController.h"
#import "TimeStandard.h"
#import "SVProgressHUD.h"
#import "DownloadTimesMI.h"

@implementation DetailSwimmerViewController
@synthesize imageView;
@synthesize labelTitle;
@synthesize labelCuts;
@synthesize swimmerPicker = _swimmerPicker;
@synthesize swimmerPickerPopover = _swimmerPickerPopover;

// load the view nib and initialize the pageNumber ivar
- (id)initWithAthlete:(AthleteCD*)athlete andContext:(NSManagedObjectContext*)moc
{
    if (self = [super initWithNibName:@"DetailSwimmerViewController" bundle:nil])
    {
        _athlete = athlete;
        _topTimes = nil;
        _moc = moc;
        self.tabBarItem.image = [UIImage imageNamed:@"star_24"];
        self.title = NSLocalizedString(@"Top Times", @"Top Times");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

- (void) drawTitleForSwimmer
{    
    [self.labelTitle setText:[NSString stringWithFormat:@"%@\n%@", _athlete.firstname,_athlete.lastname]];
    self.labelTitle.layer.cornerRadius = 15.0;
    
    if (_cuts.jos > 0 || _cuts.states > 0 || _cuts.sectionals > 0 || _cuts.nationals > 0) {
        NSString* jos = _cuts.jos > 0 ? [self cutsWithStars:_cuts.jos andPrefix:@"JO "] : @"";
        NSString* states = _cuts.states > 0 ? [self cutsWithStars:_cuts.states andPrefix:@"ST "] : @"";
        NSString* sectionals = _cuts.sectionals > 0 ? [self cutsWithStars:_cuts.sectionals andPrefix:@"SE "] : @"";
        NSString* nationals = _cuts.nationals > 0 ? [self cutsWithStars:_cuts.nationals andPrefix:@"NA "] : @"";
        [self.labelCuts setText:[NSString stringWithFormat:@"%@ %@ %@ %@",nationals,sectionals,states,jos]];
    } else {
        [self.labelCuts setText:@""];
    }
}

- (void) layoutTopTimes
{
    BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = isPortrait ? screenRect.size.width : screenRect.size.height;
    CGFloat screenHeight = isPortrait ? screenRect.size.height : screenRect.size.width;
    _topTimes.view.frame = CGRectMake(
                                50,
                                275,
                                320,
                                (int)(screenHeight - 275-100));
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //Add sub view for displaying top times
    _topTimes = [[TopTimesViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.view addSubview:_topTimes.view];
    if (_athlete != nil) {
        [_topTimes setAthlete:_athlete];
        [_athlete countCuts:&_cuts];
        [self drawTitleForSwimmer];
        [self layoutTopTimes];
    }
    
    UIToolbar* tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,768,44)];
    tb.barStyle = UIBarStyleDefault;
    UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload_v2.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(refreshPressed:)];  
    UIBarButtonItem* bi2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"man_24.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(pickerPressed:)];  
    
    //Add buttons to the array
    NSArray *items = [NSArray arrayWithObjects: bi, bi2, nil];
    [tb setItems:items];
    [self.view addSubview:tb];

    //[tv release];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self layoutTopTimes];
}

/* 
 * timesDownloaded
 *
 * Invoked asynchronously when the user selects the 'Refresh' button 
 */
- (void)timesDownloaded:(NSArray*)times
{
    int numadded;
    
    // Updating results for single swimmer
    numadded = [Swimmers updateAllRaceResultsForAthlete:_athlete withResults:times inContext:_moc];
    
    [_queue release];
    
    NSTimeInterval nsti = 3.5;
    if (numadded > 0) {
        [_topTimes reloadData];
        NSString* msg = [NSString stringWithFormat:@"Added %d new race times",numadded];
        [SVProgressHUD dismissWithSuccess:msg afterDelay:nsti];
    } else {
        [SVProgressHUD dismissWithSuccess:@"No new race times found" afterDelay:nsti];
    }
}

- (void)swimmerSelected:(AthleteCD *)a {
    /* TODO if ([color compare:@"Red"] == NSOrderedSame) {
        _nameLabel.textColor = [UIColor redColor];
    } else if ([color compare:@"Green"] == NSOrderedSame) {
        _nameLabel.textColor = [UIColor greenColor];
    } else if ([color compare:@"Blue"] == NSOrderedSame){
        _nameLabel.textColor = [UIColor blueColor];
    }*/
    [_athlete release];
    _athlete = a;
    [_topTimes setAthlete:_athlete];
    [_athlete countCuts:&_cuts];
    [self drawTitleForSwimmer];
    
    [self.swimmerPickerPopover dismissPopoverAnimated:YES];
}

- (IBAction)pickerPressed:(id)sender
{
    if (_swimmerPicker == nil) {
        //self.swimmerPicker = [[[SwimmerPickerController alloc] 
                             //initWithStyle:UITableViewStylePlain] autorelease];
        self.swimmerPicker = [[SwimmerPickerController alloc] initWithNSManagedObjectContext:_moc];
        _swimmerPicker.delegate = self;
        self.swimmerPickerPopover = [[[UIPopoverController alloc] 
                                    initWithContentViewController:_swimmerPicker] autorelease];               
    }
    [self.swimmerPickerPopover presentPopoverFromBarButtonItem:sender 
                                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}

- (IBAction)refreshPressed:(id)sender
{
    NSLog(@"Refresh pressed");
    _queue = [[NSOperationQueue alloc] init];
    
    [SVProgressHUD showWithStatus:@"Checking for updated times"];
    
    // download all times and populate the database
    DownloadTimesMI* dtm = [[DownloadTimesMI alloc] initWithAthlete:_athlete:self];
    [_queue addOperation:dtm];
    [dtm release];
}

- (void)dealloc {
    [super dealloc];
    [imageView release];
    self.swimmerPicker = nil;
    self.swimmerPickerPopover = nil;
}
@end
