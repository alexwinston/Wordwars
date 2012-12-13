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
    NSString *_name;
    UIColor *_color;
    NSMutableArray *_rack;
    int points;
}
@property(nonatomic, readwrite, strong) NSString *name;
@property(nonatomic, readwrite, strong) UIColor *color;
@property(nonatomic, readonly, strong) NSMutableArray *rack;
@property(nonatomic, readwrite, assign) int points;
+ (WWPlayer *)playerWithName:(NSString *)name;
+ (WWPlayer *)playerWithName:(NSString *)name color:(UIColor *)color;
- (WWPlayer *)initWithName:(NSString *)name color:(UIColor *)color;
- (void)didEndTurn:(WWTurn *)turn;
- (void)shuffleRack;
@end
