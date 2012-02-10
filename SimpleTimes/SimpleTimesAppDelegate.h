//
//  SimpleTimesAppDelegate.h
//  SimpleTimes
//
//  Created by David LaPorte on 11/13/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@class DetailViewScrollController;

//@interface SimpleTimesAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> 
@interface SimpleTimesAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{

}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
- (NSURL *)applicationUrlDocumentsDirectory;
// iOS 3 compatible
- (NSString *)applicationStringDocumentsDirectory;

@property (strong,nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) IBOutlet RootViewController *rootVC;

@end
