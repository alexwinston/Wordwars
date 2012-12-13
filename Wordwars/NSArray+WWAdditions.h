//
//  NSArray+WWAdditions.h
//  Wordwars
//
//  Created by Alex Winston on 11/28/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (WWAdditions)
- (BOOL)isContiguous;
- (BOOL)containsOnlyObjects:(NSArray *)array;
- (BOOL)containsNoObjects:(NSArray *)array;
@end

@interface NSMutableArray (WWAdditions)
- (NSMutableArray *)shuffle;
@end
