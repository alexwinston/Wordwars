//
//  WWPositionView.h
//  Wordwars
//
//  Created by Alex Winston on 12/2/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WWPosition.h"

@interface WWPositionView : UIView
{
    @private
    WWPosition *_position;
}
@property(nonatomic, readonly, strong) WWPosition *position;
- (id)initWithFrame:(CGRect)frame position:(WWPosition *)position;
@end
