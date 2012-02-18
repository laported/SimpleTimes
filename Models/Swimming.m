//
//  Swimming.m
//  SimpleTimes
//
//  Created by David LaPorte on 2/2/12.
//  Singleton class pattern used from:
//  http://www.johnwordsworth.com/2010/04/iphone-code-snippet-the-singleton-pattern/
//

#import "Swimming.h"

@implementation Swimming

@synthesize strokes;
@synthesize distances;
static Swimming *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (Swimming *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        strokes = [[NSArray alloc] initWithObjects:@"Fly", @"Back", @"Breast", @"Free", @"IM", nil];
        distances = [[NSArray alloc] initWithObjects:@"25", @"50", @"100", @"200", @"400", @"500", @"800", @"1000", @"1600", @"1650", nil];
    }
    
    return self;
}

- (NSArray*) getStrokes
{
    Swimming* s = [Swimming sharedInstance];
    return s.strokes;
}

- (NSArray*) getDistances
{
    Swimming* s = [Swimming sharedInstance];
    return s.distances;
}
 
// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    // I'm never called!
    [super dealloc];
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [[self sharedInstance] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain {
    return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
- (oneway void)release {
    
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease {
    return self;
}

@end