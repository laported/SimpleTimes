//
//  DetailSwimmerViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 1/29/12.
//  Copyright (c) 2012 Burroughs. All rights reserved.
//

#import "DetailSwimmerViewController.h"
#import "TopTimesViewController.h"
#import "TimeStandard.h"
#import "Swimmers.h"

@implementation DetailSwimmerViewController
@synthesize imageView;
@synthesize labelTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _athlete = nil;
        _topTimes = nil;
        self.tabBarItem.image = [UIImage imageNamed:@"star_24"];
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
    // Do any additional setup after loading the view from its nib.
    UIImage *underWaterImage = [UIImage imageNamed:@"UnderWater.png"];
    self.imageView.image = underWaterImage;
    
    //Add sub view for displaying top times
    _topTimes = [[TopTimesViewController alloc] init];
    UITableView* tv = [[[UITableView alloc] initWithFrame:CGRectMake(5,60,320,480) style:UITableViewStylePlain] autorelease];
    tv.backgroundColor = [UIColor clearColor];
    _topTimes.view = tv;
    [tv setDataSource:_topTimes];
    [tv setDelegate:_topTimes];
	[self.view addSubview:tv];
    //[tv release];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
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

- (void) setAthlete:(AthleteCD *)a
{
    _athlete = a;
    [_topTimes setAthlete:a];
    [self.labelTitle setText:[NSString stringWithFormat:@"  Top Times for %@ %@", a.firstname,a.lastname]];
}

- (void)dealloc {
    [imageView release];
    [super dealloc];
}
@end
