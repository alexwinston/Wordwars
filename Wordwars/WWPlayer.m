//
//  WWPlayer.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWPlayer.h"
#import "NSArray+WWAdditions.h"
#import "UIColor+WWAdditions.h"

@implementation WWPlayer

@synthesize name=_name;
@synthesize color=_color;
@synthesize rack=_rack;
@synthesize points=_points;

+(WWPlayer *) playerWithName:(NSString *)name
{
    return [[WWPlayer alloc] initWithName:name color:nil];
}

+(WWPlayer *) playerWithName:(NSString *)name color:(UIColor *)color
{
    return [[WWPlayer alloc] initWithName:name color:color];
}

-(WWPlayer *) initWithName:(NSString *)name color:(UIColor *)color
{
    if (self = [super init])
    {
        _name = name;
        _color = color;
        _rack = [NSMutableArray array];
        _points = 0;
    }
    return self;
}

- (void)didEndTurn:(WWTurn *)turn
{
    if (_color != nil)
        _color = [_color colorByDarkeningColor:0.02f];
}

-(void) shuffleRack
{
    [self.rack shuffle];
}

@end
