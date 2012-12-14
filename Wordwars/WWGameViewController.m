//
//  WWGameControllerViewController.m
//  Wordwars
//
//  Created by Alex Winston on 12/6/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWGameViewController.h"

#import "NSArray+WWAdditions.h"
#import "UIAlertView+WWAdditions.h"
#import "UIColor+WWAdditions.h"

#import "WWGameCenterSerialization.h"

@interface WWGameViewController ()
@end

@implementation WWGameViewController

@synthesize dragObject;
@synthesize touchOffset;

+ (UIColor *)colorForPlayer:(WWPlayer *)player
{
    static NSArray *playerColors = nil;
    if (!playerColors) {
        playerColors = @[
        [UIColor colorWithRed:76/255.0 green:198/255.0 blue:251/255.0 alpha:1.0],
        [UIColor colorWithRed:220/255.0 green:41/255.0 blue:43/255.0 alpha:1.0],
        [UIColor colorWithRed:220/255.0 green:41/255.0 blue:43/255.0 alpha:1.0],
        [UIColor colorWithRed:220/255.0 green:41/255.0 blue:43/255.0 alpha:1.0] ];
    }
    
    return [playerColors objectAtIndex:player.number];
}

+ (UIColor *)colorForTurn:(WWTurn *)turn player:(WWPlayer *)player
{
    return [[WWGameViewController colorForPlayer:player] colorByDarkeningColor:0.02 * turn.number];
}

- (WWGameViewController *)initWithMatch:(GKTurnBasedMatch *)match game:(WWGame *)game
{
    NSLog(@"initWithGame:");
    if (self = [super init]) {
        _match = match;
        _game = game;
        _game.delegate = self;
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.backgroundColor = [UIColor whiteColor];
    
    self.view = view;
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    NSLog(@"%@", self.navigationController);
    [super viewDidLoad];
    
    _gameViewConstraints = [[WWGameViewConstraints alloc] initWithGame:_game
                                                            screenRect:[[UIScreen mainScreen] applicationFrame]];
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    
    _tileViews = [NSMutableArray arrayWithCapacity:_gameViewConstraints.tileCount];
    [self rackTilesForTurn: _game.currentTurn];
    
    _positionViews = [NSMutableArray arrayWithCapacity:_gameViewConstraints.tileCount * _gameViewConstraints.tileCount];
    for (int row = 0; row < _gameViewConstraints.tileCount; row++) {
        for (int column = 0; column < _gameViewConstraints.tileCount; column++) {
            WWPositionView *positionView = [[WWPositionView alloc] initWithFrame:[_gameViewConstraints frameForPositionAtRow:row column:column]
                                                                        position:[_game.board positionAtRow:row column:column]];
            positionView.backgroundColor = [UIColor lightGrayColor];
            positionView.alpha = 0.1;
            
            [self.view addSubview:positionView];
            [_positionViews addObject:positionView];
        }
    }
    
    _clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(floor(screenRect.size.width / 3.6), screenRect.size.height - (screenRect.size.height / 12), 0, 0)];
    _clearLabel.hidden = YES;
    _clearLabel.text = @"Clear";
    _clearLabel.textColor = [UIColor blackColor];
    _clearLabel.userInteractionEnabled = YES;
    [_clearLabel sizeToFit];
    [_clearLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearTouched)]];
    [self.view addSubview:_clearLabel];
    
    _shuffleLabel = [[UILabel alloc] initWithFrame:CGRectMake(floor(screenRect.size.width / 3.9), screenRect.size.height - (screenRect.size.height / 12), 0, 0)];
    _shuffleLabel.text = @"Shuffle";
    _shuffleLabel.textColor = [UIColor blackColor];
    _shuffleLabel.userInteractionEnabled = YES;
    [_shuffleLabel sizeToFit];
    [_shuffleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shuffleLabelTouched)]];
    [self.view addSubview:_shuffleLabel];
    
    UILabel *submitLabel = [[UILabel alloc] initWithFrame:CGRectMake(floor(screenRect.size.width / 1.75), screenRect.size.height - (screenRect.size.height / 12), 0, 0)];
    submitLabel.text = @"Submit";
    submitLabel.textColor = [UIColor blackColor];
    submitLabel.userInteractionEnabled = YES;
    [submitLabel sizeToFit];
    [submitLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitTouched)]];
    [self.view addSubview:submitLabel];
    
    _playerPointLabels = [NSMutableDictionary dictionaryWithCapacity:_game.players.count];
    _playersLastMoveTileViews = [NSMutableDictionary dictionaryWithCapacity:_game.players.count];
    
    for (WWPlayer *player in _game.players) {
        WWPlayerPointsView *playerPointsLabel = [[WWPlayerPointsView alloc] initWithFrame:[_gameViewConstraints frameForPlayerPointsWithPlayer:player]
                                                                          backgroundColor:[WWGameViewController colorForPlayer:player]
                                                                                   player:player];
        playerPointsLabel.userInteractionEnabled = YES;
        [playerPointsLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerPointsTouched:)]];
        [self.view addSubview:playerPointsLabel];
        
        [_playerPointLabels setObject:playerPointsLabel forKey:player.name];
        [_playersLastMoveTileViews setObject:[NSMutableArray array] forKey:player.name];
    }
    
    _currentPlayerIndicatorView = [[UIView alloc] initWithFrame:[_gameViewConstraints frameForPlayerIndicatorWithPlayer:_game.currentTurn.player]];
    _currentPlayerIndicatorView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_currentPlayerIndicatorView];
    
    // Initialize any played turns for this game
    for (WWTurn *turn in _game.playedTurns) {
        for (WWMove *move in turn.moves) {
            [self.view addSubview:[[WWTileView alloc] initWithFrame:[_gameViewConstraints frameForPositionAtRow:move.position.row column:move.position.column]
                                                               tile:move.tile
                                                    backgroundColor:[WWGameViewController colorForTurn:turn player:turn.player]]];
        }
    }
}

