//
//  WWTurn.m
//  Wordwars
//
//  Created by Alex Winston on 11/27/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "NSArray+WWAdditions.h"
#import "WWTurn.h"

@implementation WWTurn

@synthesize delegate;

@synthesize number=_number;
@synthesize player=_player;
@synthesize moves=_moves;

+(WWTurn *) turnWithNumber:(int)number player:(WWPlayer *)player
{
    return [[WWTurn alloc] initWithNumber:number player:player];
}

-(WWTurn *) initWithNumber:(int)number player:(WWPlayer *)player
{
    if (self = [super init])
    {
        _number = number;
        _player = player;
        _moves = [NSMutableArray array];
        _word = @"";
    }
    return self;
}

- (void)movesDidChange
{
    if([delegate respondsToSelector:@selector(turn:didChangeMoves:)]) {
        [delegate turn:self didChangeMoves:self.moves];
    }
}

-(BOOL) canMoveTile:(WWTile *)tile toPosition:(WWPosition *)position
{
    if (![position hasMove] || position.move.tile == tile)
        return YES;
    if ([_moves containsObject:position.move])
        return NO;
    
    return tile.points >= position.move.tile.points;
}

// TODO Replace with toRow:column: ?
-(BOOL) moveTile:(WWTile *)tile toPosition:(WWPosition *)position
{
    if (position.move.tile == tile)
        return YES;
    
    if (![self canMoveTile:tile toPosition:position])
        return NO;
    
    // Remove any existing moves for this tile
    [self removeMovesWithTile:tile];
    
    [_moves addObject:[WWMove moveWithPlayer:_player tile:tile position:position]];
    [self movesDidChange];
    
//    NSLog(@"%@ %d,%d", tile.letter, position.row, position.column);
    
    _word = [[[self positions] valueForKeyPath:@"move.tile.letter"] componentsJoinedByString:@""];
    
    return YES;
}

- (BOOL)hasMoves
{
    return _moves.count > 0;
}

- (void)undoMoves
{
    if ([self hasMoves]) {
        for (WWMove *move in _moves)
            [move undo];
        
        [_moves removeAllObjects];
        
        [self movesDidChange];
    }
}

- (void)removeMovesWithTile:(WWTile *)tile
{
    if ([self hasMoves]) {
        NSMutableArray *movesWithTile = [NSMutableArray array];
        for (WWMove *move in _moves) {
            if (move.tile == tile)
                [movesWithTile addObject:[move undo]];
        }
        if (movesWithTile.count > 0) {
            [_moves removeObjectsInArray:movesWithTile];
            [self movesDidChange];
        }
    }
}

-(BOOL) isValid
{
    if (_moves.count <= 1)
        return NO;
    
    NSArray *positions = [self positions];

    // Invalid if either the rows or columns are not in a row 
    if ([[positions valueForKeyPath:@"@distinctUnionOfObjects.row"] count] != 1 &&
        [[positions valueForKeyPath:@"@distinctUnionOfObjects.column"] count] != 1)
        return NO;
    
    // Invalid if either the rows or columns are not contiguous
    if (![[positions valueForKeyPath:@"@unionOfObjects.row"] isContiguous] &&
        ![[positions valueForKeyPath:@"@unionOfObjects.column"] isContiguous])
        return NO;
    
    return YES;
}

- (BOOL)containsTile:(WWTile *)tile
{
    return [[_moves valueForKeyPath:@"tile"] containsObject:tile];
}

- (NSArray *)positions
{
    return [[_moves valueForKeyPath:@"position"] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSString *)word
{
    return _word;
}

@end
