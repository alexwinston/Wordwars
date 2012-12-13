//
//  WWGame.m
//  Wordwars
//
//  Created by Alex Winston on 11/27/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWGame.h"
#import "NSArray+WWAdditions.h"

@implementation WWGame

@synthesize delegate;

@synthesize board=_board;
@synthesize players=_players;
@synthesize currentTurn=_currentTurn;
@synthesize playedTurns=_playedTurns;

+ (int)pointsForLetter:(NSString *)letter
{
    static NSDictionary *letterPoints = nil;
    if (!letterPoints) {
        letterPoints = @{
        @"A": @(1),
        @"B": @(3),
        @"C": @(3),
        @"D": @(2),
        @"E": @(1),
        @"F": @(4),
        @"G": @(2),
        @"H": @(4),
        @"I": @(1),
        @"J": @(8),
        @"K": @(5),
        @"L": @(1),
        @"M": @(3),
        @"N": @(1),
        @"O": @(1),
        @"P": @(3),
        @"Q": @(10),
        @"R": @(1),
        @"S": @(1),
        @"T": @(1),
        @"U": @(2),
        @"V": @(5),
        @"W": @(4),
        @"X": @(8),
        @"Y": @(4),
        @"Z": @(10) };
    }
    return [[letterPoints objectForKey:letter] integerValue];
}

+ (WWTile *)tileWithLetter:(NSString *)letter
{
    return [WWTile tileWithLetter:letter points:[WWGame pointsForLetter:letter]];
}

+ (WWGame *) gameWithDictionary:(NSArray *)dictionary board:(WWBoard *)board players:(NSArray *)players
{
    return [[WWGame alloc] initWithDictionary:(NSArray *)dictionary board:board players:players];
}

-(WWGame *) initWithDictionary:(NSArray *)dictionary board:(WWBoard *)board players:(NSArray *)players
{
    if (self = [super init])
    {
        _letterFrequencies = [WWFrequency frequencyWithDistributionFrequencies:@{
                                  @"A": @(8.5/100.0),
                                  @"B": @(2.1/100.0),
                                  @"C": @(4.5/100.0),
                                  @"D": @(3.4/100.0),
                                  @"E": @(11.2/100.0),
                                  @"F": @(1.8/100.0),
                                  @"G": @(2.5/100.0),
                                  @"H": @(3.0/100.0),
                                  @"I": @(7.5/100.0),
                                  @"J": @(0.2/100.0),
                                  @"K": @(1.1/100.0),
                                  @"L": @(5.5/100.0),
                                  @"M": @(3.0/100.0),
                                  @"N": @(6.7/100.0),
                                  @"O": @(7.2/100.0),
                                  @"P": @(3.2/100.0),
                                  @"Q": @(0.2/100.0),
                                  @"R": @(7.6/100.0),
                                  @"S": @(5.3/100.0),
                                  @"T": @(7.0/100.0),
                                  @"U": @(3.6/100.0),
                                  @"V": @(1.0/100.0),
                                  @"W": @(1.3/100.0),
                                  @"X": @(0.3/100.0),
                                  @"Y": @(1.8/100.0),
                                  @"Z": @(0.3/100.0) }];
        
        _dictionary = dictionary;
        _board = board;
        
        _players = players;
        _playerColors = @[ [UIColor colorWithRed:76/255.0 green:198/255.0 blue:251/255.0 alpha:1.0],
                           [UIColor colorWithRed:220/255.0 green:41/255.0 blue:43/255.0 alpha:1.0],
                           [UIColor colorWithRed:220/255.0 green:41/255.0 blue:43/255.0 alpha:1.0],
                           [UIColor colorWithRed:220/255.0 green:41/255.0 blue:43/255.0 alpha:1.0] ];
        
        _currentPlayer = [_players objectAtIndex:0];
        _currentTurn = [WWTurn turnWithPlayer:_currentPlayer];
        _currentTurn.delegate = self;
        _playedTurns = [NSMutableArray array];
        _playedTurnWords = [NSMutableArray array];
        
        [_players enumerateObjectsUsingBlock:^(WWPlayer *player, NSUInteger index, BOOL *stop) {
            player.color = [_playerColors objectAtIndex:index];
            [self drawTilesWithRackSize:_board.rows forPlayer:player];
        }];
        
        // TODO Provide delegate as parameter in constructor
//        [self turn:_currentTurn startedForPlayer:_currentPlayer];
    }
    return self;
}

- (void)turn:(WWTurn *)turn startedForPlayer:(WWPlayer *)player
{
    if ([self.delegate respondsToSelector:@selector(game:didStartTurn:forPlayer:)])
        [self.delegate game:self didStartTurn:turn forPlayer:player];
}

- (void)turn:(WWTurn *)turn endedForPlayer:(WWPlayer *)player
{
    if ([self.delegate respondsToSelector:@selector(game:didEndTurn:forPlayer:)])
        [self.delegate game:self didEndTurn:turn forPlayer:player];
}

