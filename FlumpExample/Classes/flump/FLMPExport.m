//
// @author Levi Eggert
//

#import "FLMPExport.h"
#import "FLMPMovie.h"
#import "FLMPLayer.h"
#import "FLMPKeyframe.h"

#import "RXMLElement.h"

@implementation FLMPExport

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(FLMPExport *)flumpExportWithXMLFileName:(NSString *)fileName
{
    return [[FLMPExport alloc] initWithXMLFileName:fileName];
}

-(void)dealloc
{
    _moviesDictionary = nil;
    _subTextures = nil;
}

-(id)initWithXMLFileName:(NSString *)fileName
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        //printf("\n fileName: %s", [fileName UTF8String]);
        
        RXMLElement *xmlElement = [RXMLElement elementFromXMLFile:fileName];
        
        //load all textures
        NSArray *atlasXMLArray = [[[xmlElement child:@"textureGroups"]
                                   child:@"textureGroup"]
                                  children:@"atlas"];
        
        [self loadTexturesFromAtlasXMLArray:atlasXMLArray];
        
        //load movies
        [self loadMoviesFromMoviesXMLArray:[xmlElement children:@"movie"]];
    }
    
    return self;
}

#pragma mark private methods

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

-(void)loadTexturesFromAtlasXMLArray:(NSArray *)atlasXMLArray
{
    _subTextures = [[NSMutableDictionary alloc] init];
    
    NSArray *textureXMLArray;
    UIImage *textureAtlas;
    NSString *atlasFile;
    UIImage *subTexture;
    NSString *subTextureName;
    CGRect rectangle;
    //CGPoint origin;
    NSArray *array;
    CGImageRef imageRef;
    
    for (RXMLElement *atlasXML in atlasXMLArray)
    {
        atlasFile = [atlasXML attribute:@"file"];
        //printf("\n atlasFile: %s", [atlasFile UTF8String]);
        textureAtlas = [UIImage imageNamed:atlasFile];
        
        textureXMLArray = [atlasXML children:@"texture"];
        
        for (RXMLElement *textureXML in textureXMLArray)
        {
            subTextureName = [textureXML attribute:@"name"];
            //printf("\n subTextureName: %s", [subTextureName UTF8String]);
            
            //rect
            array = [[textureXML attribute:@"rect"] componentsSeparatedByString:@","];
            rectangle = CGRectMake([[array objectAtIndex:0] intValue], [[array objectAtIndex:1] intValue], [[array objectAtIndex:2] intValue], [[array objectAtIndex:3] intValue]);
            
            //origin
            array = [[textureXML attribute:@"origin"] componentsSeparatedByString:@","];
            //origin = CGPointMake([[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue]);
            
            //subTexture
            imageRef = CGImageCreateWithImageInRect(textureAtlas.CGImage, rectangle);
            subTexture = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            subTexture = [self renderImageForAntialiasing:subTexture];

            [_subTextures setValue:subTexture forKey:subTextureName];
        }
    }
}

