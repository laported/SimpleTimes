//
//  GetBirthdayViewController.m
//  SimpleTimes
//
//  Created by David LaPorte on 1/21/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "GetBirthdayViewController.h"

@implementation GetBirthdayViewController

@synthesize textMM,textDD,textYYYY,buttonOK,buttonCancel;
@synthesize selectedDate = _selectedDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        textMM.keyboardType = UIKeyboardTypeDecimalPad;
        textDD.keyboardType = UIKeyboardTypeDecimalPad;
        textYYYY.keyboardType = UIKeyboardTypeDecimalPad;
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

- (IBAction)onOK:(id)sender 
{
    NSString* datestr = [NSString stringWithFormat:@"%@-%@-%@",[textMM text], [textDD text], [textYYYY text]];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
    self.selectedDate = [df dateFromString:datestr];
    [df release];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCancel:(id)sender 
{
    // Make them old enough to be in the Open category
    NSString* datestr = [NSString stringWithFormat:@"%@-%@-%@",@"01", @"01", @"1900"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
    self.selectedDate = [df dateFromString:datestr];
    [df release];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
