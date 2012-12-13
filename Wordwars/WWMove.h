//
//  WWMove.h
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWPlayer.h"
#import "WWPosition.h"
#import "WWTile.h"

@class WWPosition;
@class WWPlayer;

@interface WWMove : NSObject
{
    @private
    WWPlayer *_player;
    WWTile *_tile;
    WWPosition *_position;
    
}
@property(nonatomic, readonly, strong) WWPlayer *player;
@property(nonatomic, readonly, strong) WWTile *tile;
@property(nonatomic, readonly, strong) WWPosition *position;
+ (WWMove *)moveWithPlayer:(WWPlayer *)player tile:(WWTile *)tile position:(WWPosition *)position;
- (WWMove *)initWithPlayer:(WWPlayer *)player tile:(WWTile *)tile position:(WWPosition *)position;
- (WWMove *)undo;
- (int)pointsForPlayer:(WWPlayer *)player;
@end
