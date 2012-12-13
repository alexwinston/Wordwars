//
//  WordwarsTests.m
//  WordwarsTests
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WordwarsTests.h"

#import "NSArray+WWAdditions.h"
#import "NSData+GZip.h"

#import "WWBoard.h"
#import "WWFrequency.h"
#import "WWGameCenterSerialization.h"
#import "WWMove.h"
#import "WWPlayer.h"
#import "WWPosition.h"
#import "WWTurn.h"

@implementation WordwarsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCumulativeFrequency
{
    NSDictionary *distributionFrequencies = @{
                                           @"A": @(10.0/100.0),
                                           @"B": [NSNumber numberWithDouble:0.3],
                                           @"C": @(0.4),
                                           @"D": [NSNumber numberWithDouble:0.2] };
    
    WWFrequency *frequency = [WWFrequency frequencyWithDistributionFrequencies:distributionFrequencies];
    STAssertEquals(0.1, [[frequency.cumulativeFrequencies objectForKey:@"A"] doubleValue], @"");
    STAssertEquals(0.4, [[frequency.cumulativeFrequencies objectForKey:@"B"] doubleValue], @"");
    STAssertEquals(0.8, [[frequency.cumulativeFrequencies objectForKey:@"C"] doubleValue], @"");
    STAssertEquals(1.0, [[frequency.cumulativeFrequencies objectForKey:@"D"] doubleValue], @"");
    
    STAssertEqualObjects(@"A", [frequency stringForCumulativeFrequency:0.039], @"");
    STAssertEqualObjects(@"B", [frequency stringForCumulativeFrequency:0.354], @"");
    STAssertEqualObjects(@"C", [frequency stringForCumulativeFrequency:0.612], @"");
    STAssertEqualObjects(@"D", [frequency stringForCumulativeFrequency:0.963], @"");
    
    int frequencyCount = 0;
    for (int i = 0; i < 1000; i++)
    {
        if ([[frequency stringForRandomCulmulativeFrequency] isEqualToString:@"A"])
            frequencyCount++;
    }
    STAssertEqualsWithAccuracy(100, frequencyCount, 20, @"");
}

-(void) testBoard
{
    WWBoard *board = [WWBoard boardWithRows:5 columns:5];
    STAssertEquals(0, [board positionAtRow:0 column:0].row, @"");
    STAssertEquals(0, [board positionAtRow:0 column:0].column, @"");
    STAssertEquals(1, [board positionAtRow:1 column:1].row, @"");
    STAssertEquals(1, [board positionAtRow:1 column:1].column, @"");
    STAssertEquals(2, [board positionAtRow:2 column:3].row, @"");
    STAssertEquals(3, [board positionAtRow:2 column:3].column, @"");
}

-(void) testPosition
{
    WWPlayer *player = [WWPlayer playerWithName:@"1"];
    
    WWPosition *position = [WWPosition positionWithRow:2 column:3];
    STAssertEquals(2, position.row, @"");
    STAssertEquals(3, position.column, @"");
    STAssertFalse([position hasMove], @"");
    STAssertEquals(0, [position pointsForPlayer:player], @"");
    STAssertEquals(0, [position pointsForPlayer:[WWPlayer playerWithName:@"1"]], @"");
    [position undoMove];
    STAssertFalse([position hasMove], @"");
    
    position.move = [WWMove moveWithPlayer:player
                                      tile:[[WWTile alloc] initWithLetter:@"A" points:1]
                                  position:[[WWPosition alloc] initWithRow:0 column:0]];
    STAssertTrue([position hasMove], @"");
    STAssertEquals(1, [position pointsForPlayer:player], @"");
    STAssertEquals(0, [position pointsForPlayer:[WWPlayer playerWithName:@"1"]], @"");
    
    [position undoMove];
    STAssertFalse([position hasMove], @"");
    STAssertEquals(0, [position pointsForPlayer:player], @"");
    STAssertEquals(0, [position pointsForPlayer:[WWPlayer playerWithName:@"1"]], @"");
}

