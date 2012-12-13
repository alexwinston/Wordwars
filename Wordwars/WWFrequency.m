//
//  WWFrequency.m
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWFrequency.h"

@implementation WWFrequency

@synthesize cumulativeFrequencies=_cumulativeFrequencies;

+(WWFrequency *) frequencyWithDistributionFrequencies:(NSDictionary *)distributionFrequencies
{
    return [[WWFrequency alloc] initWithDistributionFrequencies:distributionFrequencies];
}

-(WWFrequency *) initWithDistributionFrequencies:(NSDictionary *)distributionFrequencies
{
    if (self = [super init])
    {
        _frequencyKeys = [[distributionFrequencies allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        _cumulativeFrequencies = [NSMutableDictionary dictionaryWithCapacity:_frequencyKeys.count];
        [_cumulativeFrequencies setObject:[distributionFrequencies objectForKey:[_frequencyKeys objectAtIndex:0]]
                                forKey:[_frequencyKeys objectAtIndex:0]];
        
        for (int i = 1; i < _frequencyKeys.count; i++) {
            double previousCumulativeFrequency = [[_cumulativeFrequencies objectForKey:[_frequencyKeys objectAtIndex:i - 1]] doubleValue];
            double cumulativeFrequency = previousCumulativeFrequency + [[distributionFrequencies objectForKey:[_frequencyKeys objectAtIndex:i]] doubleValue];
            [_cumulativeFrequencies setObject:[NSNumber numberWithDouble:cumulativeFrequency]
                                    forKey:[_frequencyKeys objectAtIndex:i]];
        }
    }
    return self;
}

-(NSString *) stringForCumulativeFrequency:(double)cumulativeFrequency
{
    for (int i = 0; i < _frequencyKeys.count - 1; i++)
    {
        if (cumulativeFrequency > [[_cumulativeFrequencies objectForKey:[_frequencyKeys objectAtIndex:i]] doubleValue]  &&
            cumulativeFrequency < [[_cumulativeFrequencies objectForKey:[_frequencyKeys objectAtIndex:i + 1]] doubleValue])
            return [_frequencyKeys objectAtIndex:i + 1];
    }
    return [_frequencyKeys objectAtIndex:0];
}

-(NSString *) stringForRandomCulmulativeFrequency
{
    return [self stringForCumulativeFrequency:((double)arc4random() / 0x100000000)];
}

@end
