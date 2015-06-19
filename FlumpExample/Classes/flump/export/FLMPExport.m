//
// @author Levi Eggert
//

#import "FLMPExport.h"
#import "FLMPMovie.h"
#import "FLMPLayer.h"
#import "FLMPKeyframe.h"
#import "FLMPAtlas.h"
#import "FLMPTexture.h"
#import "FLMPView.h"

@implementation FLMPExport

-(id)initWithFlumpXMLFileName:(NSString *)fileName
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *xmlPath = [mainBundle pathForResource:fileName ofType:@"xml"];
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:xmlPath];
        
        _flumpXMLParser = [[NSXMLParser alloc] initWithData:xmlData];
        self.flumpXMLParser.delegate = self;
        [self.flumpXMLParser parse];
    }
    
    return self;
}

-(void)dealloc
{
    _flumpXMLParser = nil;
    _movies = nil;
    _atlases = nil;
    _lastAddedMovieName = nil;
}

#pragma mark private methods

-(void)addMovie:(FLMPMovie *)movie withMovieName:(NSString *)movieName
{
    if (movie == nil || movieName == nil)
    {
        return;
    }
    
    if (self.movies == nil)
    {
        _movies = [[NSMutableDictionary alloc] init];
    }
    
    movie.movieName = movieName;
    
    [self.movies setValue:movie forKey:movieName];
}

-(void)addAtlas:(FLMPAtlas *)atlas
{
    if (atlas == nil)
    {
        return;
    }
    
    if (self.atlases == nil)
    {
        _atlases = [[NSMutableArray alloc] init];
    }
    
    [self.atlases addObject:atlas];
}

#pragma mark public methods

-(FLMPView *)getFlumpViewWithMovieName:(NSString *)movieName
{
    return [[FLMPView alloc] initWithFlumpExport:self movieName:movieName];
}

-(FLMPMovie *)getFlumpMovieWithMovieName:(NSString *)movieName
{
    if (movieName == nil)
    {
        return nil;
    }
    
    return [self.movies objectForKey:movieName];
}

-(FLMPAtlas *)getAtlasWithTextureName:(NSString *)textureName
{
    if (textureName == nil)
    {
        return nil;
    }
    
    if (self.atlases != nil)
    {
        for (FLMPAtlas *atlas in self.atlases)
        {
            if ([atlas containsTextureWithTextureName:textureName])
            {
                return atlas;
            }
        }
    }
    
    return nil;
}

