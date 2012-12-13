//
//  WWGameViewConstraints.m
//  Wordwars
//
//  Created by Alex Winston on 12/4/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWGameViewConstraints.h"

const int kTileSpacing = 4;

@implementation WWGameViewConstraints

@synthesize tileCount=_tileCount;
@synthesize tileSize=_tileSize;
@synthesize rackRect=_rackRect;

- (WWGameViewConstraints *)initWithGame:(WWGame *)game screenRect:(CGRect)screenRect
{
    if (self = [super init]) {
        _game = game;
        _screenRect = screenRect;
        
        _tileCount = game.board.rows;
        _tileSize = CGSizeMake(floor((screenRect.size.width - kTileSpacing * (_tileCount - 1))  / (_tileCount + 0.5)),
                               floor((screenRect.size.width - kTileSpacing * (_tileCount - 1))  / (_tileCount + 0.5)));
        
        // Constrain the tile size to 1/6 of the height of the screen
        int maxTileSize = screenRect.size.height / 6;
        if (_tileSize.height > maxTileSize || _tileSize.width > maxTileSize)
            _tileSize = CGSizeMake(maxTileSize, maxTileSize);
        
        CGSize rackSize = CGSizeMake((_tileCount * _tileSize.width) + (kTileSpacing * (_tileCount - 1)),
                                     _tileSize.height);
        _rackRect = CGRectMake(floor((screenRect.size.width - rackSize.width) / 2),
                               floor(70),
                               rackSize.width,
                               rackSize.height);
        NSLog(@"%@", NSStringFromCGRect(_rackRect));
    }
    return self;
}

- (CGRect)frameForPlayerPointsWithPlayer:(WWPlayer *)player
{
    int width = 20;
    int height = 20;
    
    float framePadding = _screenRect.size.width / 3;
    
    float x = framePadding + ((framePadding / (_game.players.count + 1)) * ([_game playerNumberForPlayer:player] + 1) - (width / 2));
    float y = _screenRect.size.height / 24;
    return CGRectMake(x, y, width, height);
}

- (CGRect)frameForPlayerIndicatorWithPlayer:(WWPlayer *)player
{
    CGRect playerPointsRect = [self frameForPlayerPointsWithPlayer:player];
    
    int width = playerPointsRect.size.width / 3;
    int height = playerPointsRect.size.height / 3;
    
    float x = playerPointsRect.origin.x + (playerPointsRect.size.width / 2) - (width / 2);
    float y = playerPointsRect.origin.y + playerPointsRect.size.height + (height / 2);
    
    return CGRectMake(x, y, width, height);
}

- (CGRect)frameForTileAtIndex:(int)index
{
    int x = _rackRect.origin.x + ((_tileSize.width + kTileSpacing) * index);
    int y = _rackRect.origin.y;
    
    return CGRectMake(x, y, _tileSize.width, _tileSize.height);
}

- (CGRect)frameForPositionAtRow:(int)row column:(int)column
{
    int x = _rackRect.origin.x + ((_tileSize.width + kTileSpacing) * column);
    int y = (_rackRect.origin.y + _tileSize.height + (_tileSize.height / 3)) + ((_tileSize.height + kTileSpacing) * row);
    
    return CGRectMake(x, y, _tileSize.width, _tileSize.height);
}

- (BOOL)positionView:(WWPositionView *)positionView containsPoint :(CGPoint)point
{    
    CGRect positionRectWithSpacing = CGRectMake(positionView.frame.origin.x - (kTileSpacing / 2),
                                                positionView.frame.origin.y - (kTileSpacing / 2),
                                                positionView.frame.size.width + kTileSpacing,
                                                positionView.frame.size.height + kTileSpacing);
    return CGRectContainsPoint(positionRectWithSpacing, point);
}

@end
