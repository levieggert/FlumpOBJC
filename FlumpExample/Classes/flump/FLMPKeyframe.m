//
// @author Levi Eggert
//

#import "FLMPKeyframe.h"

@implementation FLMPKeyframe

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

+(FLMPKeyframe *)keyframe
{
    return [[FLMPKeyframe alloc] init];
}

-(void)dealloc
{
    self.imageKey = nil;
}

-(FLMPKeyframe *)copy
{
    FLMPKeyframe *kf = [[FLMPKeyframe alloc] init];
    
    kf.imageKey = _imageKey;
    kf.duration = _duration;
    kf.index = _index;
    kf.frame = _frame;
    kf.x = _x;
    kf.y = _y;
    kf.scaleX = _scaleX;
    kf.scaleY = _scaleY;
    kf.skewX = _skewX;
    kf.skewY = _skewY;
    kf.pivotX = _pivotX;
    kf.pivotY = _pivotY;
    kf.alpha = _alpha;
    kf.ease = _ease;
    kf.tweened = _tweened;
    
    return kf;
}

@end
