//
//  WWTile.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWTile.h"

@implementation WWTile

@synthesize letter=_letter;
@synthesize points=_points;

+(WWTile *) tileWithLetter:(NSString *)letter points:(int)points
{
    return [[WWTile alloc] initWithLetter:letter points:points];
}

-(WWTile *) initWithLetter:(NSString *)letter points:(int)points
{
    if (self = [super init])
    {
        _letter = letter;
        _points = points;
    }
    
    return self;
}

@end
