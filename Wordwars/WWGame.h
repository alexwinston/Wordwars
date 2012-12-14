//
//  WWGame.h
//  Wordwars
//
//  Created by Alex Winston on 11/27/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWFrequency.h"
#import "WWBoard.h"
#import "WWTurn.h"

@class WWGame;

@protocol WWGameDelegate <NSObject>
- (void)game:(WWGame *)game didChangeMoves:(NSArray *)moves forTurn:(WWTurn *)turn;
- (void)game:(WWGame *)game didStartTurn:(WWTurn *)turn forPlayer:(WWPlayer *)player;
- (void)game:(WWGame *)game didEndTurn:(WWTurn *)turn forPlayer:(WWPlayer *)player;
- (void)gameDidFinish:(WWGame *)game withWinningPlayers:(NSArray *)players points:(int)points;
@end

@interface WWGame : NSObject<WWTurnDelegate>
{
    @private
    WWFrequency *_letterFrequencies;
    NSArray *_dictionary;
    WWBoard *_board;
    NSArray *_players;
    WWPlayer *_currentPlayer;
    WWTurn *_currentTurn;
    NSMutableArray *_playedTurns;
    NSMutableArray *_playedTurnWords;
    BOOL _isFinished;
}
@property(nonatomic, readwrite, weak) id <WWGameDelegate> delegate;
@property(nonatomic, readonly, strong) WWBoard *board;
@property(nonatomic, readonly, strong) NSArray *players;
@property(nonatomic, readonly, strong) WWTurn *currentTurn;
@property(nonatomic, readonly, strong) NSArray *playedTurns;
+ (WWTile *)tileWithLetter:(NSString *)letter;
+ (WWGame *)gameWithDictionary:(NSArray *)dictionary board:(WWBoard *)board players:(NSArray *)players;
- (WWGame *)initWithDictionary:(NSArray *)dictionary board:(WWBoard *)board players:(NSArray *)players;
- (WWPosition *)positionAtRow:(int)row column:(int)column;
- (BOOL)hasMoves;
- (BOOL)playTurn:(WWTurn *)turn;
- (void)undoCurrentTurn;
- (BOOL)playCurrentTurn;
- (void)swapTilesForCurrentTurn;
- (void)skipCurrentTurn;
- (void)drawTilesWithRackSize:(int)rackSize forPlayer:(WWPlayer *)player;
- (WWPlayer *)nextPlayersTurn:(WWPlayer *)player;
- (int)playerNumberForPlayer:(WWPlayer *)player;
@end
