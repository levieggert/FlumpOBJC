//
// @author Levi Eggert
//

#import "FLMPSPDisplayObject.h"
#import "FLMPExport.h"
#import "FLMPMovie.h"
#import "FLMPLayer.h"
#import "FLMPKeyframe.h"
#import "FLMPSPAtlas.h"

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
}

#pragma mark private methods

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
    
    [self clearFrame];
    
    if ([self.delegate respondsToSelector:@selector(flumpDisplayObjectDidUpdateFrame:frame:)])
    {
        [self.delegate flumpDisplayObjectDidUpdateFrame:self frame:self.currentFrame];
    }
    
    FLMPMovie *flumpMovie = [self.flumpExport getFlumpMovieWithMovieName:self.movieName];
    NSArray *layers = flumpMovie.layers;
    
    if (layers != nil)
    {
        FLMPSPAtlas *atlas = nil;
        NSArray *keyframes = nil;
        FLMPKeyframe *keyframe = nil;
        NSString *keyframeTextureName = nil;
        SPImage *image;
        SPTexture *texture = nil;
        
        for(FLMPLayer *layer in layers)
        {
            keyframes = layer.keyframes;
            
            if (keyframes != nil && self.currentFrame < [keyframes count])
            {
                keyframe = [keyframes objectAtIndex:self.currentFrame];
                keyframeTextureName = keyframe.textureName;
                
                atlas = (FLMPSPAtlas *)[self.flumpExport getAtlasWithTextureName:keyframeTextureName];
                
                if (atlas != nil)
                {
                    texture = [atlas getImageAtTextureName:keyframeTextureName andCacheImageInLocalMemory:YES];
                    image = [[SPImage alloc] initWithTexture:texture];
                    
                    image.x = keyframe.position.x;
                    image.y = keyframe.position.y;
                    image.scaleX = keyframe.scale.x;
                    image.scaleY = keyframe.scale.y;
                    image.skewX = keyframe.skew.x;
                    image.skewY = keyframe.skew.y;
                    image.pivotX = keyframe.pivot.x;
                    image.pivotY = keyframe.pivot.y;
                    image.alpha = keyframe.alpha;
                    
                    [self addChild:image];
                }
            }
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
        
        if ([self.delegate respondsToSelector:@selector(flumpDisplayObjectDidPlay:)])
        {
            [self.delegate flumpDisplayObjectDidPlay:self];
        }
    }
}

-(void)pause
{
    if (self.isPlaying)
    {
        _isPlaying = NO;
        
        SPJuggler *juggler = Sparrow.juggler;
        [juggler removeObject:self];
        
        if ([self.delegate respondsToSelector:@selector(flumpDisplayObjectDidPause:)])
        {
            [self.delegate flumpDisplayObjectDidPause:self];
        }
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
    
    if ([self.delegate respondsToSelector:@selector(flumpDisplayObjectDidStop:)])
    {
        [self.delegate flumpDisplayObjectDidStop:self];
    }
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
        
        if ([self.delegate respondsToSelector:@selector(flumpDisplayObjectDidComplete:)])
        {
            [self.delegate flumpDisplayObjectDidComplete:self];
        }
        
        return;
    }
    
    [self drawFrame:frame];
}

@end
