//
//  WWPosition.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWPosition.h"

@interface WWPosition ()
@property(nonatomic, readwrite, strong) WWMove *previousMove;
@end

@implementation WWPosition

@synthesize row=_row;
@synthesize column=_column;
@synthesize move=_move;

+(WWPosition *) positionWithRow:(int)row column:(int)column
{
    return [[WWPosition alloc] initWithRow:row column:column];
}

-(WWPosition *) initWithRow:(int)row column:(int)column
{
    if (self = [super init])
    {
        _row = row;
        _column = column;
    }
    return self;
}

- (void)setMove:(WWMove *)move
{
    _previousMove = _move;
    _move = move;
}

-(BOOL) hasMove
{
    return _move != nil;
}

-(void) undoMove
{
    if ([self hasMove])
    {
        _move = _previousMove;
        _previousMove = nil;
    }
}

-(int) pointsForPlayer:(WWPlayer *)player
{
    return [self hasMove] ? [_move pointsForPlayer:player] : 0;
}

- (NSComparisonResult)compare:(WWPosition *)position {
    if (_row < position.row)
        return NSOrderedAscending;
    else if (_row > position.row)
        return NSOrderedDescending;
    else {
        if (_column < position.column)
            return NSOrderedAscending;
        else if(_column > position.column)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }
}

@end
