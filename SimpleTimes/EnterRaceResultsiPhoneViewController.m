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
        _dot_entered = FALSE;
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
    time.delegate = self;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"text.tag=%d text=%@ replacement: %@",textField.tag, textField.text,string);
    // TODO
    return YES;
    
    if (textField == time) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        // If user manually entered a decimal, don't auto-add characters
        if (_dot_entered == TRUE) {
            return YES;
        }
        
        // 87654321
        //  5:01.86
        //    27.64
        // 10.08.29
        if (newLength == 4) {
            NSRange dot = [string rangeOfString:@"." options:(NSCaseInsensitiveSearch)];
            if (dot.location == NSNotFound) {
                // Insert the "." into the time string
                NSMutableString *mu = [NSMutableString stringWithString:textField.text];
                [mu insertString:@"." atIndex:2];
                [mu appendString:string];
                textField.text = [NSString stringWithString:mu];
                return NO;
            }
        } 
    }
    return YES;
}

// Catch return key and dismiss keyboard
-(IBAction) userDoneEnteringText:(id)sender
{
    if (sender == time) {
        [time resignFirstResponder];
    }
}

@end
