//
// @author Levi Eggert
//

#import "FLMPLayer.h"
#import "FLMPKeyframe.h"

@implementation FLMPLayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

-(void)dealloc
{
    self.layerName = nil;
    self.keyframes = nil;
}

#pragma mark private methods

-(void)addKeyframe:(FLMPKeyframe *)keyframe
{
    if (keyframe == nil)
    {
        return;
    }
    
    if (self.keyframes == nil)
    {
        self.keyframes = [[NSMutableArray alloc] init];
    }
    
    [self.keyframes addObject:keyframe];
}

#pragma mark public methods

-(NSInteger)getTotalFrames
{
    if (self.keyframes != nil)
    {
        return [self.keyframes count];
    }
    
    return 0;
}

-(void)addKeyframesWithTextureName:(NSString *)textureName duration:(NSInteger)duration position:(CGPoint)position scale:(CGPoint)scale skew:(CGPoint)skew pivot:(CGPoint)pivot alpha:(CGFloat)alpha ease:(NSInteger)ease tween:(BOOL)tween
{
    FLMPKeyframe *keyframe = nil;
    
    
    if (self.keyframes != nil && [self.keyframes count] > 0)
    {
        keyframe = [self.keyframes lastObject];
        
        if (keyframe.tween)
        {
            NSInteger keyframeDuration = keyframe.duration;
            NSInteger startFrame = [self.keyframes count] - keyframeDuration;
            NSInteger endFrame = startFrame + keyframeDuration;
            CGFloat interped = 0.0f;
            NSInteger keyframeEase = 0;
            
            for (NSInteger i = startFrame; i < endFrame; ++i)
            {
                keyframe = [self.keyframes objectAtIndex:i];
                
                interped = (CGFloat)(i - startFrame) / (CGFloat)keyframeDuration;
                keyframeEase = keyframe.ease;
                
                if (keyframeEase != 0)
                {
                    CGFloat t = 0.0f;
                    if (keyframeEase < 0)
                    {
                        // Ease in
                        CGFloat inv = 1 - interped;
                        t = 1 - inv * inv;
                        keyframeEase = keyframeEase * -1;
                    }
                    else
                    {
                        // Ease out
                        t = interped * interped;
                    }
                    
                    interped = (CGFloat)keyframeEase * t + (CGFloat)(1 - keyframeEase) * interped;                    
                }
                
                keyframe.position = CGPointMake(keyframe.position.x + (position.x - keyframe.position.x) * interped,
                                                keyframe.position.y + (position.y - keyframe.position.y) * interped);
                
                keyframe.scale = CGPointMake(keyframe.scale.x + (scale.x - keyframe.scale.x) * interped,
                                             keyframe.scale.y + (scale.y - keyframe.scale.y) * interped);
                
                keyframe.skew = CGPointMake(keyframe.skew.x + (skew.x - keyframe.skew.x) * interped,
                                             keyframe.skew.y + (skew.y - keyframe.skew.y) * interped);
                
                keyframe.alpha = keyframe.alpha + (alpha - keyframe.alpha) * interped;
            }
        }
    }
    
    for (NSInteger i = 0; i < duration; ++i)
    {
        keyframe = [[FLMPKeyframe alloc] init];
        
        keyframe.textureName = textureName;
        keyframe.duration = duration;
        keyframe.position = CGPointMake(position.x, position.y);
        keyframe.scale = CGPointMake(scale.x, scale.y);
        keyframe.skew = CGPointMake(skew.x, skew.y);
        keyframe.pivot = CGPointMake(pivot.x, pivot.y);
        keyframe.alpha = alpha;
        keyframe.ease = ease;
        keyframe.tween = tween;
        
        [self addKeyframe:keyframe];
    }
}

-(CGAffineTransform)getTransformAtFrame:(NSInteger)frame
{
    FLMPKeyframe *keyframe = nil;
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat scaleX = 0.0f;
    CGFloat scaleY = 0.0f;
    CGFloat skewX = 0.0f;
    CGFloat skewY = 0.0f;
    CGFloat pivotX = 0.0f;
    CGFloat pivotY = 0.0f;
    CGFloat a = 0.0f;
    CGFloat b = 0.0f;
    CGFloat c = 0.0f;
    CGFloat d = 0.0f;
    CGFloat sinX = 0.0f;
    CGFloat cosX = 0.0f;
    CGFloat sinY = 0.0f;
    CGFloat cosY = 0.0f;
    
    if (self.keyframes != nil && frame < [self.keyframes count])
    {
        keyframe = [self.keyframes objectAtIndex:frame];
        
        x = keyframe.position.x - 1.0;
        y = keyframe.position.y - 1.0;
        scaleX = keyframe.scale.x;
        scaleY = keyframe.scale.y;
        skewX = keyframe.skew.x;
        skewY = keyframe.skew.y;
        pivotX = keyframe.pivot.x - 1.0;
        pivotY = keyframe.pivot.y - 1.0;
        
        a = 1.0;
        b = 0.0;
        c = 0.0;
        d = 1.0;
        
        if (scaleX != 1)
        {
            a *= scaleX;
            c *= scaleX;
        }
        
        if (scaleY != 1)
        {
            b *= scaleY;
            d *= scaleY;
        }
        
        if (!(skewX == 0.0 && skewY == 0.0))
        {
            sinX = sinf(skewX);
            cosX = cosf(skewX);
            sinY = sinf(skewY);
            cosY = cosf(skewY);
            
            a = a * cosY - b * sinX;
            b = a * sinY + b * cosX;
            c = c * cosY - d * sinX;
            d = c * sinY + d * cosX;
        }
        
        transform.tx = x;
        transform.ty = y;
        transform.a = a;
        transform.b = b;
        transform.c = c;
        transform.d = d;
    }
    
    return transform;
}

@end