-(void) testPlayer
{
    WWTile *tile1 = [WWTile tileWithLetter:@"A" points:1];
    WWTile *tile2 = [WWTile tileWithLetter:@"B" points:2];
    WWTile *tile3 = [WWTile tileWithLetter:@"C" points:3];
    WWTile *tile4 = [WWTile tileWithLetter:@"A" points:1];
    WWTile *tile5 = [WWTile tileWithLetter:@"D" points:2];
    
    WWPlayer *player = [WWPlayer playerWithName:@"1"];
    [player.rack addObject:tile1];
    [player.rack addObject:tile2];
    [player.rack addObject:tile3];
    [player.rack addObject:tile4];
    [player.rack addObject:tile5];
    [player shuffleRack];
    
    if ([player.rack objectAtIndex:0] == tile1 &&
        [player.rack objectAtIndex:1] == tile2 &&
        [player.rack objectAtIndex:2] == tile3 &&
        [player.rack objectAtIndex:3] == tile4 &&
        [player.rack objectAtIndex:4] == tile5)
        STFail(@"Rack not shuffled");
}

-(void) testMove
{
    WWBoard *board = [WWBoard boardWithRows:5 columns:5];
    
    WWTile *tile1 = [WWTile tileWithLetter:@"A" points:1];
    WWTile *tile2 = [WWTile tileWithLetter:@"B" points:2];
    WWTile *tile3 = [WWTile tileWithLetter:@"C" points:3];
    WWTile *tile4 = [WWTile tileWithLetter:@"A" points:1];
    
    WWPlayer *player = [WWPlayer playerWithName:@"1"];
    [player.rack addObject:tile1];
    [player.rack addObject:tile2];
    [player.rack addObject:tile3];
    [player.rack addObject:tile4];
    STAssertEquals(4U, player.rack.count, @"");
    
    WWMove *move1 = [WWMove moveWithPlayer:player
                                      tile:[player.rack objectAtIndex:0]
                                  position:[board positionAtRow:0 column:0]];
    STAssertEquals(3U, player.rack.count, @"");
    STAssertFalse([player.rack containsObject:tile1], @"");
    STAssertTrue([player.rack containsObject:tile2], @"");
    STAssertTrue([player.rack containsObject:tile3], @"");
    STAssertTrue([player.rack containsObject:tile4], @"");
    STAssertEquals(1, [move1 pointsForPlayer:player], @"");
    
    [move1 undo];
    STAssertEquals(4U, player.rack.count, @"");
    STAssertTrue([player.rack containsObject:tile1], @"");
    STAssertTrue([player.rack containsObject:tile2], @"");
    STAssertTrue([player.rack containsObject:tile3], @"");
    STAssertTrue([player.rack containsObject:tile4], @"");
    STAssertEquals(1, [move1 pointsForPlayer:player], @""); // ???
}

