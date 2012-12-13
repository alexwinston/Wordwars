//
//  WWGameViewConstraints.h
//  Wordwars
//
//  Created by Alex Winston on 12/4/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WWGame.h"
#import "WWPositionView.h"

@interface WWGameViewConstraints : NSObject
{
    @private
    WWGame *_game;
    CGRect _screenRect;
    int _tileCount;
    CGSize _tileSize;
    CGRect _rackRect;
}
@property(nonatomic, readonly, assign) int tileCount;
@property(nonatomic, readonly, assign) CGSize tileSize;
@property(nonatomic, readonly, assign) CGRect rackRect;
- (WWGameViewConstraints *)initWithGame:(WWGame *)game screenRect:(CGRect)screenRect;
- (CGRect)frameForPositionAtRow:(int)row column:(int)column;
- (CGRect)frameForTileAtIndex:(int)index;
- (CGRect)frameForPlayerPointsWithPlayer:(WWPlayer *)player;
- (CGRect)frameForPlayerIndicatorWithPlayer:(WWPlayer *)player;
- (BOOL)positionView:(WWPositionView *)positionView containsPoint:(CGPoint)point;
@end