#pragma mark NSXMLParserDelegate

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"movie"])
    {
        FLMPMovie *flumpMovie = [[FLMPMovie alloc] init];
        NSString *movieName = [attributeDict objectForKey:@"name"];
        CGFloat fps = [[attributeDict objectForKey:@"frameRate"] floatValue];
        
        flumpMovie.movieName = movieName;
        flumpMovie.fps = fps;
        
        [self addMovie:flumpMovie withMovieName:movieName];
        
        _lastAddedMovieName = movieName;
    }
    else if ([elementName isEqualToString:@"layer"])
    {
        FLMPMovie *flumpMovie = [self.movies objectForKey:self.lastAddedMovieName];
        NSString *layerName = [attributeDict objectForKey:@"name"];
        
        if (flumpMovie != nil)
        {
            FLMPLayer *flumpLayer = [[FLMPLayer alloc] init];
            flumpLayer.layerName = layerName;
            
            [flumpMovie addLayer:flumpLayer];
        }
    }
    else if ([elementName isEqualToString:@"kf"])
    {
        FLMPMovie *flumpMovie = [self.movies objectForKey:self.lastAddedMovieName];
        FLMPLayer *flumpLayer = [flumpMovie.layers lastObject];
        
        NSString *stringDuration = [attributeDict objectForKey:@"duration"];
        NSString *stringRef = [attributeDict objectForKey:@"ref"];
        NSString *stringLoc = [attributeDict objectForKey:@"loc"];
        NSString *stringScale = [attributeDict objectForKey:@"scale"];
        NSString *stringSkew = [attributeDict objectForKey:@"skew"];
        NSString *stringPivot = [attributeDict objectForKey:@"pivot"];
        NSString *stringAlpha = [attributeDict objectForKey:@"alpha"];
        NSString *stringEase = [attributeDict objectForKey:@"ease"];
        NSString *stringTween = [attributeDict objectForKey:@"tweened"];
        
        NSString *textureName = stringRef;
        NSInteger duration = [stringDuration integerValue];
        CGPoint position = CGPointZero;
        CGPoint scale = CGPointMake(1.0, 1.0);
        CGPoint skew = CGPointZero;
        CGPoint pivot = CGPointZero;
        CGFloat alpha = 1.0f;
        NSInteger ease = 0;
        BOOL tween = YES;
        
        if (stringAlpha != nil)
        {
            alpha = [stringAlpha floatValue];
        }
        
        if (stringEase != nil)
        {
            ease = [stringEase integerValue];
        }
        
        if (stringTween != nil)
        {
            tween = [stringTween boolValue];
        }
        
        if (stringLoc != nil)
        {
            NSArray *components = [stringLoc componentsSeparatedByString:@","];
            
            if ([components count] >= 2)
            {
                NSString *stringX = components[0];
                NSString *stringY = components[1];
                CGFloat x = [stringX floatValue];
                CGFloat y = [stringY floatValue];
                
                position = CGPointMake(x, y);
            }
        }
        
        if (stringScale != nil)
        {
            NSArray *components = [stringScale componentsSeparatedByString:@","];
            
            if ([components count] >= 2)
            {
                NSString *stringScaleX = components[0];
                NSString *stringScaleY = components[1];
                CGFloat scaleX = [stringScaleX floatValue];
                CGFloat scaleY = [stringScaleY floatValue];
                
                scale = CGPointMake(scaleX, scaleY);
            }
        }
        
        if (stringSkew != nil)
        {
            NSArray *components = [stringSkew componentsSeparatedByString:@","];
            
            if ([components count] >= 2)
            {
                NSString *stringSkewX = components[0];
                NSString *stringSkewY = components[1];
                CGFloat skewX = [stringSkewX floatValue];
                CGFloat skewY = [stringSkewY floatValue];
                
                skew = CGPointMake(skewX, skewY);
            }
        }
        
        if (stringPivot != nil)
        {
            NSArray *components = [stringPivot componentsSeparatedByString:@","];
            
            if ([components count] >= 2)
            {
                NSString *stringPivotX = components[0];
                NSString *stringPivotY = components[1];
                CGFloat pivotX = [stringPivotX floatValue];
                CGFloat pivotY = [stringPivotY floatValue];
                
                pivot = CGPointMake(pivotX, pivotY);
            }
        }
        
        [flumpLayer addKeyframesWithTextureName:textureName duration:duration position:position scale:scale skew:skew pivot:pivot alpha:alpha ease:ease tween:tween];        
    }
    else if ([elementName isEqualToString:@"atlas"])
    {
        FLMPAtlas *flumpAtlas = [[FLMPAtlas alloc] init];
        NSString *atlasImageName = [attributeDict objectForKey:@"file"];
        
        flumpAtlas.atlasImageName = atlasImageName;
        
        [self addAtlas:flumpAtlas];
    }
    else if ([elementName isEqualToString:@"texture"])
    {
        FLMPAtlas *flumpAtlas = [self.atlases lastObject];
        
        if (flumpAtlas != nil)
        {
            FLMPTexture *flumpTexture = [[FLMPTexture alloc] init];
            NSString *textureName = [attributeDict objectForKey:@"name"];
            NSString *stringOrigin = [attributeDict objectForKey:@"origin"];
            NSString *stringRect = [attributeDict objectForKey:@"rect"];
            
            flumpTexture.textureName = textureName;
            
            [flumpAtlas addTexture:flumpTexture];
            
            if (stringOrigin != nil)
            {
                NSArray *components = [stringOrigin componentsSeparatedByString:@","];
                
                if ([components count] >= 2)
                {
                    NSString *stringX = [components objectAtIndex:0];
                    NSString *stringY = [components objectAtIndex:1];

                    CGFloat x = [stringX floatValue];
                    CGFloat y = [stringY floatValue];
                    
                    flumpTexture.origin = CGPointMake(x, y);
                }
            }
            
            if (stringRect != nil)
            {
                NSArray *components = [stringRect componentsSeparatedByString:@","];
                
                if ([components count] >= 2)
                {
                    NSString *stringX = [components objectAtIndex:0];
                    NSString *stringY = [components objectAtIndex:1];
                    NSString *stringWidth = [components objectAtIndex:2];
                    NSString *stringHeight = [components objectAtIndex:3];
                    
                    CGFloat x = [stringX floatValue];
                    CGFloat y = [stringY floatValue];
                    CGFloat width = [stringWidth floatValue];
                    CGFloat height = [stringHeight floatValue];
                    
                    flumpTexture.rect = CGRectMake(x, y, width, height);
                }
            }
        }
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{

}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    printf("\n parseErrorOccurred: %s", [[parseError localizedDescription] UTF8String]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    printf("\n validationErrorOccurred: %s", [[validationError localizedDescription] UTF8String]);
}

@end
