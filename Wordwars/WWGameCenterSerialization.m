//
//  WWGameCenterSerialization.m
//  Wordwars
//
//  Created by Alex Winston on 12/11/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWGameCenterSerialization.h"
#import "WWPlayer.h"

@implementation WWGameCenterSerialization
+ (NSData *)dataFromGame:(WWGame *)game
{
    NSMutableString *stringData = [NSMutableString string];
    [stringData appendFormat:@"%d,%d:", game.board.rows, game.board.columns];
    
    [game.players enumerateObjectsUsingBlock:^(WWPlayer *player, NSUInteger index, BOOL *stop) {
        [stringData appendFormat:@"%@,",player.name];
        [stringData appendString:[[player valueForKeyPath:@"rack.letter"] componentsJoinedByString:@""]];
        [stringData appendString:game.players.count - 1 != index ? @";" : @":"];
    }];
    [game.playedTurns enumerateObjectsUsingBlock:^(WWTurn *turn, NSUInteger index, BOOL *stop) {
        if ([turn positions].count >= 2) {
            [stringData appendString:[turn word]];
            [stringData appendString:@","];
            
            NSArray *positions = [turn positions];
            WWPosition *firstPosition = [positions objectAtIndex:0];
            WWPosition *lastPosition = [positions lastObject];
            [stringData appendFormat:@"%d%d%d%d", firstPosition.row, firstPosition.column, lastPosition.row, lastPosition.column];
        }
        [stringData appendString:game.playedTurns.count - 1 != index ? @";" : @""];
    }];
    NSLog(@"%@", stringData);
    return [stringData dataUsingEncoding:NSUTF8StringEncoding];
}

+ (WWGame *)gameFromData:(NSData *)data dictionary:(NSArray *)dictionary
{
    NSArray *dataStrings = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString: @":"];
    NSArray *boardStrings = [[dataStrings objectAtIndex:0] componentsSeparatedByString:@","];
    WWBoard *board = [WWBoard boardWithRows:[[boardStrings objectAtIndex:0] integerValue]
                                    columns:[[boardStrings objectAtIndex:1] integerValue]];
    
    NSArray *playerStrings = [[dataStrings objectAtIndex:1] componentsSeparatedByString:@";"];
    NSMutableArray *players = [NSMutableArray array];
    for (NSString *playerString in playerStrings) {
        NSArray *playerDetailStrings = [playerString componentsSeparatedByString:@","];
        
        NSString *playerNameString = [playerDetailStrings objectAtIndex:0];
        WWPlayer *player = [WWPlayer playerWithName:playerNameString];
        
        NSString *playerRackString = [playerDetailStrings objectAtIndex:1];
        for (int i = 0; i < [playerRackString length]; i++) {
            [player.rack addObject:[WWGame tileWithLetter:[NSString stringWithFormat:@"%c", [playerRackString characterAtIndex:i]]]];
        }
        
        [players addObject:player];
    }
    
    WWGame *game = [WWGame gameWithDictionary:dictionary board:board players:players];
    
    NSArray *turnStrings = [[dataStrings objectAtIndex:2] componentsSeparatedByString:@";"];
    for (NSString *turnString in turnStrings) {
        if ([turnString isEqualToString:@""])
            [game skipCurrentTurn];
        else {
            NSArray *turnDetailStrings = [turnString componentsSeparatedByString:@","];
            
            NSString *turnLettersString = [turnDetailStrings objectAtIndex:0];
            NSRange turnLettersRange = {0, 1};
            NSMutableArray *turnLetters = [NSMutableArray array];
            for (int i = 0; i < [turnLettersString length]; i++) {
                turnLettersRange.location = i;
                [turnLetters addObject:[turnLettersString substringWithRange:turnLettersRange]];
            }
            
            NSString *turnPositionsString = [turnDetailStrings objectAtIndex:1];
            NSRange turnPositionsRange = {0, 1};
            NSMutableArray *turnPositions = [NSMutableArray array];
            for (int i = 0; i < [turnPositionsString length]; i++) {
                turnPositionsRange.location = i;
                [turnPositions addObject:[turnPositionsString substringWithRange:turnPositionsRange]];
            }
            
            int turnPositionRowStart = [[turnPositions objectAtIndex:0] integerValue];
            int turnPositionColumnStart = [[turnPositions objectAtIndex:1] integerValue];
            int turnPositionRowEnd = [[turnPositions objectAtIndex:2] integerValue];
            int turnPositionColumnEnd = [[turnPositions objectAtIndex:3] integerValue];
            
            int currentLetter = 0;
            for (int row = turnPositionRowStart; row <= turnPositionRowEnd; row++) {
                for (int column = turnPositionColumnStart; column <= turnPositionColumnEnd; column++) {
                    [[game currentTurn] moveTile:[WWGame tileWithLetter:[turnLetters objectAtIndex:currentLetter++]]
                                      toPosition:[game positionAtRow:row column:column]];
                }
            }
            
            [game playCurrentTurn];
        }
    }

    return game;
}

@end
