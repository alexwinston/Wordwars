//
//  WWPlayer.h
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WWTurn.h"

@class WWTurn;

@interface WWPlayer : NSObject
{
    @private
    int _number;
    NSString *_name;
    NSMutableArray *_rack;
    int points;
}
@property(nonatomic, readonly, assign) int number;
@property(nonatomic, readwrite, strong) NSString *name;
@property(nonatomic, readonly, strong) NSMutableArray *rack;
@property(nonatomic, readwrite, assign) int points;
+ (WWPlayer *)playerWithNumber:(int)number name:(NSString *)name;
- (WWPlayer *)initWithNumber:(int)number name:(NSString *)name;
- (void)didEndTurn:(WWTurn *)turn;
- (void)shuffleRack;
@end
