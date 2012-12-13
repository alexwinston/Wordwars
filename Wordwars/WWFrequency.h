//
//  WWFrequency.h
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WWFrequency : NSObject
{
    @private
    NSMutableDictionary *_cumulativeFrequencies;
    NSArray *_frequencyKeys;
}
@property (nonatomic, readonly, strong) NSDictionary *cumulativeFrequencies;
+(WWFrequency *) frequencyWithDistributionFrequencies:(NSDictionary *)distributionFrequencies;
-(WWFrequency *) initWithDistributionFrequencies:(NSDictionary *)distributionFrequencies;
-(NSString *) stringForCumulativeFrequency:(double)cumulativeFrequency;
-(NSString *) stringForRandomCulmulativeFrequency;
@end
