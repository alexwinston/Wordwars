//
//  WWMove.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWMove.h"

@implementation WWMove

@synthesize player=_player;
@synthesize tile=_tile;
@synthesize position=_position;

+(WWMove *) moveWithPlayer:(WWPlayer *)player tile:(WWTile *)tile position:(WWPosition *)position
{
    return [[WWMove alloc] initWithPlayer:player tile:tile position:position];
}

-(WWMove *) initWithPlayer:(WWPlayer *)player tile:(WWTile *)tile position:(WWPosition *)position
{
    if (self = [super init])
    {
        _player = player;
        _tile = tile;
        _position = position;
        
        [_player.rack removeObject:_tile];
        _position.move = self;
    }
    return self;
}

- (WWMove *)undo
{
    if (![_player.rack containsObject:_tile])
        [_player.rack addObject:_tile];
    [_position undoMove];
    
    return self;
}

-(int) pointsForPlayer:(WWPlayer *)player
{
    return _player == player ? _tile.points : 0;
}

@end
