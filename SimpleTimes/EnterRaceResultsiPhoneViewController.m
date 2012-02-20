//
//  EnterRaceResultsiPhoneViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/19/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "EnterRaceResultsiPhoneViewController.h"
#import "Swimming.h"

@implementation EnterRaceResultsiPhoneViewController

@synthesize pickerView;
@synthesize time;
@synthesize distance;
@synthesize stroke;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIPickerViewDataSource protocol methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;   // Distance & Stroke
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    Swimming* swimming = [Swimming sharedInstance];
    return component == 0 ? [swimming.distances count] : [swimming.strokes count];
}

#pragma mark - UIPickerViewDelegate protocol methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Swimming* swimming = [Swimming sharedInstance];
    return component == 0 ? [swimming.distances objectAtIndex:row] : [swimming.strokes objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    Swimming* swimming = [Swimming sharedInstance];
    if (component == 0) {
        self.distance = [[swimming.distances objectAtIndex:row] intValue];
        NSLog(@"Distance: %d",self.distance);
    } else { 
        self.stroke = row;
        NSLog(@"Stroke: %d",self.stroke);
    }
}

@end
