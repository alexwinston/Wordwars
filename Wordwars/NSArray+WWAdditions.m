//
//  NSArray+WWAdditions.m
//  Wordwars
//
//  Created by Alex Winston on 11/28/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "NSArray+WWAdditions.h"

@implementation NSArray (WWAdditions)

-(BOOL) isContiguous
{
    NSArray *sortedArray = [self sortedArrayUsingSelector:@selector(compare:)];
    
    id previousValue = [sortedArray objectAtIndex:0];
    for (int i = 1; i < self.count; i++) {
        if ([previousValue integerValue] + 1 != [[sortedArray objectAtIndex:i] integerValue])
            return NO;
        previousValue = [sortedArray objectAtIndex:i];
    }
    
    return YES;
}

- (BOOL)containsOnlyObjects:(NSArray *)array
{
    for (id value in self)
        if (![array containsObject:value])
            return NO;
    return YES;
}

- (BOOL)containsNoObjects:(NSArray *)array
{
    for (id value in self)
        if ([array containsObject:value])
            return NO;
    return YES;
}

@end

@implementation NSMutableArray (Shuffling)

- (NSMutableArray *)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return self;
}

@end
