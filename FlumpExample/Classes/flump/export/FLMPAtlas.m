//
// @author Levi Eggert
//

#import "FLMPAtlas.h"
#import "FLMPTexture.h"

@implementation FLMPAtlas

-(void)dealloc
{
    self.atlasImageName = nil;
    self.textures = nil;
}

#pragma mark public methods

-(void)addTexture:(FLMPTexture *)texture withTextureName:(NSString *)textureName
{
    if (texture == nil || textureName == nil)
    {
        return;
    }
    
    if (self.textures == nil)
    {
        self.textures = [[NSMutableDictionary alloc] init];
    }
    
    texture.textureName = textureName;
    
    [self.textures setValue:texture forKey:textureName];
}

-(BOOL)containsTextureWithTextureName:(NSString *)textureName
{    
    if (textureName == nil || self.textures == nil)
    {
        return NO;
    }
    
    if ([self.textures objectForKey:textureName] != nil)
    {
        return YES;
    }
    
    return NO;
}

@end
