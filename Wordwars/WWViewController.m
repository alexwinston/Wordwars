//
//  WWViewController.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWViewController.h"

#import "WWGameCenterSerialization.h"
#import "WWGameViewController.h"

@implementation WWViewController

- (void)awakeFromNib
{
    NSLog(@"awakeFromNib");
    NSMutableArray *dictionary = [NSMutableArray array];
    NSString *dictionaryFile = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"twl06" ofType:@"dic"]
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];
    for (NSString *word in [dictionaryFile componentsSeparatedByString:@"\r\n"]) {
        [dictionary addObject:word];
    }
    
    _dictionary = dictionary;
    
    _matches = [NSMutableArray array];
    _matchGames = [NSMutableDictionary dictionary];
    
    [[GCTurnBasedMatchHelper sharedInstance] authenticateLocalUser];
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
}

- (void)viewDidLoad
{
    [_matchesTableView setDataSource:self];
    [_matchesTableView setDelegate:self];
}

#pragma mark - GCTurnBasedMatchHelperDelegate methods

- (void)handleAuthenticationChangedForPlayer:(GKPlayer *)localPlayer
{
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
            [_matches removeAllObjects];
            [_matches addObjectsFromArray:matches];
            
            for (GKTurnBasedMatch *match in matches) {
                NSLog(@"%@", [[NSString alloc] initWithData:match.matchData encoding:NSUTF8StringEncoding]);
                [_matchGames setObject:[WWGameCenterSerialization gameFromData:match.matchData dictionary:_dictionary] forKey:match.matchID];
            }

            [_matchesTableView reloadData];
        }];
    }
}

- (void)enterNewGame:(GKTurnBasedMatch *)match
{
    NSLog(@"enterNewGame:");

    NSMutableArray *players = [NSMutableArray array];
    [match.participants enumerateObjectsUsingBlock:^(GKTurnBasedParticipant *participant, NSUInteger index, BOOL *stop) {
        [players addObject:[WWPlayer playerWithName:@"Opponent"
                                            color:[UIColor colorWithRed:76/255.0 green:198/255.0 blue:251/255.0 alpha:1.0]]];
    }];
    
    WWGame *game = [WWGame gameWithDictionary:_dictionary board:[WWBoard boardWithRows:6 columns:6] players:players];
    game.currentTurn.player.name = [GKLocalPlayer localPlayer].alias;
    
    [_matches addObject:match];
    [_matchGames setObject:game forKey:match.matchID];
    [_matchesTableView reloadData];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_matches count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    if (indexPath.row == 0)
        cell.textLabel.text = @"+ New Game";
    else {
        GKTurnBasedMatch *match = [_matches objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = match.matchID;
    }
    
    return cell;
}

#pragma mark - UITablewViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [[GCTurnBasedMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
    } else {
        GKTurnBasedMatch *match = [_matches objectAtIndex:indexPath.row - 1];
        
        [self.navigationController pushViewController:[[WWGameViewController alloc] initWithMatch:match
                                                                                             game:[_matchGames objectForKey:match.matchID]]
                                             animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
