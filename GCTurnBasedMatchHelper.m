//
//  GCTurnBasedMatchHelper.m
//  Wordwars
//
//  Created by Alex Winston on 12/7/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "GCTurnBasedMatchHelper.h"

@implementation GCTurnBasedMatchHelper
@synthesize gameCenterAvailable=_gameCenterAvailable;
@synthesize currentMatch=_currentMatch;
@synthesize delegate=_delegate;


#pragma mark Initialization

static GCTurnBasedMatchHelper* sharedHelper = nil;
+ (GCTurnBasedMatchHelper*) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCTurnBasedMatchHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    //check for instance of GKLocalPlayer api
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    //check if the device is running 4.1 or later
    NSString* reqSysVer = @"4.1";
    NSString* curSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([curSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    return (gcClass && osVersionSupported);
}

- (id)init
{
    self = [super init];
    if (self) {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if (_gameCenterAvailable) {
            NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerDidChangeNotificationName object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated) {
        NSLog(@"authentication changed: player authenticated");
        _userAuthenticated = YES;
        
    }else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
        NSLog(@"authentication changed: player not authenticated");
        _userAuthenticated = NO;
    } else {
        NSLog(@"authentication unchanged");
    }
    
    [self.delegate handleAuthenticationChangedForPlayer:[GKLocalPlayer localPlayer]];
}

#pragma mark User functions
- (void)authenticateLocalUser {
    NSLog(@"authenticateLocalUser");
    
    if (!_gameCenterAvailable) return;
    
    void (^setGKEventHandlerDelegate)(NSError *) = ^ (NSError *error)
    {
        GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
        ev.delegate = self;
    };
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:setGKEventHandlerDelegate];
    } else {
        NSLog(@"Already authenticated!");
        setGKEventHandlerDelegate(nil);
    }
}
- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
{
    if (!_gameCenterAvailable) return;
    
    _presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = YES;
    
    [_presentingViewController presentModalViewController:mmvc
                                                animated:YES];
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController
                            didFindMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"turnBasedMatchmakerViewController:didFindMatch:%@", match.participants);
    [_presentingViewController dismissModalViewControllerAnimated:YES];
    _currentMatch = match;
    GKTurnBasedParticipant *firstParticipant = [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate == NULL) {
        // It's a new game!
        [_delegate enterNewGame:match];
    } else {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // It's your turn!
            [_delegate takeTurn:match];
        } else {
            // It's not your turn, just display the game state.
            [_delegate layoutMatch:match];
        }
    }
}

-(void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [_presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"has cancelled");
}

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController
                        didFailWithError:(NSError *)error {
    [_presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController
                      playerQuitForMatch:(GKTurnBasedMatch *)match
{
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];
    
    GKTurnBasedParticipant *part;
    for (int i = 0; i < [match.participants count]; i++) {
        part = [match.participants objectAtIndex:(currentIndex + 1 + i) % match.participants.count];
        if (part.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        }
    }
    NSLog(@"playerquitforMatch, %@, %@", match, match.currentParticipant);
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit
                            nextParticipant:part
                                  matchData:match.matchData
                          completionHandler:nil];
}

#pragma mark GKTurnBasedEventHandlerDelegate

-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite
{
    [_presentingViewController dismissModalViewControllerAnimated:YES];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.playersToInvite = playersToInvite;
    request.maxPlayers = 12;
    request.minPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    viewController.showExistingMatches = NO;
    viewController.turnBasedMatchmakerDelegate = self;
    
    [_presentingViewController presentModalViewController:viewController animated:YES];
}


-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Turn has happened");
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's the current match and it's our turn now
            _currentMatch = match;
            [_delegate takeTurn:match];
        } else {
            // it's the current match, but it's someone else's turn
            _currentMatch = match;
            [_delegate layoutMatch:match];
        }
    } else {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's not the current match and it's our turn now
            [_delegate sendNotice:@"It's your turn for another match"
                        forMatch:match];
        } else {
            // it's the not current match, and it's someone else's
            // turn
        }
    }
}

-(void)handleMatchEnded:(GKTurnBasedMatch *)match
{
    NSLog(@"Game has ended");
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        [_delegate recieveEndGame:match];
    } else {
        [_delegate sendNotice:@"Another Game Ended!" forMatch:match];
    }
}

@end
