//
//  WWTileView.m
//  Wordwars
//
//  Created by Alex Winston on 11/30/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "WWTileView.h"

#import <QuartzCore/QuartzCore.h>

@implementation WWTileView

@synthesize tile=_tile;
@synthesize rackCenterPoint=_rackCenterPoint;
@synthesize previousCenterPoint=_previousCenterPoint;

- (id)initWithFrame:(CGRect)frame tile:(WWTile *)tile backgroundColor:(UIColor *)backgroundColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        _tile = tile;
        
        self.backgroundColor = backgroundColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.0;
        
        UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        letterLabel.backgroundColor = [UIColor clearColor];
        letterLabel.font = [UIFont fontWithName:@"Helvetica" size:frame.size.width/1.75];
        letterLabel.textColor = [UIColor whiteColor];
        letterLabel.text = _tile.letter;
        [letterLabel sizeToFit];
        letterLabel.frame = CGRectIntegral(CGRectOffset(letterLabel.frame, (frame.size.width - letterLabel.frame.size.width)/2, (frame.size.height - letterLabel.frame.size.height)/2));
        [self addSubview:letterLabel];
        
        UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        pointLabel.backgroundColor = [UIColor clearColor];
        pointLabel.font = [UIFont fontWithName:@"Helvetica" size:frame.size.width/5];
        pointLabel.textColor = [UIColor whiteColor];
        pointLabel.text = [NSString stringWithFormat:@"%d", _tile.points];
        [pointLabel sizeToFit];
        pointLabel.frame = CGRectIntegral(CGRectOffset(pointLabel.frame, frame.size.width - frame.size.width/8 - pointLabel.frame.size.width, frame.size.height - frame.size.height/3));
        [self addSubview:pointLabel];
        
        _rackCenterPoint = self.center;
        _previousCenterPoint = _rackCenterPoint;
    }
    return self;
}

- (void)dragBegan
{
    self.layer.shadowOpacity = 0.2;
}

- (void)dragEnded
{
    self.layer.shadowOpacity = 0.0;
}

- (void)moveToRack
{
    [UIView animateWithDuration:0.25 animations:^{
        self.center = _rackCenterPoint;
        _previousCenterPoint = self.center;
        self.layer.shadowOpacity = 0.0;
    }];
}

- (void)wobble
{
    [self wobbleWithRepeatCount:HUGE_VALF];
}

- (void)wobbleWithRepeatCount:(int)repeatCount
{
    if (self.layer.animationKeys.count != 0)
        return;
    
    float Y_OFFSET = 2.0f;
    float X_OFFSET = 2.0f;
    float ANGLE_OFFSET = (M_PI_4 * 0.3f);
    
    CFTimeInterval offset = (double)arc4random() / (double)RAND_MAX;
    self.transform = CGAffineTransformRotate(self.transform, -ANGLE_OFFSET * 0.5);
    self.transform = CGAffineTransformTranslate(self.transform, -X_OFFSET * 0.5f, -Y_OFFSET * 0.5f);
    
    CABasicAnimation *tAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    tAnim.repeatCount=repeatCount;
    tAnim.byValue=[NSNumber numberWithFloat:X_OFFSET];
    tAnim.duration=0.07f;
    tAnim.autoreverses=YES;
    tAnim.timeOffset=offset;
    [self.layer addAnimation:tAnim forKey:@"shakePositionX"];
    
    CABasicAnimation *tyAnim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    tyAnim.repeatCount=repeatCount;
    tyAnim.byValue=[NSNumber numberWithFloat:Y_OFFSET];
    tyAnim.duration=0.06f;
    tyAnim.autoreverses=YES;
    tyAnim.timeOffset=offset;
    [self.layer addAnimation:tyAnim forKey:@"shakePositionY"];
    
    CABasicAnimation *rAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rAnim.delegate=self;
    rAnim.repeatCount=repeatCount;
    rAnim.byValue=[NSNumber numberWithFloat:ANGLE_OFFSET];
    rAnim.duration=0.15f;
    rAnim.autoreverses=YES;
    rAnim.timeOffset=offset;
    [self.layer addAnimation:rAnim forKey:@"shakeRotation"];
}

-(void)stopWobbling
{
    if (self.layer.animationKeys.count == 0)
        return;
    
    [self.layer removeAnimationForKey:@"shakePositionX"];
    [self.layer removeAnimationForKey:@"shakePositionY"];
    [self.layer removeAnimationForKey:@"shakeRotation"];
//    self.transform = CGAffineTransformIdentity;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.transform = CGAffineTransformIdentity;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