-(void) testTurn
{
    WWBoard *board = [WWBoard boardWithRows:5 columns:5];
    
    WWTile *tile1 = [WWTile tileWithLetter:@"A" points:1];
    WWTile *tile2 = [WWTile tileWithLetter:@"B" points:2];
    WWTile *tile3 = [WWTile tileWithLetter:@"C" points:3];
    WWTile *tile4 = [WWTile tileWithLetter:@"A" points:1];
    
    WWPlayer *player = [WWPlayer playerWithName:@"1"];
    [player.rack addObject:tile1];
    [player.rack addObject:tile2];
    [player.rack addObject:tile3];
    [player.rack addObject:tile4];
    
    WWTurn *turn1 = [WWTurn turnWithPlayer:player];
    STAssertEquals(0U, turn1.moves.count, @"");
    STAssertEquals(4U, player.rack.count, @"");
    STAssertTrue([turn1 canMoveTile:tile1 toPosition:[board positionAtRow:0 column:0]], @"");
    
    [turn1 moveTile:tile1 toPosition:[board positionAtRow:0 column:0]];
    STAssertEquals(1U, turn1.moves.count, @"");
    STAssertEquals(3U, player.rack.count, @"");
    STAssertTrue([turn1 canMoveTile:tile1 toPosition:[board positionAtRow:0 column:0]], @"");
    STAssertFalse([turn1 canMoveTile:tile4 toPosition:[board positionAtRow:0 column:0]], @"");
    STAssertFalse([turn1 canMoveTile:tile2 toPosition:[board positionAtRow:0 column:0]], @"");
    
    [turn1 undoMoves];
    [turn1 moveTile:tile2 toPosition:[board positionAtRow:0 column:0]];
    STAssertTrue([[board positionAtRow:0 column:0] hasMove], @"");
    
    WWTurn *turn2 = [WWTurn turnWithPlayer:player];
    STAssertFalse([turn2 canMoveTile:tile1 toPosition:[board positionAtRow:0 column:0]], @"");
    STAssertTrue([turn2 canMoveTile:tile2 toPosition:[board positionAtRow:0 column:0]], @"");
    
    WWTurn *turn3 = [WWTurn turnWithPlayer:player];
    STAssertEqualObjects(@"", [turn3 word], @"");
    [turn3 moveTile:[WWTile tileWithLetter:@"T" points:1] toPosition:[WWPosition positionWithRow:0 column:0]];
    STAssertEqualObjects(@"T", [turn3 word], @"");
    [turn3 moveTile:[WWTile tileWithLetter:@"E" points:1] toPosition:[WWPosition positionWithRow:0 column:1]];
    STAssertEqualObjects(@"TE", [turn3 word], @"");
    [turn3 moveTile:[WWTile tileWithLetter:@"S" points:1] toPosition:[WWPosition positionWithRow:0 column:2]];
    STAssertEqualObjects(@"TES", [turn3 word], @"");
    [turn3 moveTile:[WWTile tileWithLetter:@"T" points:1] toPosition:[WWPosition positionWithRow:0 column:3]];
    STAssertEqualObjects(@"TEST", [turn3 word], @"");
    
    WWTurn *turn4 = [WWTurn turnWithPlayer:player];
    STAssertEqualObjects(@"", [turn4 word], @"");
    [turn4 moveTile:[WWTile tileWithLetter:@"T" points:1] toPosition:[WWPosition positionWithRow:1 column:1]];
    STAssertEqualObjects(@"T", [turn4 word], @"");
    [turn4 moveTile:[WWTile tileWithLetter:@"E" points:1] toPosition:[WWPosition positionWithRow:2 column:1]];
    STAssertEqualObjects(@"TE", [turn4 word], @"");
    [turn4 moveTile:[WWTile tileWithLetter:@"S" points:1] toPosition:[WWPosition positionWithRow:3 column:1]];
    STAssertEqualObjects(@"TES", [turn4 word], @"");
    [turn4 moveTile:[WWTile tileWithLetter:@"T" points:1] toPosition:[WWPosition positionWithRow:4 column:1]];
    STAssertEqualObjects(@"TEST", [turn4 word], @"");
    
    WWTurn *turn5 = [WWTurn turnWithPlayer:player];
    STAssertFalse([turn5 isValid], @"");
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:0 column:0]];
    STAssertFalse([turn5 isValid], @"");
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:0 column:1]];
    STAssertTrue([turn5 isValid], @"");
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:1 column:2]];
    STAssertFalse([turn5 isValid], @"");
    
    [turn5 undoMoves];
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:1 column:0]];
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:1 column:3]];
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:1 column:1]];
    STAssertFalse([turn5 isValid], @"");
    
    [turn5 undoMoves];
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:1 column:2]];
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:2 column:2]];
    [turn5 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:3 column:2]];
    STAssertTrue([turn5 isValid], @"");
}

