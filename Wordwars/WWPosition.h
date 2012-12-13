//
//  WWPosition.h
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWMove.h"
#import "WWPlayer.h"

@class WWMove;
@class WWPlayer;

@interface WWPosition : NSObject
{
    @private
    int _row;
    int _column;
    WWMove *_move;
    WWMove *_previousMove;
}
@property(nonatomic, readonly) int row;
@property(nonatomic, readonly) int column;
@property(nonatomic, readwrite, strong) WWMove *move;
+(WWPosition *) positionWithRow:(int)row column:(int)column;
-(WWPosition *) initWithRow:(int)row column:(int)column;
-(BOOL) hasMove;
-(void) undoMove;
-(int) pointsForPlayer:(WWPlayer *)player;
@end
