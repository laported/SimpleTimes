//
//  SimpleTimesAppDelegate.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "DetailSwimmerViewController.h"

@interface SimpleTimesAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UITabBarController *tabBarController;


- (void)saveContext;
- (NSURL *)applicationUrlDocumentsDirectory;
// iOS 3 compatible
- (NSString *)applicationStringDocumentsDirectory;

@property (retain, nonatomic) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) IBOutlet RootViewController *rootVC;

@end
