//
//  DetailSwimmerViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 1/29/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "DetailSwimmerViewController.h"
#import "TopTimesViewController.h"
#import "TimeStandard.h"
#import "Swimmers.h"

@implementation DetailSwimmerViewController
@synthesize imageView;
@synthesize labelTitle;
@synthesize labelCuts;
@synthesize pageControl;

// load the view nib and initialize the pageNumber ivar
- (id)initWithAthlete:(AthleteCD*)athlete
{
    if (self = [super initWithNibName:@"DetailSwimmerView" bundle:nil])
    {
        _athlete = athlete;
        _topTimes = nil;
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
    [self.labelTitle setText:[NSString stringWithFormat:@"  Top Times for %@ %@", _athlete.firstname,_athlete.lastname]];
    
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
                                (int)(screenWidth-320)/3,
                                80,
                                320,
                                (int)(screenHeight - 160));
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //Add sub view for displaying top times
    _topTimes = [[TopTimesViewController alloc] init];
    [_topTimes setAthlete:_athlete];
    UITableView* tv = [[[UITableView alloc] initWithFrame:CGRectMake(5,80,320,640) style:UITableViewStylePlain] autorelease];
    tv.backgroundColor = [UIColor clearColor];
    _topTimes.view = tv;
    if (_athlete != nil) {
        [_topTimes setAthlete:_athlete];
        [_athlete countCuts:&_cuts];
        [self drawTitleForSwimmer];
        [self layoutTopTimes];
    }
    [tv setDataSource:_topTimes];
    [tv setDelegate:_topTimes];
	[self.view addSubview:tv];
    //[tv release];
    
    _swimmers = [[Swimmers alloc] init];
    [_swimmers loadWithContext:_moc];
    [pageControl setNumberOfPages:[_swimmers count]];
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

- (void) setAthlete:(AthleteCD *)a
{
    _athlete = a;
    [_topTimes setAthlete:a];
    [self drawTitleForSwimmer];
}

- (void) setMOC:(NSManagedObjectContext *)managedObjectContext
{
    _moc = managedObjectContext; 
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;    
}

- (void)dealloc {
    [imageView release];
    [super dealloc];
}
@end
