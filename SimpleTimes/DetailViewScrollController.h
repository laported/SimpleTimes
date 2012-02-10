//
//  DetailViewScrollController.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/4/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailSwimmerViewController.h"
#import "Swimmers.h"

@interface DetailViewScrollController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray* viewControllers;
    Swimmers*       theSwimmers;
        
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    BOOL pageControlIsChangingPage;
    
    BOOL initialized;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) Swimmers* theSwimmers;

- (IBAction)changePage:(id)sender;

- (id)initWithNSManagedObjectContext:(NSManagedObjectContext*)moc;
//- (void)loadDetailViewPage:(int)page;
- (void)setupPage;

@end
