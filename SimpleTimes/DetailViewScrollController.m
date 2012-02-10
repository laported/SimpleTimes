//
//  DetailViewScrollController.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/4/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import "DetailViewScrollController.h"
#import "DetailSwimmerViewController.h"
#import "Swimmers.h"

@implementation DetailViewScrollController

@synthesize scrollView;
@synthesize pageControl;
@synthesize viewControllers, theSwimmers;

- (id)initWithNSManagedObjectContext:(NSManagedObjectContext*)moc
{
    if (self = [super initWithNibName:@"DetailViewScrollController" bundle:nil])
    {
        self.theSwimmers = [[Swimmers alloc] init];
        [self.theSwimmers loadWithContext:moc];
        self.title = NSLocalizedString(@"Top Times", @"Top Times");
        self.tabBarItem.image = [UIImage imageNamed:@"star_24"];
        initialized = NO;
    }
    return self;
}

- (UIView *)view
{
    return self.scrollView;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*- (void)viewDidLoad
{
    [super viewDidLoad];
    int kNumberOfPages = [self.theSwimmers count];
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadDetailViewPage:0];
    [self loadDetailViewPage:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self setupPage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!initialized) {
        [self setupPage];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
*/
#pragma mark -
#pragma mark The Guts
- (void)setupPage
{
	NSUInteger npages = 4;
	
	[self.scrollView setBackgroundColor:[UIColor blackColor]];
	[scrollView setCanCancelContentTouches:NO];
	
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
	CGFloat cx = 0;
	for (NSUInteger i=0; i<npages; i++) {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(cx,0,768,900 /* TODO subtract tabbar height instead of hardcoding value */)];
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cx+50,250,100,50)];
        [label setText:[NSString stringWithFormat:@"Page %d",i]];
        [label setTextColor: [UIColor blackColor]];
        [view addSubview:label];
        switch (i) {
            case 0:[view setBackgroundColor:[UIColor redColor]];break;
            case 1:[view setBackgroundColor:[UIColor greenColor]];break;
            case 2:[view setBackgroundColor:[UIColor blueColor]];break;
            case 3:[view setBackgroundColor:[UIColor yellowColor]];break;
        }
		[scrollView addSubview:view];
		[view release];
        
		cx += scrollView.frame.size.width;
	}
    pageControl.numberOfPages = npages;
    pageControl.currentPage = 0;
	
    NSLog(@"%f",[scrollView bounds].size.height);
	[scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)changePage:(id)sender 
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];
    
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}


@end
