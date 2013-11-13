//
//  AllTimesViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/4/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "AllTimesViewController.h"
#import "RaceResult.h"
#import "TimeStandard.h"
#import "Swimmers.h"

@implementation AllTimesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.image = [UIImage imageNamed:@"clock_24"];
        self.title = NSLocalizedString(@"All Times", @"All Times");
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
	return YES;
}

- (UILabel *)stringLabel:(NSString*)withText {
    UILabel* stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    stringLabel.textColor = [UIColor whiteColor];
    stringLabel.backgroundColor = [UIColor clearColor];
    stringLabel.adjustsFontSizeToFitWidth = YES;
    stringLabel.textAlignment = UITextAlignmentLeft;
    stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    stringLabel.font = [UIFont boldSystemFontOfSize:16];
    stringLabel.shadowColor = [UIColor blackColor];
    stringLabel.shadowOffset = CGSizeMake(0, -1);
    stringLabel.numberOfLines = 0;
    [stringLabel setText:withText];
    return stringLabel;
}

- (void) layoutData
{
    //int row = 0;
    //int col = 0;
    
    // TODO: release label array data if not ni
    _labels = [[NSMutableArray alloc] init];
    for (RaceResult* race in _races) {
        NSString* text = [NSString stringWithFormat:@"%@ %@ %@ %@",race.date, race.distance, race.stroke, race.time];
        UILabel* label = [self stringLabel:text];
        [_labels addObject:label];
    }
}

- (void) setAthlete:(AthleteCD *)a
{
    _athlete = a;
    [_races release];
    _races = [[_athlete allResults] retain]; 
    [self layoutData];
}

@end
