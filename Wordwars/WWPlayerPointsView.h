//
//  WWPlayerPointsView.h
//  Wordwars
//
//  Created by Alex Winston on 12/4/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WWPlayer.h"

@interface WWPlayerPointsView : UILabel
{
    @private
    WWPlayer *_player;
}
@property(nonatomic, readonly, strong) WWPlayer *player;
- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor player:(WWPlayer *)player;
@end
