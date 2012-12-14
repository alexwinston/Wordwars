//
//  WWPlayer.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWPlayer.h"

#import "NSArray+WWAdditions.h"

@implementation WWPlayer

@synthesize number=_number;
@synthesize name=_name;
@synthesize rack=_rack;
@synthesize points=_points;

+(WWPlayer *) playerWithNumber:(int)number name:(NSString *)name
{
    return [[WWPlayer alloc] initWithNumber:number name:name];
}

-(WWPlayer *) initWithNumber:(int)number name:(NSString *)name
{
    if (self = [super init])
    {
        _number = number;
        _name = name;
        _rack = [NSMutableArray array];
        _points = 0;
    }
    return self;
}

- (void)didEndTurn:(WWTurn *)turn
{
}

-(void) shuffleRack
{
    [self.rack shuffle];
}

@end
