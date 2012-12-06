//
//  WWGameControllerViewController.h
//  Wordwars
//
//  Created by Alex Winston on 12/6/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WWViewController.h"

#import "WWGame.h"
#import "WWPlayerPointsView.h"
#import "WWPositionView.h"
#import "WWTile.h"

@protocol WWGameViewControllerDelegate <NSObject>
@end

@interface WWGameViewController : UIViewController <WWGameDelegate>
{
@private
    WWGame *_game;
    WWGameViewConstraints *_gameViewConstraints;
    NSMutableArray *_tileViews;
    NSMutableArray *_positionViews;
    NSMutableDictionary *_playerPointLabels;
    NSMutableDictionary *_playersLastMoveTileViews;
    UIView *_currentPlayerIndicatorView;
    UILabel *_shuffleLabel;
    UILabel *_clearLabel;
}
@property (nonatomic, strong) WWTileView *dragObject;
@property (nonatomic, assign) CGPoint touchOffset;
- (WWGameViewController *)initWithGame:(WWGame *)game;
@end