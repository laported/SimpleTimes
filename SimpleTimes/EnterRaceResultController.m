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
@synthesize meet;

// tags for the two picker views
#define TAG_DISTANCE 0
#define TAG_STROKE   1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _swimming = [Swimming sharedInstance];
        self.tabBarItem.image = [UIImage imageNamed:@"plus_24"];
        self.title = NSLocalizedString(@"Enter Times", @"Enter Times");
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
    _distance_index = 0;
    _stroke_index = 0;

    NSLog(@"%@",datePicker.frame);
    // Do any additional setup after loading the view from its nib.
    for (UIView* subview in strokePicker.subviews) {
        subview.frame = strokePicker.bounds;
    }
    for (UIView* subview in distancePicker.subviews) {
        subview.frame = distancePicker.bounds;
    }
    // hack
    [meet setText:@"DRD Groundhog Splash"];
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
    if (thePickerView.tag == TAG_DISTANCE) {
        // need to update the layout for the splits entries??
        if (_distance_index != row) {
            NSString* sdist = [_swimming.distances objectAtIndex:row];
            int distance = [sdist intValue];
            _distance_index = row;
            if (distance >= 100) {
                // todo [self layout_splits];
            }
        }
        NSLog(@"Selected distance: %@. Index of selected stroke: %i",
          [_swimming.distances objectAtIndex:row], row);
    } else if (thePickerView.tag == TAG_STROKE) {
        NSLog(@"Selected stroke: %@. Index of selected stroke: %i",
              [_swimming.strokes objectAtIndex:row], row);
    } else {
        assert( false );    // Must have added somehting to the .XIB file w/o adding code here
    }
}
@end
