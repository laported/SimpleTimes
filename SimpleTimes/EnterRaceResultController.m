//
//  EnterRaceResultController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/1/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "EnterRaceResultController.h"

@implementation EnterRaceResultController
@synthesize distancePicker;
@synthesize strokePicker;
@synthesize datePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _swimming = [Swimming sharedInstance];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView 
{    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return thePickerView.tag == 0 ? [_swimming.distances count] : [_swimming.strokes count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return thePickerView.tag == 0 ? [_swimming.distances objectAtIndex:row] : [_swimming.strokes objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (thePickerView.tag == 0) {
        NSLog(@"Selected distance: %@. Index of selected color: %i",
          [_swimming.distances objectAtIndex:row], row);
    } else {
        NSLog(@"Selected stroke: %@. Index of selected color: %i",
              [_swimming.strokes objectAtIndex:row], row);
    }
}
@end
