//
//  UIAlertView+WWAdditions.m
//  Wordwars
//
//  Created by Alex Winston on 12/6/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "UIAlertView+WWAdditions.h"
#import <objc/runtime.h>

@implementation UIAlertView (WWAdditions)

- (id)initWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(UIAlertView *alertView, NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
	objc_setAssociatedObject(self, "blockCallback", [block copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
	if (self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil]) {
        
		id eachObject;
		va_list argumentList;
		if (otherButtonTitles) {
			[self addButtonWithTitle:otherButtonTitles];
			va_start(argumentList, otherButtonTitles);
			while ((eachObject = va_arg(argumentList, id))) {
				[self addButtonWithTitle:eachObject];
			}
			va_end(argumentList);
		}
        
        if (cancelButtonTitle) {
			[self addButtonWithTitle:cancelButtonTitle];
			self.cancelButtonIndex = [self numberOfButtons] - 1;
		}
	}
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	void (^block)(UIAlertView *alertView, NSUInteger buttonIndex) = objc_getAssociatedObject(self, "blockCallback");
	block(self, buttonIndex);
}

@end
