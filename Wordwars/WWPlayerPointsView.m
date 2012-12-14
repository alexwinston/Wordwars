//
//  WWPlayerPointsView.m
//  Wordwars
//
//  Created by Alex Winston on 12/4/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWPlayerPointsView.h"

@implementation WWPlayerPointsView

@synthesize player=_player;

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor player:(WWPlayer *)player
{
    self = [super initWithFrame:frame];
    if (self) {
        _player = player;
        
        self.textAlignment = UITextAlignmentCenter;
        self.text = [NSString stringWithFormat:@"%d", player.points];
        self.textColor = [UIColor blackColor];
        self.backgroundColor = backgroundColor;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
