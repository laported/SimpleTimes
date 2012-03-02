//
//  CutsViewDataItem.h
//  SimpleTimes
//
//  Created by David LaPorte on 2/16/12.
//  Copyright (c) 2012 laporte6.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CutsViewDataItem : NSObject
{
    NSMutableArray* _cuts;
}

@property (retain) NSString* standard;
@property (retain) NSMutableArray*  cuts;         // Array of NSStrings

-(id) initWithStandard:(NSString*)std;
-(void) addCut:(NSString*)cut ;

@end
