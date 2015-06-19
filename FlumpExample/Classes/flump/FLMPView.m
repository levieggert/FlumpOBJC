//
// @author Levi Eggert
//

#import "FLMPView.h"
#import "FLMPExport.h"
#import "FLMPMovie.h"
#import "FLMPLayer.h"
#import "FLMPKeyframe.h"
#import "FLMPAtlas.h"

@implementation FLMPView

- (id)initWithFlumpExport:(FLMPExport *)flumpExport movieName:(NSString *)movieName
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code here.
        
        //backgroundColor
        self.backgroundColor = [UIColor clearColor];
        
        //flumpExport
        _flumpExport = flumpExport;
        
        //isPlaying
        _isPlaying = NO;
        
        //loop
        self.loop = YES;
        
        if (flumpExport != nil && movieName != nil)
        {
            _flumpMovie = [flumpExport getFlumpMovieWithMovieName:movieName];
            
            self.fps = self.flumpMovie.fps;
            
            [self drawFrame:0];
        }
    }
    
    return self;
}

-(void)dealloc
{
    _flumpExport = nil;
    _flumpMovie = nil;
    [self.updateFramesTimer invalidate];
    _updateFramesTimer = nil;
}

#pragma mark private methods

-(NSInteger)clampFrame:(NSInteger)frame
{
    if (frame < 0 || frame >= [self getTotalFrames])
    {
        return 0;
    }
    
    return frame;
}

#pragma mark public methods

-(NSInteger)getTotalFrames
{
    NSInteger totalFrames = 0;
    
    if (self.flumpMovie != nil)
    {
        NSArray *layers = self.flumpMovie.layers;
        
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

-(void)decrementFrame
{
    NSInteger frame = self.currentFrame - 1;
    
    [self drawFrame:frame];
}

-(void)incrementFrame
{
    NSInteger frame = self.currentFrame + 1;
    
    if (frame < [self getTotalFrames])
    {
        [self drawFrame:frame];
    }
    else
    {
        if (self.loop)
        {
            [self drawFrame:0];
        }
        else
        {
            [self pause];
            
            if ([self.delegate respondsToSelector:@selector(flumpViewDidComplete:)])
            {
                [self.delegate flumpViewDidComplete:self];
            }
        }
    }
}

-(void)drawFrame:(NSInteger)frame
{
    NSInteger clampedFrame = [self clampFrame:frame];
    
    _currentFrame = clampedFrame;
    
    [self clearFrame];
    
    if ([self.delegate respondsToSelector:@selector(flumpViewDidUpdateFrame:frame:)])
    {
        [self.delegate flumpViewDidUpdateFrame:self frame:self.currentFrame];
    }
    
    NSArray *layers = self.flumpMovie.layers;
    
    if (layers != nil)
    {
        FLMPAtlas *atlas = nil;
        NSArray *keyframes = nil;
        FLMPKeyframe *keyframe = nil;
        NSString *keyframeTextureName = nil;
        UIImageView *imageView = nil;
        UIImage *image = nil;
        
        for(FLMPLayer *layer in layers)
        {
            keyframes = layer.keyframes;
            
            if (keyframes != nil && self.currentFrame < [keyframes count])
            {
                keyframe = [keyframes objectAtIndex:self.currentFrame];
                keyframeTextureName = keyframe.textureName;
                
                atlas = [self.flumpExport getAtlasWithTextureName:keyframeTextureName];
                
                if (atlas != nil)
                {
                    image = [atlas getImageAtTextureName:keyframeTextureName andCacheImageInLocalMemory:YES];
                    imageView = [layer getImageViewAtFrame:self.currentFrame drawImage:image];
                    
                    if (imageView != nil)
                    {
                        [self addSubview:imageView];
                    }
                }
            }
        }
    }
}

-(void)clearFrame
{
    for(UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
}

-(void)play
{
    if (!self.isPlaying)
    {
        _isPlaying = YES;
        
        NSTimeInterval timeInterval = 1.0f / self.fps;
        
        _updateFramesTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(incrementFrame) userInfo:nil repeats:YES];
        
        if ([self.delegate respondsToSelector:@selector(flumpViewDidPlay:)])
        {
            [self.delegate flumpViewDidPlay:self];
        }
    }
}

-(void)pause
{
    if (self.isPlaying)
    {
        _isPlaying = NO;
        [self.updateFramesTimer invalidate];
        _updateFramesTimer = nil;
        
        if ([self.delegate respondsToSelector:@selector(flumpViewDidPause:)])
        {
            [self.delegate flumpViewDidPause:self];
        }
    }
}

-(void)stop
{
    if (self.isPlaying)
    {
        _isPlaying = NO;
        [self.updateFramesTimer invalidate];
        _updateFramesTimer = nil;
    }
    
    [self drawFrame:0];
    
    if ([self.delegate respondsToSelector:@selector(flumpViewDidStop:)])
    {
        [self.delegate flumpViewDidStop:self];
    }
}

@end
