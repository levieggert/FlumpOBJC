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
        
        self.textureName = nil;
        self.duration = 0;
        self.position = CGPointZero;
        self.scale = CGPointMake(1.0f, 1.0f);
        self.skew = CGPointZero;
        self.pivot = CGPointZero;
        self.alpha = 1.0f;
        self.ease = 0;
        self.tween = NO;
    }
    
    return self;
}

-(void)dealloc
{
    self.textureName = nil;
}

@end