- (void)testTurnWordForMovesWithUnorderedPositions
{    
    WWTurn *turn1 = [WWTurn turnWithPlayer:[WWPlayer playerWithName:@"1"]];
    [turn1 moveTile:[WWTile tileWithLetter:@"E" points:1] toPosition:[WWPosition positionWithRow:4 column:0]];
    [turn1 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:2 column:0]];
    [turn1 moveTile:[WWTile tileWithLetter:@"B" points:1] toPosition:[WWPosition positionWithRow:1 column:0]];
    [turn1 moveTile:[WWTile tileWithLetter:@"K" points:1] toPosition:[WWPosition positionWithRow:3 column:0]];
    STAssertEqualObjects(@"BAKE", [turn1 word], @"");
    
    WWTurn *turn2 = [WWTurn turnWithPlayer:[WWPlayer playerWithName:@"1"]];
    [turn2 moveTile:[WWTile tileWithLetter:@"Y" points:1] toPosition:[WWPosition positionWithRow:0 column:4]];
    [turn2 moveTile:[WWTile tileWithLetter:@"R" points:1] toPosition:[WWPosition positionWithRow:0 column:2]];
    [turn2 moveTile:[WWTile tileWithLetter:@"T" points:1] toPosition:[WWPosition positionWithRow:0 column:1]];
    [turn2 moveTile:[WWTile tileWithLetter:@"A" points:1] toPosition:[WWPosition positionWithRow:0 column:3]];
    STAssertEqualObjects(@"TRAY", [turn2 word], @"");
}

-(void) testGame
{
    WWPlayer *player1 = [WWPlayer playerWithName:@"1"];
    [player1.rack addObject:[WWTile tileWithLetter:@"A" points:1]];
    [player1.rack addObject:[WWTile tileWithLetter:@"T" points:1]];
    WWPlayer *player2 = [WWPlayer playerWithName:@"2"];
    WWPlayer *player3 = [WWPlayer playerWithName:@"2"];
    
    WWGame *game = [WWGame gameWithDictionary:@[ @"AT" ]
                                        board:[WWBoard boardWithRows:5 columns:5]
                                      players:@[ player1, player2, player3 ]];
    STAssertEquals(5U, player1.rack.count, @"");
    STAssertEquals(5U, player2.rack.count, @"");
    STAssertEquals(5U, player3.rack.count, @"");
    STAssertEqualObjects(player1, game.currentTurn.player, @"");
    STAssertEqualObjects(player2, [game nextPlayersTurn:player1], @"");
    STAssertEqualObjects(player3, [game nextPlayersTurn:player2], @"");
    STAssertEqualObjects(player1, [game nextPlayersTurn:player3], @"");
    
    WWPlayer *currentPlayer = game.currentTurn.player;
    STAssertFalse([game playCurrentTurn], @"");
    STAssertEqualObjects(player1, currentPlayer, @"");
    STAssertEquals(5U, currentPlayer.rack.count, @"");
    
    WWTile *tile1 = [currentPlayer.rack objectAtIndex:0];
    [game.currentTurn moveTile:tile1 toPosition:[WWPosition positionWithRow:0 column:0]];
    STAssertEquals(4U, currentPlayer.rack.count, @"");
    STAssertFalse([game playCurrentTurn], @"");
    STAssertFalse([currentPlayer.rack containsObject:tile1], @"");
    
    WWTile *tile2 = [currentPlayer.rack objectAtIndex:0];
    [game.currentTurn moveTile:tile2 toPosition:[WWPosition positionWithRow:0 column:1]];
    STAssertEquals(3U, currentPlayer.rack.count, @"");
    STAssertTrue([game playCurrentTurn], @"");
    STAssertEquals(5U, currentPlayer.rack.count, @"");
    STAssertFalse([currentPlayer.rack containsObject:tile1], @"");
    STAssertFalse([currentPlayer.rack containsObject:tile2], @"");
}