- (void)rackTilesForTurn:(WWTurn *)turn {
    for (int i = 0; i < _gameViewConstraints.tileCount; i++) {
        WWTileView *tileView = [[WWTileView alloc] initWithFrame:[_gameViewConstraints frameForTileAtIndex:i]
                                                            tile:[turn.player.rack objectAtIndex:i]
                                                 backgroundColor:[WWGameViewController colorForTurn:turn player:turn.player]];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tileViewDoubleTapped:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.delaysTouchesEnded = NO;
        [tileView addGestureRecognizer: doubleTap];
        
        [self.view addSubview:tileView];
        
        [_tileViews addObject:tileView];
    }
}

- (void)undoMovedTileView:(WWTileView *)tileView
{
    [_game.currentTurn removeMovesWithTile:tileView.tile];
    [tileView moveToRack];
    
    self.dragObject = nil;
}

- (void)undoMovedTileViews
{
    [_game undoCurrentTurn];
    for (WWTileView *tileView in _tileViews) {
        [tileView moveToRack];
    }
}

- (void)tileViewDoubleTapped:(UIGestureRecognizer *)gestureRecognier
{
    [self undoMovedTileView:(WWTileView *)gestureRecognier.view];
}

- (void)playerPointsTouched:(UIGestureRecognizer *)gestureRecognizer
{
    WWPlayerPointsView *playerPointsView = (WWPlayerPointsView *)gestureRecognizer.view;
    
    for (WWTileView *tileView in [_playersLastMoveTileViews objectForKey:playerPointsView.player.name])
        [tileView wobbleWithRepeatCount:5];
}

- (void)shuffleLabelTouched
{
    [self shuffleTileViews];
}

- (void)clearTouched
{
    [self undoMovedTileViews];
}

- (void)resign
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitTouched
{
    // Submitting without any moves prompts to skip turn or swap tiles
    if (!_game.currentTurn.hasMoves) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No tiles played"
                                                        message:@"Do you want to end your turn?"
                                                completionBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
                                                    if (buttonIndex == 0)
                                                        [_game swapTilesForCurrentTurn];
                                                    else if (buttonIndex == 1)
                                                        [_game skipCurrentTurn];
                                                    else if (buttonIndex == 2)
                                                        [self resign];
                                                    else if (buttonIndex == alertView.cancelButtonIndex)
                                                        NSLog(@"Canceled");
                                                }
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Swap Tiles", @"Skip Turn", @"Resign", nil];
        [alert show];
        
        return;
    }
    
    if (![_game playCurrentTurn]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid word or tile placement"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)updatePlayerPointLabels
{
    for (WWPlayer *player in _game.players) {
        UILabel *playerPointsLabel = [_playerPointLabels objectForKey:player.name];
        playerPointsLabel.text = [NSString stringWithFormat:@"%d", player.points];
    }
}

- (void)shuffleTileViews
{
    if (!_game.currentTurn.hasMoves) {
        NSMutableArray *shuffledCenterPoints = [NSMutableArray array];
        [[[NSMutableArray arrayWithArray:_tileViews] shuffle] enumerateObjectsUsingBlock:^(WWTileView *tileView, NSUInteger index, BOOL *stop)
         {
             [shuffledCenterPoints addObject:[NSValue valueWithCGPoint:tileView.rackCenterPoint]];
         }];
        
        [_tileViews enumerateObjectsUsingBlock:^(WWTileView *tileView, NSUInteger index, BOOL *stop)
         {
             tileView.rackCenterPoint = [[shuffledCenterPoints objectAtIndex:index] CGPointValue];
             [tileView moveToRack];
         }];
    }
}

- (void)showHideClearShuffleLabels:(NSArray *)moves
{
    if (moves.count > 0) {
        _clearLabel.hidden = NO;
        _shuffleLabel.hidden = YES;
    } else {
        _clearLabel.hidden = YES;
        _shuffleLabel.hidden = NO;
    }
}

#pragma mark - UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
        for (WWTileView *iView in self.view.subviews) {
            if (iView.userInteractionEnabled && [iView isMemberOfClass:[WWTileView class]] && CGRectContainsPoint([iView frame], touchPoint)) {
                [self.view bringSubviewToFront:iView];
                
                self.dragObject = iView;
                [self.dragObject dragBegan];
                
                self.touchOffset = CGPointMake(touchPoint.x - iView.center.x,
                                               touchPoint.y - iView.center.y);
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.dragObject != nil) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
        self.dragObject.center = CGPointMake(touchPoint.x - self.touchOffset.x, touchPoint.y - self.touchOffset.y);
        
        BOOL positionContainsTouchPoint = NO;
        for (WWPositionView *positionView in _positionViews) {
            if ([_gameViewConstraints positionView:positionView containsPoint:touchPoint]) {
                if (![_game.currentTurn canMoveTile:self.dragObject.tile toPosition:positionView.position]) {
                    [self.dragObject wobble];
                    positionContainsTouchPoint = YES;
                }
                break;
            }
        }
        
        if (!positionContainsTouchPoint)
            [self.dragObject stopWobbling];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.dragObject != nil) {
        CGPoint touchesEndedCenterPoint = self.dragObject.previousCenterPoint;
        
        CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
        if (CGRectContainsPoint(_gameViewConstraints.rackRect, touchPoint)) {
            touchesEndedCenterPoint = self.dragObject.rackCenterPoint;
            [_game.currentTurn removeMovesWithTile:self.dragObject.tile];
        }
        
        for (WWPositionView *positionView in _positionViews) {
            if ([_gameViewConstraints positionView:positionView containsPoint:touchPoint]) {
                if ([_game.currentTurn moveTile:self.dragObject.tile toPosition:positionView.position]) {
                    touchesEndedCenterPoint = positionView.center;
                    break;
                }
            }
        }
        
        [self.dragObject stopWobbling];
        [UIView animateWithDuration:0.25 animations:^{
            self.dragObject.center = touchesEndedCenterPoint;
        }];
        self.dragObject.previousCenterPoint = self.dragObject.center;
        [self.dragObject dragEnded];
        self.dragObject = nil;
    }
}

