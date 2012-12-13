//
//  WWTile.h
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WWTile : NSObject
{
    @private
    NSString *_letter;
    int _points;
}
@property(nonatomic, readonly, strong) NSString *letter;
@property(nonatomic, readonly) int points;
+(WWTile *) tileWithLetter:(NSString *)letter points:(int)points;
-(WWTile *) initWithLetter:(NSString *)letter points:(int)points;
@end
