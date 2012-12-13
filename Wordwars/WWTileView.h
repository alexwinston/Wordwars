//
//  WWTileView.h
//  Wordwars
//
//  Created by Alex Winston on 11/30/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWTile.h"

@interface WWTileView : UIView
{
    @private
    WWTile *_tile;
    CGPoint _rackCenterPoint;
    CGPoint _previousCenterPoint;
}
@property(nonatomic, readonly, strong) WWTile *tile;
@property(nonatomic, readwrite) CGPoint rackCenterPoint;
@property(nonatomic, readwrite) CGPoint previousCenterPoint;
- (id)initWithFrame:(CGRect)frame tile:(WWTile *)tile backgroundColor:(UIColor *)backgroundColor;
- (void)dragBegan;
- (void)dragEnded;
- (void)wobbleWithRepeatCount:(int)repeatCount;
- (void)wobble;
- (void)stopWobbling;
- (void)moveToRack;
@end
