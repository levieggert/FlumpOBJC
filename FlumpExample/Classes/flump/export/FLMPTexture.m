//
// @author Levi Eggert
//

#import "FLMPTexture.h"

@implementation FLMPTexture

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        self.textureName = nil;
        self.origin = CGPointZero;
        self.rect = CGRectZero;
    }
    
    return self;
}

-(void)dealloc
{
    self.textureName = nil;
}

@end
