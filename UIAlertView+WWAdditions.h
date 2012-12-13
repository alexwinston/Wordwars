//
//  UIAlertView+WWAdditions.h
//  Wordwars
//
//  Created by Alex Winston on 12/6/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (WWAdditions)
- (id)initWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(UIAlertView *alertView, NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
@end