- (void)testGameFinished
{
    WWPlayer *player1 = [WWPlayer playerWithName:@"1"];
    [player1.rack addObject:[WWTile tileWithLetter:@"C" points:1]];
    [player1.rack addObject:[WWTile tileWithLetter:@"A" points:1]];
    [player1.rack addObject:[WWTile tileWithLetter:@"T" points:1]];
    WWPlayer *player2 = [WWPlayer playerWithName:@"2"];
    [player2.rack addObject:[WWTile tileWithLetter:@"A" points:1]];
    [player2.rack addObject:[WWTile tileWithLetter:@"N" points:1]];
    [player2.rack addObject:[WWTile tileWithLetter:@"T" points:1]];
    
    WWGame *game = [WWGame gameWithDictionary:@[ @"CAT", @"ANT", @"DOG" ]
                                        board:[WWBoard boardWithRows:3 columns:3]
                                      players:@[ player1, player2 ]];
    game.delegate = self;
    
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:0 column:0]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:0 column:1]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:0 column:2]];
    STAssertTrue([game playCurrentTurn], @"");
    STAssertTrue([game hasMoves], @"");
    STAssertFalse(_gameFinished, @"Delegate shouldn't send -gameDidFinish:WithWinningPlayers:points:");
    
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game.board positionAtRow:1 column:0]];
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game.board positionAtRow:1 column:1]];
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game.board positionAtRow:1 column:2]];
    STAssertTrue([game playCurrentTurn], @"");
    STAssertTrue([game hasMoves], @"");
    STAssertFalse(_gameFinished, @"Delegate shouldn't send -gameDidFinish:WithWinningPlayers:points:");
    
    [player1.rack removeAllObjects];
    [player1.rack addObject:[WWTile tileWithLetter:@"D" points:1]];
    [player1.rack addObject:[WWTile tileWithLetter:@"O" points:1]];
    [player1.rack addObject:[WWTile tileWithLetter:@"G" points:1]];
    
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:2 column:0]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:2 column:1]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:2 column:2]];
    STAssertTrue([game playCurrentTurn], @"");
    STAssertFalse([game hasMoves], @"");
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    STAssertTrue(_gameFinished, @"Delegate should send -gameDidFinish:WithWinningPlayers:points:");
}

#pragma mark - WWGameDelegate methods

- (void)game:(WWGame *)game didChangeMoves:(NSArray *)moves forTurn:(WWTurn *)turn
{
}

- (void)game:(WWGame *)game didStartTurn:(WWTurn *)turn forPlayer:(WWPlayer *)player
{
}

- (void)game:(WWGame *)game didEndTurn:(WWTurn *)turn forPlayer:(WWPlayer *)player
{
}

- (void)gameDidFinish:(WWGame *)game withWinningPlayers:(NSArray *)players points:(int)points
{
    NSLog(@"gameDidFinish");
    _gameFinished = YES;
}

