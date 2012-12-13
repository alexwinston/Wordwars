//
//  WWBoard.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWBoard.h"

@implementation WWBoard

@synthesize rows=_rows;
@synthesize columns=_columns;
@synthesize positions=_positions;

+(WWBoard *) boardWithRows:(int)rows columns:(int)columns
{
    return [[WWBoard alloc] initWithRows:rows columns:columns];
}

-(WWBoard *) initWithRows:(int)rows columns:(int)columns
{
    if (self = [super init])
    {
        _rows = rows;
        _columns = columns;
        _positions = [NSMutableArray arrayWithCapacity:_rows * _columns];
        
        for (int row = 0; row < _rows; row++)
        {
            for (int column = 0; column < _columns; column++)
            {
                [_positions addObject:[WWPosition positionWithRow:row column:column]];
            }
        }
    }
    return self;
}

-(WWPosition *) positionAtRow:(int)row column:(int)column
{
    for (WWPosition *position in _positions)
    {
        if (position.row == row && position.column == column)
            return position;
    }
    return nil;
}

@end
