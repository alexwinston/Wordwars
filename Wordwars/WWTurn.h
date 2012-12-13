//
//  WWTurn.h
//  Wordwars
//
//  Created by Alex Winston on 11/27/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WWPlayer.h"
#import "WWPosition.h"
#import "WWTile.h"

@class WWPlayer;
@class WWPosition;
@class WWTile;
@class WWTurn;

@protocol WWTurnDelegate <NSObject>
- (void)turn:(WWTurn *)turn didChangeMoves:(NSArray *)moves;
@end

@interface WWTurn : NSObject
{
    @private
    WWPlayer *_player;
    NSMutableArray *_moves;
    NSString *_word;
}
@property(nonatomic, readwrite, weak) id <WWTurnDelegate> delegate;
@property(nonatomic, readonly, strong) WWPlayer *player;
@property(nonatomic, readonly, strong) NSArray *moves;
+ (WWTurn *)turnWithPlayer:(WWPlayer *)player;
- (WWTurn *)initWithPlayer:(WWPlayer *)player;
- (BOOL)canMoveTile:(WWTile *)tile toPosition:(WWPosition *)position;
- (BOOL)moveTile:(WWTile *)tile toPosition:(WWPosition *)position;
- (BOOL)hasMoves;
- (void)undoMoves;
- (void)removeMovesWithTile:(WWTile *)tile;
- (BOOL)isValid;
- (BOOL)containsTile:(WWTile *)tile;
- (NSArray *)positions;
- (NSString *)word;
@end