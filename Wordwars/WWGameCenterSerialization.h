//
//  WWGameCenterSerialization.h
//  Wordwars
//
//  Created by Alex Winston on 12/11/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//
// https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Archiving/Articles/serializing.html#//apple_ref/doc/uid/20000952-BABBEJEE

#import <Foundation/Foundation.h>

#import "WWGame.h"

@interface WWGameCenterSerialization : NSObject
+ (NSData *)dataFromGame:(WWGame *)game;
+ (WWGame *)gameFromData:(NSData *)data dictionary:(NSArray *)dictionary;
@end
