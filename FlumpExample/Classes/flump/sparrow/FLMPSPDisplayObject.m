//
// @author Levi Eggert
//

#import "FLMPSPDisplayObject.h"
#import "FLMPExport.h"
#import "FLMPMovie.h"
#import "FLMPLayer.h"
#import "FLMPKeyframe.h"
#import "FLMPSPAtlas.h"
#import "FLMPSPLayer.h"

#import "Sparrow.h"
#import "SPJuggler.h"

@implementation FLMPSPDisplayObject
{
    float mFrameDuration;
    double mElapsedTime;
}

- (id)initWithFlumpExport:(FLMPExport *)flumpExport movieName:(NSString *)movieName
{
    self = [super init];
    if (self) {
        // Initialization code here.
                
        //flumpExport
        _flumpExport = flumpExport;
        
        //movieName
        _movieName = movieName;
        
        //layers
        [self addFLMPSPLayers];
        
        //isPlaying
        _isPlaying = NO;
        
        //loop
        self.loop = YES;
        
        //totalFrames
        _totalFrames = [self getTotalFrames];
        
        if (flumpExport != nil && movieName != nil)
        {
            FLMPMovie *flumpMovie = [flumpExport getFlumpMovieWithMovieName:movieName];
            
            self.fps = flumpMovie.fps;
            
            [self drawFrame:0];
        }
        
        mFrameDuration = 1.0f / self.fps;
    }
    
    return self;
}

-(void)dealloc
{
    _flumpExport = nil;
    _movieName = nil;
    _layers = nil;
}

#pragma mark private methods

-(void)addFLMPSPLayers
{
    _layers = [[NSMutableArray alloc] init];
    
    FLMPMovie *flumpMovie = [self.flumpExport getFlumpMovieWithMovieName:self.movieName];
    NSArray *layers = flumpMovie.layers;
    FLMPSPAtlas *atlas = nil;
    NSArray *keyframes = nil;
    NSString *keyframeTextureName = nil;
    SPTexture *texture = nil;
    FLMPSPLayer *spFlumpLayer;
    for (FLMPLayer *layer in layers)
    {
        spFlumpLayer = [[FLMPSPLayer alloc] init];
        
        [self addChild:spFlumpLayer.image];
        
        [self.layers addObject:spFlumpLayer];
        
        keyframes = layer.keyframes;
        
        for (FLMPKeyframe *keyframe in keyframes)
        {
            keyframeTextureName = keyframe.textureName;
            
            if (![spFlumpLayer.texturesDictionary objectForKey:keyframeTextureName])
            {
                atlas = (FLMPSPAtlas *)[self.flumpExport getAtlasWithTextureName:keyframeTextureName];
                
                if (atlas != nil)
                {
                    texture = [atlas getImageAtTextureName:keyframeTextureName andCacheImageInLocalMemory:YES];
                    
                    [spFlumpLayer addTexture:texture withTextureName:keyframeTextureName];
                }
            }
        }
    }
}

-(NSInteger)getTotalFrames
{
    NSInteger totalFrames = 0;
    
    FLMPMovie *flumpMovie = [self.flumpExport getFlumpMovieWithMovieName:self.movieName];
    
    if (flumpMovie != nil)
    {
        NSArray *layers = flumpMovie.layers;
        
        if (layers != nil && [layers count] > 0)
        {
            FLMPLayer *flumpLayer = [layers firstObject];
            
            if (flumpLayer != nil)
            {
                totalFrames = [flumpLayer getTotalFrames];
            }
        }
    }
    
    return totalFrames;
}

-(NSInteger)clampFrame:(NSInteger)frame
{
    if (frame < 0 || frame >= self.totalFrames)
    {
        return 0;
    }
    
    return frame;
}

#pragma mark public methods

-(void)drawFrame:(NSInteger)frame
{
    NSInteger clampedFrame = [self clampFrame:frame];
    
    _currentFrame = clampedFrame;
    
    //[self clearFrame];
    
    FLMPMovie *flumpMovie = [self.flumpExport getFlumpMovieWithMovieName:self.movieName];
    NSArray *layers = flumpMovie.layers;
    
    //TODO: Progress Block.
    
    if (layers != nil)
    {
        NSArray *keyframes = nil;
        FLMPKeyframe *keyframe = nil;
        NSString *keyframeTextureName = nil;
        SPImage *image;
        FLMPSPLayer *spLayer;
        
        NSInteger layerIndex = 0;
        
        for(FLMPLayer *layer in layers)
        {
            keyframes = layer.keyframes;
            
            if (keyframes != nil && self.currentFrame < [keyframes count])
            {
                keyframe = [keyframes objectAtIndex:self.currentFrame];
                keyframeTextureName = keyframe.textureName;
                
                spLayer = [self.layers objectAtIndex:layerIndex];
                image = spLayer.image;
                
                image.texture = [spLayer.texturesDictionary objectForKey:keyframeTextureName];
                
                [image readjustSize];
                
                image.x = keyframe.position.x;
                image.y = keyframe.position.y;
                image.scaleX = keyframe.scale.x;
                image.scaleY = keyframe.scale.y;
                image.skewX = keyframe.skew.x;
                image.skewY = keyframe.skew.y;
                image.pivotX = keyframe.pivot.x;
                image.pivotY = keyframe.pivot.y;
                image.alpha = keyframe.alpha;
            }
            
            layerIndex++;
        }
    }
}

-(void)clearFrame
{
    [self removeAllChildren];
}

-(void)play
{
    if (!self.isPlaying)
    {
        _isPlaying = YES;
        
        SPJuggler *juggler = Sparrow.juggler;
        [juggler addObject:self];
    }
}

-(void)pause
{
    if (self.isPlaying)
    {
        _isPlaying = NO;
        
        SPJuggler *juggler = Sparrow.juggler;
        [juggler removeObject:self];
    }
}

-(void)stop
{
    if (self.isPlaying)
    {
        _isPlaying = NO;
        
        SPJuggler *juggler = Sparrow.juggler;
        [juggler removeObject:self];
    }
    
    mElapsedTime = 0.0f;
    _prevFrame = 0;
    [self drawFrame:0];
}

#pragma mark SPAnimatable

- (void)advanceTime:(double)seconds
{
    mElapsedTime += seconds;
    
    NSInteger frame = (int)(mElapsedTime / mFrameDuration) % self.totalFrames;
    NSInteger endFrame = self.totalFrames - 1;
    
    _prevFrame = self.currentFrame;
    
    if ((self.prevFrame == endFrame || frame == endFrame) && !self.loop)
    {
        [self pause];
        
        [self drawFrame:endFrame];
        
        //TODO: Complete Block.
        
        return;
    }
    
    [self drawFrame:frame];
}

@end
