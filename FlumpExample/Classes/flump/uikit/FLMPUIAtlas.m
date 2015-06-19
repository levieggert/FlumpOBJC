//
// @author Levi Eggert
//

#import "FLMPUIAtlas.h"
#import "FLMPTexture.h"

@implementation FLMPUIAtlas

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
    if (texture == nil)
    {
        return nil;
    }
    
    if (self.atlas == nil)
    {
        self.atlas = [UIImage imageNamed:self.atlasImageName];
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

#pragma mark public methods

-(UIImage *)getImageAtTextureName:(NSString *)textureName andCacheImageInLocalMemory:(BOOL)cacheImageInLocalMemory
{
    if (textureName == nil || self.textures == nil)
    {
        return nil;
    }
    
    FLMPTexture *texture = [self.textures objectForKey:textureName];
    UIImage *cachedImage = [self.cachedLocalImages objectForKey:textureName];
    
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