- (void)testGameCenterSerialization
{
    NSArray *gameDictionary = @[ @"RACK", @"ANT", @"FRIEND", @"IN", @"HAT" ];
    
    WWPlayer *player1 = [WWPlayer playerWithName:@"1"];
    [player1.rack addObject:[WWGame tileWithLetter:@"R"]];
    [player1.rack addObject:[WWGame tileWithLetter:@"A"]];
    [player1.rack addObject:[WWGame tileWithLetter:@"C"]];
    [player1.rack addObject:[WWGame tileWithLetter:@"K"]];
    [player1.rack addObject:[WWGame tileWithLetter:@"I"]];
    [player1.rack addObject:[WWGame tileWithLetter:@"N"]];
    WWPlayer *player2 = [WWPlayer playerWithName:@"2"];
    [player2.rack addObject:[WWGame tileWithLetter:@"A"]];
    [player2.rack addObject:[WWGame tileWithLetter:@"N"]];
    [player2.rack addObject:[WWGame tileWithLetter:@"T"]];
    [player2.rack addObject:[WWGame tileWithLetter:@"H"]];
    [player2.rack addObject:[WWGame tileWithLetter:@"A"]];
    [player2.rack addObject:[WWGame tileWithLetter:@"T"]];
    WWPlayer *player3 = [WWPlayer playerWithName:@"3"];
    [player3.rack addObject:[WWGame tileWithLetter:@"F"]];
    [player3.rack addObject:[WWGame tileWithLetter:@"R"]];
    [player3.rack addObject:[WWGame tileWithLetter:@"I"]];
    [player3.rack addObject:[WWGame tileWithLetter:@"E"]];
    [player3.rack addObject:[WWGame tileWithLetter:@"N"]];
    [player3.rack addObject:[WWGame tileWithLetter:@"D"]];
    
    WWGame *game = [WWGame gameWithDictionary:gameDictionary
                                        board:[WWBoard boardWithRows:6 columns:6]
                                      players:@[ player1, player2, player3 ]];
    
    NSData *gameData1 = [WWGameCenterSerialization dataFromGame:game];
    STAssertEqualObjects(gameData1, [WWGameCenterSerialization dataFromGame:[WWGameCenterSerialization gameFromData:gameData1 dictionary:gameDictionary]], @"");
    
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game positionAtRow:0 column:0]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game positionAtRow:0 column:1]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game positionAtRow:0 column:2]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game positionAtRow:0 column:3]];
    [game playCurrentTurn];
    
    NSData *gameData2 = [WWGameCenterSerialization dataFromGame:game];
    WWGame *game2 = [WWGameCenterSerialization gameFromData:gameData2 dictionary:gameDictionary];
    STAssertEqualObjects(gameData2, [WWGameCenterSerialization dataFromGame:game2], @"");
    STAssertEqualObjects([game2.players valueForKeyPath:@"points"], [game.players valueForKeyPath:@"points"], @"");
    
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game positionAtRow:0 column:0]];
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game positionAtRow:1 column:0]];
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game positionAtRow:2 column:0]];
    [game playCurrentTurn];
    
    NSData *gameData3 = [WWGameCenterSerialization dataFromGame:game];
    STAssertEqualObjects(gameData3, [WWGameCenterSerialization dataFromGame:[WWGameCenterSerialization gameFromData:gameData3 dictionary:gameDictionary]], @"");
    
    [game skipCurrentTurn];
    [game skipCurrentTurn];
    [game skipCurrentTurn];
    
    NSData *gameData4 = [WWGameCenterSerialization dataFromGame:game];
    STAssertEqualObjects(gameData4, [WWGameCenterSerialization dataFromGame:[WWGameCenterSerialization gameFromData:gameData4 dictionary:gameDictionary]], @"");
    
    [game.currentTurn moveTile:[player3.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:0]];
    [game.currentTurn moveTile:[player3.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:1]];
    [game.currentTurn moveTile:[player3.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:2]];
    [game.currentTurn moveTile:[player3.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:3]];
    [game.currentTurn moveTile:[player3.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:4]];
    [game.currentTurn moveTile:[player3.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:5]];
    [game playCurrentTurn];
    
    NSData *gameData5 = [WWGameCenterSerialization dataFromGame:game];
    STAssertEqualObjects(gameData5, [WWGameCenterSerialization dataFromGame:[WWGameCenterSerialization gameFromData:gameData5 dictionary:gameDictionary]], @"");
    
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game positionAtRow:0 column:5]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game positionAtRow:1 column:5]];
    [game playCurrentTurn];
    
    NSData *gameData6 = [WWGameCenterSerialization dataFromGame:game];
    STAssertEqualObjects(gameData6, [WWGameCenterSerialization dataFromGame:[WWGameCenterSerialization gameFromData:gameData6 dictionary:gameDictionary]], @"");
    
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:2]];
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:3]];
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game positionAtRow:5 column:4]];
    [game playCurrentTurn];
    
    NSData *gameData7 = [WWGameCenterSerialization dataFromGame:game];
    STAssertEqualObjects(gameData7, [WWGameCenterSerialization dataFromGame:[WWGameCenterSerialization gameFromData:gameData7 dictionary:gameDictionary]], @"");
    
    [game swapTilesForCurrentTurn];

    NSData *gameData8 = [WWGameCenterSerialization dataFromGame:game];
    STAssertEqualObjects(gameData8, [WWGameCenterSerialization dataFromGame:[WWGameCenterSerialization gameFromData:gameData8 dictionary:gameDictionary]], @"");
}

