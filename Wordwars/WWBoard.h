//
//  WWBoard.h
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWPosition.h"

@interface WWBoard : NSObject
{
    @private
    int _rows;
    int _columns;
    NSMutableArray *_positions;
}
@property(nonatomic, readonly) int rows;
@property(nonatomic, readonly) int columns;
@property(nonatomic, readonly, strong) NSArray *positions;
+(WWBoard *) boardWithRows:(int)rows columns:(int)columns;
-(WWBoard *) initWithRows:(int)rows columns:(int)columns;
-(WWPosition *) positionAtRow:(int)row column:(int)column;
@end