-(void)loadMoviesFromMoviesXMLArray:(NSArray *)moviesXMLArray
{
    _moviesDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *array;
    FLMPMovie *flumpMovie;
    NSString *movieName;
    NSArray *layersXMLArray;
    FLMPLayer *flumpLayer;
    BOOL addLayer;
    NSString *layerName;
    NSArray *keyframesXMLArray;
    NSString *textureName;
    NSInteger duration;
    UIImageView *imageView;
    FLMPKeyframe *keyframe;
    
    //movies
    for (RXMLElement *movieXML in moviesXMLArray)
    {
        movieName = [[[movieXML attribute:@"name"] componentsSeparatedByString:@"/"] lastObject];
        //printf("\n movieName: %s", [movieName UTF8String]);
        
        flumpMovie = [[FLMPMovie alloc] init];
        flumpMovie.movieName = movieName;
        flumpMovie.fps = [[movieXML attribute:@"frameRate"] floatValue];
        
        //layers
        layersXMLArray = [movieXML children:@"layer"];
        for (RXMLElement *layerXML in layersXMLArray)
        {
            layerName = [[[layerXML attribute:@"name"] componentsSeparatedByString:@"/"] lastObject];
            //printf("\n layerName: %s", [layerName UTF8String]);
            
            flumpLayer = [[FLMPLayer alloc] init];
            
            addLayer = YES;
            
            //keyframes
            keyframesXMLArray = [layerXML children:@"kf"];
            for (RXMLElement *keyframeXML in keyframesXMLArray)
            {
                textureName = [keyframeXML attribute:@"ref"];
                if (textureName)
                {
                    //printf("\n textureName: %s", [textureName UTF8String]);
                    duration = [[keyframeXML attribute:@"duration"] intValue];
                    imageView = [[UIImageView alloc] initWithImage:[_subTextures objectForKey:textureName]];
                    //imageView.layer.shouldRasterize = YES;
                    //imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
                    //imageView.clipsToBounds = NO;
                    //imageView.layer.masksToBounds = NO;
                    
                    keyframe = [FLMPKeyframe keyframe];
                    
                    //location
                    array = [[keyframeXML attribute:@"loc"] componentsSeparatedByString:@","];
                    keyframe.x = ([array objectAtIndex:0]) ? [[array objectAtIndex:0] floatValue] : 0;
                    keyframe.y = ([array objectAtIndex:1]) ? [[array objectAtIndex:1] floatValue] : 0;
                    
                    //skew
                    array = [[keyframeXML attribute:@"skew"] componentsSeparatedByString:@","];
                    keyframe.skewX = ([array objectAtIndex:0]) ? [[array objectAtIndex:0] floatValue] : 0;
                    keyframe.skewY = ([array objectAtIndex:1]) ? [[array objectAtIndex:1] floatValue] : 0;
                    
                    //scale
                    array = [[keyframeXML attribute:@"scale"] componentsSeparatedByString:@","];
                    keyframe.scaleX = ([array objectAtIndex:0]) ? [[array objectAtIndex:0] floatValue] : 1;
                    keyframe.scaleY = ([array objectAtIndex:1]) ? [[array objectAtIndex:1] floatValue] : 1;
                    
                    //pivot
                    array = [[keyframeXML attribute:@"pivot"] componentsSeparatedByString:@","];
                    keyframe.pivotX = ([array objectAtIndex:0]) ? [[array objectAtIndex:0] floatValue] : 0;
                    keyframe.pivotY = ([array objectAtIndex:1]) ? [[array objectAtIndex:1] floatValue] : 0;
                    
                    if ([keyframeXML attribute:@"alpha"])
                        keyframe.alpha = [[keyframeXML attribute:@"alpha"] floatValue];
                    else
                        keyframe.alpha = 1.0f;
                    
                    if ([keyframeXML attribute:@"ease"])
                        keyframe.ease = [[keyframeXML attribute:@"ease"] integerValue];
                    else
                        keyframe.ease = 0;
                    
                    if ([keyframeXML attribute:@"tweened"] == nil ||
                        [[keyframeXML attribute:@"tweened"] boolValue])
                    {
                        keyframe.tweened = YES;
                    }
                    else
                    {
                        keyframe.tweened = NO;
                    }
                    
                    [flumpLayer addImage:imageView key:textureName];
                    [flumpLayer addKeyframe:keyframe duration:duration imageKey:textureName];
                }//end if textureName
                else//else no texture name in XML
                {
                    addLayer = NO;
                    //no texture...
                    printf("\nWARNING: SXFlumpExport - No texture found on keyframe in layer with name: %s. Layer was not added.", [layerName UTF8String]);
                }
            }//end keyframes
            
            if (addLayer)
                [flumpMovie addLayer:flumpLayer name:layerName];
            
        }//end layers
        
        [_moviesDictionary setValue:flumpMovie forKey:movieName];
    }//end movies
}

#pragma mark public methods

@end
