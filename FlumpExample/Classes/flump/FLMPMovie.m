//
// @author Levi Eggert
//

#import "FLMPMovie.h"
#import "FLMPLayer.h"

@implementation FLMPMovie

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
    self.movieName = nil;
    self.layers = nil;
}

#pragma mark public methods

-(void)addLayer:(FLMPLayer *)layer
{
    if (layer == nil)
    {
        return;
    }
    
    if (self.layers == nil)
    {
        self.layers = [[NSMutableArray alloc] init];
    }
    
    [self.layers addObject:layer];
}

@end
