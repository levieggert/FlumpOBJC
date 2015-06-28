//
// @author Levi Eggert
//

#import "FLMPSPAtlas.h"
#import "FLMPTexture.h"

#import "SPTexture.h"
#import "SPRectangle.h"

@implementation FLMPSPAtlas

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
    self.atlas = nil;
    self.cachedLocalImages = nil;
}

#pragma mark private methods

-(SPTexture *)cacheLocalImageFromTexture:(FLMPTexture *)texture
{
    if (texture == nil)
    {
        return nil;
    }
    
    if (self.cachedLocalImages == nil)
    {
        self.cachedLocalImages = [[NSMutableDictionary alloc] init];
    }
    
    SPTexture *image = [self createImageWithTexture:texture];
    
    if (image != nil)
    {
        [self.cachedLocalImages setValue:image forKey:texture.textureName];
    }
    
    return image;
}

-(SPTexture *)createImageWithTexture:(FLMPTexture *)texture
{
    if (texture == nil)
    {
        return nil;
    }
    
    if (self.atlas == nil)
    {
        self.atlas = [[SPTexture alloc] initWithContentsOfFile:self.atlasImageName];
    }
    
    CGRect textureRect = texture.rect;
    SPRectangle *rectangle = [[SPRectangle alloc] init];
    rectangle.x = textureRect.origin.x;
    rectangle.y = textureRect.origin.y;
    rectangle.width = textureRect.size.width;
    rectangle.height = textureRect.size.height;
    
    SPTexture *image = [SPTexture textureWithRegion:rectangle ofTexture:self.atlas];
    
    return image;
}

#pragma mark public methods

-(SPTexture *)getImageAtTextureName:(NSString *)textureName andCacheImageInLocalMemory:(BOOL)cacheImageInLocalMemory
{
    if (textureName == nil || self.textures == nil)
    {
        return nil;
    }
    
    FLMPTexture *texture = [self.textures objectForKey:textureName];
    SPTexture *cachedImage = [self.cachedLocalImages objectForKey:textureName];
    
    if (cachedImage != nil)
    {
        return cachedImage;
    }
    else if (cachedImage == nil && cacheImageInLocalMemory)
    {
        return [self cacheLocalImageFromTexture:texture];
    }
    else
    {
        return [self createImageWithTexture:texture];
    }
}

@end
