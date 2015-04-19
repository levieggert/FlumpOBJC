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
    _imageView = nil;
    _imagesDictionary = nil;
    _keyframes = nil;
}

#pragma mark private methods

-(void)addKeyframeInternal:(FLMPKeyframe *)flumpKeyFrame
{
    if (!_keyframes)
    {
        _keyframes = [[NSMutableArray alloc] init];
        _numFrames = 0;
    }
    
    [_keyframes addObject:flumpKeyFrame];
    _numFrames += flumpKeyFrame.duration;
}

#pragma mark public methods

-(FLMPLayer *)copy
{
    FLMPLayer *flumpLayer = [[FLMPLayer alloc] init];
    
    flumpLayer.layerName = self.layerName;
    
    UIImageView *imageView;
    NSString *key;
    
    for (key in _imagesDictionary)
    {
        imageView = [_imagesDictionary objectForKey:key];
        [flumpLayer addImage:[[UIImageView alloc] initWithImage:imageView.image] key:key];
    }
    
    FLMPKeyframe *keyFrame;
    FLMPKeyframe *keyFrameCopy;
    for (keyFrame in _keyframes)
    {
        keyFrameCopy = [keyFrame copy];
        [flumpLayer addKeyframeInternal:keyFrameCopy];
    }
    
    return flumpLayer;
}

-(void)addImage:(UIImageView *)imageView key:(NSString *)key
{
    if (!_imagesDictionary)
        _imagesDictionary = [[NSMutableDictionary alloc] init];
    
    if (![_imagesDictionary valueForKey:key])
        [_imagesDictionary setValue:imageView forKey:key];
}

-(void)addKeyframe:(FLMPKeyframe *)flumpKeyframe duration:(NSUInteger)duration imageKey:(NSString *)imageKey
{
    if (!_keyframes)
    {
        _keyframes = [[NSMutableArray alloc] init];
        _numFrames = 0;
    }
    
    flumpKeyframe.index = [_keyframes count];
    flumpKeyframe.duration = duration;
    flumpKeyframe.imageKey = imageKey;
    FLMPKeyframe *copy;
    NSUInteger i;
    for (i = 0; i < duration; ++i)
    {
        copy = [flumpKeyframe copy];
        copy.frame = [_keyframes count];
        [_keyframes addObject:copy];
    }
    
    _numFrames += duration;
    
    //check if we need to tween previous frame
    NSInteger prevFrame = _numFrames - duration;
    if (prevFrame > 0)
    {
        FLMPKeyframe *startKeyframe = [_keyframes objectAtIndex:(prevFrame-1)];
        
        if (startKeyframe.tweened)
        {
            FLMPKeyframe *nextKeyframe = flumpKeyframe;
            FLMPKeyframe *keyframe;
            CGFloat interped = 0;
            CGFloat ease;
            NSUInteger prevDuration = startKeyframe.duration;
            NSUInteger startFrame = prevFrame - prevDuration;
            NSUInteger numFrames = startFrame + prevDuration;
            for (i = (startFrame+1); i < numFrames; ++i)
            {
                keyframe = [_keyframes objectAtIndex:i];
                
                interped = (float)(keyframe.frame - keyframe.index) / keyframe.duration;
                ease = keyframe.ease;
                
                if (ease != 0)
                {
                    CGFloat t;
                    if (ease < 0)
                    {
                        // Ease in
                        CGFloat inv = 1 - interped;
                        t = 1 - inv * inv;
                        ease = -ease;
                    }
                    else
                    {
                        // Ease out
                        t = interped * interped;
                    }
                    
                    interped = ease * t + (1 - ease) * interped;
                }
                
                keyframe.x = startKeyframe.x + (nextKeyframe.x - startKeyframe.x) * interped;
                keyframe.y = startKeyframe.y + (nextKeyframe.y - startKeyframe.y) * interped;
                keyframe.scaleX = startKeyframe.scaleX + (nextKeyframe.scaleX - startKeyframe.scaleX) * interped;
                keyframe.scaleY = startKeyframe.scaleY + (nextKeyframe.scaleY - startKeyframe.scaleY) * interped;
                keyframe.skewX = startKeyframe.skewX + (nextKeyframe.skewX - startKeyframe.skewX) * interped;
                keyframe.skewY = startKeyframe.skewY + (nextKeyframe.skewY - startKeyframe.skewY) * interped;
                keyframe.alpha = startKeyframe.alpha + (nextKeyframe.alpha - startKeyframe.alpha) * interped;
            }
        }
    }
}

-(void)updateFrame:(NSInteger)frameIndex
{
    FLMPKeyframe *keyframe = [_keyframes objectAtIndex:frameIndex];
    
    _imageView = [_imagesDictionary objectForKey:keyframe.imageKey];
    
    CALayer *layer = _imageView.layer;
    UIImage *image = _imageView.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat x = keyframe.x - 1.0f;
    CGFloat y = keyframe.y - 1.0f;
    CGFloat pivotX = keyframe.pivotX - 1.0f;
    CGFloat pivotY = keyframe.pivotY - 1.0f;
    CGFloat scaleX = keyframe.scaleX;
    CGFloat scaleY = keyframe.scaleY;
    CGFloat skewX = keyframe.skewX;
    CGFloat skewY = keyframe.skewY;
    
    //pivot
    layer.anchorPoint = CGPointMake((pivotX / width), (pivotY / height));
    
    //position
    [layer setPosition:CGPointMake(x, y)];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat a = 1.0f;
    CGFloat b = 0.0f;
    CGFloat c = 0.0f;
    CGFloat d = 1.0f;
    
    //scale
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
    
    //skew
    if (!(skewX == 0.0f && skewY == 0.0f))
    {
        CGFloat sinX = sinf(skewX);
        CGFloat cosX = cosf(skewX);
        CGFloat sinY = sinf(skewY);
        CGFloat cosY = cosf(skewY);
        
        a = a * cosY - b * sinX;
        b = a * sinY + b * cosX;
        c = c * cosY - d * sinX;
        d = c * sinY + d * cosX;
    }
    
    transform.a = a;
    transform.b = b;
    transform.c = c;
    transform.d = d;
    
    _imageView.transform = transform;
    
    layer.opacity = keyframe.alpha;
}

@end