- (void)endedTurn:(WWTurn *)turn forPlayer:(WWPlayer *)player
{
    NSLog(@"endedTurn:forPlayer:");
    // Remove the last tiles played for this player
    [[_playersLastMoveTileViews objectForKey:player.name] removeAllObjects];
    
    // Disable interaction with the tiles played during the last turn
    for (WWTileView *tileView in _tileViews) {
        tileView.userInteractionEnabled = NO;
        // Remove unplayed rack tiles from the view, otherwise add them to the list of last tiles played
        if (![turn containsTile:tileView.tile])
            [tileView removeFromSuperview];
        else
            [[_playersLastMoveTileViews objectForKey:player.name] addObject:tileView];
    }
    [_tileViews removeAllObjects];

}

#pragma mark - WWGameDelegate methods

- (void)game:(WWGame *)game didChangeMoves:(NSArray *)moves forTurn:(WWTurn *)turn
{
    NSLog(@"game:didChangeMoves:forTurn:");
    [self updatePlayerPointLabels];
    [self showHideClearShuffleLabels:moves];
}

- (void)game:(WWGame *)game didStartTurn:(WWTurn *)turn forPlayer:(WWPlayer *)player
{
    NSLog(@"game:didStartTurn:forPlayer:");
    [self rackTilesForTurn:turn];
    
    // Update the current player indicator
    _currentPlayerIndicatorView.frame = [_gameViewConstraints frameForPlayerIndicatorWithPlayer:player];
    
    [self showHideClearShuffleLabels:turn.moves];
}

- (void)game:(WWGame *)game didEndTurn:(WWTurn *)turn forPlayer:(WWPlayer *)player
{
    NSLog(@"game:didEndTurn:forPlayer:");
    [_match endTurnWithNextParticipant:[_match.participants objectAtIndex:game.currentTurn.player.number]
                             matchData:[WWGameCenterSerialization dataFromGame:game]
                     completionHandler:^(NSError *error) {
                         if (error) {
                             NSLog(@"endTurnWithNextParticipant:%@", [error localizedDescription]);
                         } else {
                             // TODO Refactor because it is called after game:didStartTurn:forPlayer:
                             [self endedTurn:turn forPlayer:player];
                         }
                     }];
}

- (void)gameDidFinish:(WWGame *)game withWinningPlayers:(NSArray *)players points:(int)points
{
    // TODO Disable action labels when game is finished
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                    message:[NSString stringWithFormat:@"%@ won with %d points", [[players valueForKeyPath:@"name"] componentsJoinedByString:@"," ], points]
                                            completionBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
                                                if (buttonIndex == alertView.cancelButtonIndex)
                                                    [self.navigationController popViewControllerAnimated:YES];
                                            }
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIEventSubtypeMotionShake

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self shuffleTileViews];
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
