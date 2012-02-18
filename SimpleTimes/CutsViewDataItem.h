//
//  CutsViewDataItem.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/16/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CutsViewDataItem : NSObject

@property (retain) NSString* standard;
@property (retain) NSArray*  cuts;         // Array of NSStrings

-(id) initWithStandard:(NSString*)std;

@end
