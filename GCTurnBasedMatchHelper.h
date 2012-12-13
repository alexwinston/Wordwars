//
//  GCTurnBasedMatchHelper.h
//  Wordwars
//
//  Created by Alex Winston on 12/7/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCTurnBasedMatchHelperDelegate
- (void)handleAuthenticationChangedForPlayer:(GKPlayer *)localPlayer;
- (void)enterNewGame:(GKTurnBasedMatch *)match;
- (void)layoutMatch:(GKTurnBasedMatch *)match;
- (void)takeTurn:(GKTurnBasedMatch *)match;
- (void)recieveEndGame:(GKTurnBasedMatch *)match;
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;
@end

@interface GCTurnBasedMatchHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKTurnBasedEventHandlerDelegate>
{
@private
    BOOL _gameCenterAvailable;
    BOOL _userAuthenticated;
    UIViewController *_presentingViewController;
    
    GKTurnBasedMatch *_currentMatch;
    
    id <GCTurnBasedMatchHelperDelegate> _delegate;
}

@property (nonatomic, readwrite, strong) id <GCTurnBasedMatchHelperDelegate> delegate;
@property (nonatomic, readonly, assign) BOOL gameCenterAvailable;
@property (nonatomic, readonly, strong) GKTurnBasedMatch *currentMatch;

+ (GCTurnBasedMatchHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)authenticationChanged;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController;

@end