- (void)testClearTurnWithMoveAtPositionForPreviousMoveFromDifferentPlayer
{
    WWPlayer *player1 = [WWPlayer playerWithName:@"1"];
    [player1.rack addObjectsFromArray:@[ [WWTile tileWithLetter:@"A" points:1], [WWTile tileWithLetter:@"T" points:3]]];
    WWPlayer *player2 = [WWPlayer playerWithName:@"2"];
    [player2.rack addObjectsFromArray:@[ [WWTile tileWithLetter:@"I" points:4], [WWTile tileWithLetter:@"T" points:2]]];
    
    WWGame *game = [WWGame gameWithDictionary:@[ @"AT", @"IT" ]
                                        board:[WWBoard boardWithRows:5 columns:5]
                                      players:@[ player1, player2 ]];
    
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:0 column:0]];
    [game.currentTurn moveTile:[player1.rack objectAtIndex:0] toPosition:[game.board positionAtRow:0 column:1]];
    [game playCurrentTurn];
    STAssertEquals(4, player1.points, @"");
    STAssertEquals(0, player2.points, @"");
    
    [game.currentTurn moveTile:[player2.rack objectAtIndex:0] toPosition:[game.board positionAtRow:0 column:1]];
    STAssertEquals(1, player1.points, @"");
    STAssertEquals(4, player2.points, @"");
    
    [game.currentTurn undoMoves];
    STAssertEquals(4, player1.points, @"");
    STAssertEquals(0, player2.points, @"");
}


- (void)testArrayContainsOnlyObjectsInArray
{
    NSArray *vowels = @[ @"A", @"E", @"I", @"O" ];
    NSArray *consonants = @[ @"B", @"C", @"D", @"F", @"G" ];
    
    NSArray *array1 = @[ @"A", @"E", @"I", @"E" ];
    STAssertTrue([array1 containsOnlyObjects:vowels], @"");
    
    NSArray *array2 = @[ @"A", @"E", @"I", @"D" ];
    STAssertFalse([array2 containsOnlyObjects:vowels], @"");
    
    NSArray *array3 = @[ @"A", @"E", @"I", @"D" ];
    STAssertFalse([array3 containsOnlyObjects:consonants], @"");
    
    NSArray *array4 = @[ @"C", @"C", @"G", @"A" ];
    STAssertFalse([array4 containsOnlyObjects:consonants], @"");
}

- (void)testArrayContainsNoObjectsInArray
{
    NSArray *vowels = @[ @"A", @"E", @"I", @"O" ];
    NSArray *consonants = @[ @"B", @"C", @"D", @"F", @"G" ];
    
    NSArray *array1 = @[ @"A", @"E", @"I", @"E" ];
    STAssertTrue([array1 containsNoObjects:consonants], @"");
    
    NSArray *array2 = @[ @"A", @"E", @"I", @"D" ];
    STAssertFalse([array2 containsNoObjects:vowels], @"");
    
    NSArray *array4 = @[ @"C", @"C", @"G", @"A" ];
    STAssertFalse([array4 containsOnlyObjects:consonants], @"");
}

- (void)testDrawingTilesWithOnlyVowelsOrConsonants
{
    WWTile *a = [WWTile tileWithLetter:@"A" points:1];
    WWTile *b = [WWTile tileWithLetter:@"B" points:1];
    WWTile *c = [WWTile tileWithLetter:@"C" points:1];
    WWTile *d = [WWTile tileWithLetter:@"D" points:1];
    WWTile *e = [WWTile tileWithLetter:@"E" points:1];
    WWTile *i = [WWTile tileWithLetter:@"I" points:1];
    
    WWPlayer *player1 = [WWPlayer playerWithName:@"1"];
    [player1.rack addObjectsFromArray:@[ b, c, d ]];
    
    WWPlayer *player2 = [WWPlayer playerWithName:@"2"];
    [player2.rack addObjectsFromArray: @[ a, e, i ]];
    
    WWPlayer *player3 = [WWPlayer playerWithName:@"3"];
    [player3.rack addObjectsFromArray:@[ b, a, d ]];
    
    WWGame *game = [WWGame gameWithDictionary:@[ @"" ]
                                        board:[WWBoard boardWithRows:3 columns:3]
                                      players:@[ player1, player2, player3 ]];
    [game drawTilesWithRackSize:3 forPlayer:player1];
    STAssertEqualObjects([player1.rack objectAtIndex:0], b, @"");
    STAssertEqualObjects([player1.rack objectAtIndex:1], c, @"");
    WWTile *tile1 = [player1.rack objectAtIndex:2];
    STAssertEqualObjects(tile1.letter, @"E", @"");
    
    [game drawTilesWithRackSize:3 forPlayer:player2];
    STAssertEqualObjects([player2.rack objectAtIndex:0], a, @"");
    STAssertEqualObjects([player2.rack objectAtIndex:1], e, @"");
    WWTile *tile2 = [player2.rack objectAtIndex:2];
    STAssertEqualObjects(tile2.letter, @"N", @"");
    
    [game drawTilesWithRackSize:3 forPlayer:player3];
    STAssertEqualObjects([player3.rack objectAtIndex:0], b, @"");
    STAssertEqualObjects([player3.rack objectAtIndex:1], a, @"");
    STAssertEqualObjects([player3.rack objectAtIndex:2], d, @"");
}