- (WWPosition *)positionAtRow:(int)row column:(int)column
{
    return [_board positionAtRow:row column:column];
}

- (NSArray *)playersWithPoints:(int)points
{
    NSMutableArray *playersWithPoints = [NSMutableArray array];
    for (WWPlayer *player in _players)
        if ([self pointsForPlayer:player] == points)
            [playersWithPoints addObject:player];
    return playersWithPoints;
    
}

- (BOOL)gameFinished
{
    NSLog(@"gameFinished");
    NSNumber *winningPoints = [_players valueForKeyPath:@"@max.points"];
    
    _isFinished = YES;
    if ([self.delegate respondsToSelector:@selector(gameDidFinish:withWinningPlayers:points:)])
        [self.delegate gameDidFinish:self
                  withWinningPlayers:[self playersWithPoints:[winningPoints integerValue]]
                              points:[winningPoints integerValue]];
    
    return YES;
}

-(void) undoCurrentTurn
{
    [_currentTurn undoMoves];
}

-(BOOL) playCurrentTurn
{
    return [self playTurn:_currentTurn];
}

-(BOOL) playTurn:(WWTurn *)turn
{
    NSString *turnWord = [turn word];
    
    if (![_currentTurn isValid] || [_playedTurnWords containsObject:turnWord] || ![_dictionary containsObject:turnWord])
        return NO;
    
    return [self endTurn:turn];
}

- (void)swapTilesForCurrentTurn
{
    [_currentPlayer.rack removeAllObjects];
    [self endTurn:_currentTurn];
}

- (void)skipCurrentTurn
{
    [self endTurn:_currentTurn];
}

- (BOOL)endTurn:(WWTurn *)turn
{
    if (_isFinished)
        return NO;
    
    [_currentPlayer didEndTurn:turn];
    
    [_playedTurns addObject:turn];
    [_playedTurnWords addObject:[turn word]];
    
    [self turn:_currentTurn endedForPlayer:_currentPlayer];
    
    if (![self hasMoves])
        return [self gameFinished];
    
    [self drawTilesWithRackSize:_board.rows forPlayer:_currentPlayer];
    
    _currentPlayer = [self nextPlayersTurn:_currentPlayer];
    _currentTurn = [WWTurn turnWithPlayer:_currentPlayer];
    _currentTurn.delegate = self;
    
    [self turn:_currentTurn startedForPlayer:_currentPlayer];
    
    return YES;
}

-(void) drawTilesWithRackSize:(int)rackSize forPlayer:(WWPlayer *)player;
{
    int tileCount = rackSize - player.rack.count;
    for (int i = 0; i < tileCount; i++) {
        NSString *randomLetter = [_letterFrequencies stringForRandomCulmulativeFrequency];
        [player.rack addObject:[WWGame tileWithLetter:randomLetter]];
    }

    // Add vowel or consonant if the rack doesn't contain one
    NSArray *rackLetters = [player.rack valueForKeyPath:@"letter"];
    
    if ([[NSArray arrayWithArray:rackLetters] containsOnlyObjects:@[ @"A", @"E", @"I", @"O", @"U" ]])
        [player.rack replaceObjectAtIndex:rackSize - 1
                               withObject:[WWGame tileWithLetter:@"N"]];
    if ([[NSArray arrayWithArray:rackLetters] containsNoObjects:@[ @"A", @"E", @"I", @"O", @"U" ]])
        [player.rack replaceObjectAtIndex:rackSize - 1
                               withObject:[WWGame tileWithLetter:@"E"]];
}

- (WWPlayer *)nextPlayersTurn:(WWPlayer *)player
{
    int nextPlayerIndex = [_players indexOfObject:player] + 1;
    if (nextPlayerIndex < _players.count)
        return [_players objectAtIndex:nextPlayerIndex];
    
    return [_players objectAtIndex:0];
}

- (int)pointsForPlayer:(WWPlayer *)player
{
    int points = 0;
    for (WWPosition *position in _board.positions)
        points += [position pointsForPlayer:player];
    return points;
}

- (int)playerNumberForPlayer:(WWPlayer *)player
{
    return [_players indexOfObject:player];
}

- (BOOL)hasMoves
{
    for (WWPosition *position in _board.positions) {
        if (![position hasMove])
            return YES;
    }
    NSLog(@"hasMoves");
    return NO;
}

#pragma mark - WWTurnDelegate methods

- (void)turn:(id)turn didChangeMoves:(NSArray *)moves
{
    for (WWPlayer *player in _players)
        player.points = [self pointsForPlayer:player];
    
    if ([self.delegate respondsToSelector:@selector(game:didChangeMoves:forTurn:)])
        [self.delegate game:self didChangeMoves:moves forTurn:turn];
}

@end
