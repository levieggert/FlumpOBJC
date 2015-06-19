//
// @author Levi Eggert
//

#import "FLMPAtlas.h"
#import "FLMPTexture.h"

@implementation FLMPAtlas

-(void)dealloc
{
    self.atlasImageName = nil;
    self.atlas = nil;
    self.textures = nil;
    self.cachedLocalImages = nil;
}

#pragma mark private methods

-(UIImage *)cacheLocalImageFromTexture:(FLMPTexture *)texture
{
    if (texture == nil)
    {
        return nil;
    }
    
    if (self.cachedLocalImages == nil)
    {
        self.cachedLocalImages = [[NSMutableDictionary alloc] init];
    }
    
    UIImage *image = [self createImageWithTexture:texture];
    
    if (image != nil)
    {
        [self.cachedLocalImages setValue:image forKey:texture.textureName];
    }
    
    return image;
}

-(UIImage *)createImageWithTexture:(FLMPTexture *)texture
{
    if (texture == nil || self.atlas == nil)
    {
        return nil;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.atlas.CGImage, texture.rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    image = [self renderImageForAntialiasing:image];
    
    return image;
}

-(UIImage *)renderImageForAntialiasing:(UIImage *)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGSize imageSize = CGSizeMake(width + 2.0f, height + 2.0f);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0f);
    [image drawInRect:CGRectMake(1.0f, 1.0f, width, height)];
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

#pragma mark getters/setters

-(void)setAtlasImageName:(NSString *)atlasImageName
{
    _atlasImageName = atlasImageName;
    
    if (atlasImageName != nil)
    {
        self.atlas = [UIImage imageNamed:atlasImageName];
    }
    else
    {
        self.atlas = nil;
    }
}

#pragma mark public methods

-(void)addTexture:(FLMPTexture *)texture
{
    if (texture == nil || texture.textureName == nil)
    {
        return;
    }
    
    if (self.textures == nil)
    {
        self.textures = [[NSMutableDictionary alloc] init];
    }
    
    [self.textures setValue:texture forKey:texture.textureName];
}

-(BOOL)containsTextureWithTextureName:(NSString *)textureName
{    
    if (textureName == nil || self.textures == nil)
    {
        return NO;
    }
    
    FLMPTexture *flumpTexture = [self.textures objectForKey:textureName];
    
    if (flumpTexture != nil)
    {
        return YES;
    }
    
    return NO;
}

-(UIImage *)getImageAtTextureName:(NSString *)textureName andCacheImageInLocalMemory:(BOOL)cacheImageInLocalMemory
{
    if (textureName == nil || self.textures == nil || self.atlasImageName == nil)
    {
        return nil;
    }
    
    FLMPTexture *texture = [self.textures objectForKey:textureName];
    UIImage *cachedImage = [self.cachedLocalImages objectForKey:textureName];
    
    if (cachedImage == nil && cacheImageInLocalMemory)
    {
        return [self cacheLocalImageFromTexture:texture];
    }
    
    return [self createImageWithTexture:texture];
}

@end