- (void)testSortedPositionArrayUsingCompareSelector
{
    NSArray *p1 = @[ [WWPosition positionWithRow:0 column:0], [WWPosition positionWithRow:1 column:0] ];
    NSArray *s1 = [p1 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s1 objectAtIndex:0], [p1 objectAtIndex:0], @"");
    STAssertEqualObjects([s1 objectAtIndex:1], [p1 objectAtIndex:1], @"");
    
    NSArray *p2 = @[ [WWPosition positionWithRow:1 column:0], [WWPosition positionWithRow:0 column:0] ];
    NSArray *s2 = [p2 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s2 objectAtIndex:0], [p2 objectAtIndex:1], @"");
    STAssertEqualObjects([s2 objectAtIndex:1], [p2 objectAtIndex:0], @"");
    
    NSArray *p3 = @[ [WWPosition positionWithRow:0 column:0], [WWPosition positionWithRow:0 column:1] ];
    NSArray *s3 = [p3 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s3 objectAtIndex:0], [p3 objectAtIndex:0], @"");
    STAssertEqualObjects([s3 objectAtIndex:1], [p3 objectAtIndex:1], @"");
    
    NSArray *p4 = @[ [WWPosition positionWithRow:0 column:1], [WWPosition positionWithRow:0 column:0] ];
    NSArray *s4 = [p4 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s4 objectAtIndex:0], [p4 objectAtIndex:1], @"");
    STAssertEqualObjects([s4 objectAtIndex:1], [p4 objectAtIndex:0], @"");
    
    NSArray *p5 = @[ [WWPosition positionWithRow:1 column:3], [WWPosition positionWithRow:1 column:2], [WWPosition positionWithRow:1 column:1] ];
    NSArray *s5 = [p5 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s5 objectAtIndex:0], [p5 objectAtIndex:2], @"");
    STAssertEqualObjects([s5 objectAtIndex:1], [p5 objectAtIndex:1], @"");
    STAssertEqualObjects([s5 objectAtIndex:2], [p5 objectAtIndex:0], @"");
    
    NSArray *p6 = @[ [WWPosition positionWithRow:3 column:2], [WWPosition positionWithRow:2 column:2], [WWPosition positionWithRow:1 column:2] ];
    NSArray *s6 = [p6 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s6 objectAtIndex:0], [p6 objectAtIndex:2], @"");
    STAssertEqualObjects([s6 objectAtIndex:1], [p6 objectAtIndex:1], @"");
    STAssertEqualObjects([s6 objectAtIndex:2], [p6 objectAtIndex:0], @"");
    
    NSArray *p7 = @[ [WWPosition positionWithRow:1 column:0], [WWPosition positionWithRow:1 column:2], [WWPosition positionWithRow:1 column:1] ];
    NSArray *s7 = [p7 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s7 objectAtIndex:0], [p7 objectAtIndex:0], @"");
    STAssertEqualObjects([s7 objectAtIndex:1], [p7 objectAtIndex:2], @"");
    STAssertEqualObjects([s7 objectAtIndex:2], [p7 objectAtIndex:1], @"");
    
    NSArray *p8 = @[ [WWPosition positionWithRow:0 column:1], [WWPosition positionWithRow:2 column:1], [WWPosition positionWithRow:1 column:1] ];
    NSArray *s8 = [p8 sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects([s8 objectAtIndex:0], [p8 objectAtIndex:0], @"");
    STAssertEqualObjects([s8 objectAtIndex:1], [p8 objectAtIndex:2], @"");
    STAssertEqualObjects([s8 objectAtIndex:2], [p8 objectAtIndex:1], @"");
}


@end
