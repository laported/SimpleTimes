//
//  Swimmers.m
//  SimpleTimes
//
//  Created by David LaPorte on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Swimmers.h"
#import "AthleteCD.h"

@implementation Swimmers

@synthesize athletes = _athletes;
@synthesize athletesCD = _athletesCD;

-(void)loadWithContext:(NSManagedObjectContext *)context {
    
    // Load all AthleteCD objects from the store
    _count = 0;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AthleteCD" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    self.athletesCD = [context executeFetchRequest:fetchRequest error:&error];
    for (AthleteCD *ath in self.athletesCD) {
        NSLog(@"Name: %@ %@", ath.firstname, ath.lastname);
        NSLog(@"Birthdate: %@", ath.birthdate);
        _count++;
    }        
    [fetchRequest release];
    
}

-(int) count {
    return _count;
}
/*
/// @deprecated
-(void)load {
    
    // TODO: for now, hard code the athlete selection
    Athlete* a1 = [[Athlete alloc] initWithLastName:@"LaPorte" firstName:@"Benjamin" club:@"LCSC" key:11655];
    a1.age = 11;
    a1.gender = @"m";
    
    Athlete* a2 = [[Athlete alloc] initWithLastName:@"LaPorte" firstName:@"Matthew" club:@"LCSC" key:11657];
    a2.age = 14;
    a2.gender = @"m";
    
    Athlete* a3 = [[Athlete alloc] initWithLastName:@"LaPorte" firstName:@"Kelly" club:@"LCSC" key:11656];
    a3.age = 16;
    a3.gender = @"f";
    
    self.athletes = [NSMutableArray arrayWithObjects:
                     a1,a2,a3,nil];
    
}
*/
#ifdef DEBUG
+(void) deleteAllUsingContext:(NSManagedObjectContext *)context {
    NSFetchRequest * fetch = [[[NSFetchRequest alloc] init] autorelease];
    [fetch setEntity:[NSEntityDescription entityForName:@"AthleteCD" inManagedObjectContext:context]];
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    for (id a in result)
        [context deleteObject:a];
}

+(void) seedTestDataUsingContext:(NSManagedObjectContext *)context {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    
    AthleteCD *ath1 = [NSEntityDescription
                       insertNewObjectForEntityForName:@"AthleteCD" 
                       inManagedObjectContext:context];
    ath1.firstname = @"Benjamin";
    ath1.lastname = @"LaPorte";
    ath1.club = @"LCSC";
    ath1.birthdate = [dateFormatter dateFromString:@"01-29-2000"];
    ath1.miswimid = [[NSNumber alloc] initWithInt:11655];
    ath1.gender = @"m";
    
    AthleteCD *ath2 = [NSEntityDescription
                       insertNewObjectForEntityForName:@"AthleteCD" 
                       inManagedObjectContext:context];
    ath2.firstname = @"Matthew";
    ath2.lastname = @"LaPorte";
    ath2.club = @"LCSC";
    ath2.birthdate = [dateFormatter dateFromString:@"07-10-1997"];
    ath2.miswimid = [[NSNumber alloc] initWithInt:11657];
    ath2.gender= @"m";
    
    AthleteCD *ath3 = [NSEntityDescription
                       insertNewObjectForEntityForName:@"AthleteCD" 
                       inManagedObjectContext:context];
    ath3.firstname = @"Kelly";
    ath3.lastname = @"LaPorte";
    ath3.club = @"LCSC";
    ath3.birthdate = [dateFormatter dateFromString:@"07-23-1995"];
    ath3.miswimid = [[NSNumber alloc] initWithInt:11656];
    ath3.gender = @"f";
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
   
    [dateFormatter release];
}
#endif

@end
