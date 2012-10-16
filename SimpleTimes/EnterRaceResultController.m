//
//  EnterRaceResultController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/1/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "EnterRaceResultController.h"
#import "TimeStandard.h"

@implementation EnterRaceResultController
@synthesize distancePicker;
@synthesize strokePicker;
@synthesize datePicker;
@synthesize meet;
@synthesize projectedFinish;
@synthesize joCutTime;

// tags for the two picker views
#define TAG_DISTANCE 0
#define TAG_STROKE   1

- (id)initWithAthlete:(AthleteCD*)athlete andContext:(NSManagedObjectContext*)moc
{
    if (self = [super initWithNibName:@"EnterRaceResultController" bundle:nil])
    {
        _athlete = athlete;
        _moc = moc;
        _swimming = [Swimming sharedInstance];
        self.tabBarItem.image = [UIImage imageNamed:@"plus_24"];
        self.title = NSLocalizedString(@"Enter Times", @"Enter Times");
        _stroke_index = 1;
        joCutTime.text = (_athlete == nil) ? @"???" : [TimeStandard getJoCutWithAge:_athlete.birthdate distance:25 stroke:1 gender:_athlete.gender];
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
    [meet setText:@"MISCA"];
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

- (void) insertTextFieldAtPoint:(CGPoint)point withTag:(int)tag andLabel:(NSString*)labelText
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(point.x,point.y,40,25)];
    [label setText:labelText];
    label.tag = tag+1;
    [self.view addSubview:label];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(point.x,point.y+30,55,35)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:15];
    textField.placeholder = @"30.00";
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    textField.delegate = self;
    textField.tag = tag;
    [self.view addSubview:textField];
    [textField release];
}

- (void) moveToNextSplit:(UITextField*) textField
{
    [textField resignFirstResponder];
    int nexttag = textField.tag + 50;
    // If this is not the last split field, move to the next one
    if (nexttag <= _distance) {
        UITextField* nextField;
        UIView* view;
        while ((view = [self.view viewWithTag:nexttag]) != nil) {
            if ( [view isKindOfClass: [UITextField class]] == YES ) {
                nextField = (UITextField*) view;
                [nextField becomeFirstResponder];
                break;
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSLog(@"text.tag=%d text=%@",textField.tag, textField.text);
    
    NSRange colon = [textField.text rangeOfString:@":" options:(NSCaseInsensitiveSearch)];
    if (colon.location == NSNotFound) {
        // Insert the ":" into the time string
        NSMutableString *mu = [NSMutableString stringWithString:textField.text];
        [mu insertString:@":" atIndex:2];
        textField.text = [NSString stringWithString:mu];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"text.tag=%d text=%@ replacement: %@",textField.tag, textField.text,string);
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength == 4) {
        NSRange colon = [string rangeOfString:@"." options:(NSCaseInsensitiveSearch)];
        if (colon.location == NSNotFound) {
            // Insert the "." into the time string
            NSMutableString *mu = [NSMutableString stringWithString:textField.text];
            [mu insertString:@"." atIndex:2];
            [mu appendString:string];
            textField.text = [NSString stringWithString:mu];
            [self moveToNextSplit:textField];
            return NO;
        }
    }
    return YES;
    // TODO: jump to the next text field when 4 chars entered
    // (Make textField with tag+50 the new first responder)
}

- (void) layout_splits:(int)distance
{
    int x = 15;
    int y = joCutTime.frame.origin.y + 30;
    UIView* removeView;
    
    // clear out any current controls
    for (int t=50;t<=1650;t+=50) {
        while((removeView = [self.view viewWithTag:t]) != nil) {
            [removeView removeFromSuperview];
        }
        while((removeView = [self.view viewWithTag:(t+1)]) != nil) {
            [removeView removeFromSuperview];
        }
    }
    // now layout the new ones based one the newly slected distance
    for (int i=0;i<distance;i+=50) {
        CGPoint p;
        p.x = x + 70 * ((i/50) % 10);
        p.y = y + 80 * ((i/50) / 10);
        [self insertTextFieldAtPoint:p withTag:(i+50) andLabel:[NSString stringWithFormat:@"%d",i+50]];
    }
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (thePickerView.tag == TAG_DISTANCE) {
        // need to update the layout for the splits entries??
        if (_distance_index != row) {
            NSString* sdist = [_swimming.distances objectAtIndex:row];
            _distance = [sdist intValue];
            _distance_index = row;
            if (_distance >= 100) {
                [self layout_splits:_distance];
            }
        }
        NSLog(@"Selected distance: %@. Index of selected stroke: %i",
              [_swimming.distances objectAtIndex:row], row);
    } else if (thePickerView.tag == TAG_STROKE) {
        _stroke_index = row;
        NSLog(@"Selected stroke: %@. Index of selected stroke: %i",
              [_swimming.strokes objectAtIndex:row], row);
    } else {
        assert( false );    // Must have added somehting to the .XIB file w/o adding code here
    }
    joCutTime.text = [TimeStandard getJoCutWithAge:_athlete.birthdate distance:_distance stroke:_stroke_index gender:_athlete.gender];
}

- (IBAction)savePressed:(id)sender
{
    NSLog(@"TODO: Save data");
}
@end
