//
// @author Levi Eggert
//

#import "FLMPView.h"
#import "FLMPExport.h"
#import "FLMPMovie.h"
#import "FLMPLayer.h"
#import "FLMPKeyframe.h"
#import "FLMPUIAtlas.h"

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
    }
    
    return self;
}

-(void)dealloc
{
    _flumpExport = nil;
    _movieName = nil;
    [self.updateFramesTimer invalidate];
    _updateFramesTimer = nil;
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

-(void)decrementFrame
{
    NSInteger frame = self.currentFrame - 1;
    
    [self drawFrame:frame];
}

-(void)incrementFrame
{
    NSInteger frame = self.currentFrame + 1;
    
    if (frame < self.totalFrames)
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
    
    FLMPMovie *flumpMovie = [self.flumpExport getFlumpMovieWithMovieName:self.movieName];
    NSArray *layers = flumpMovie.layers;
    
    if (layers != nil)
    {
        FLMPUIAtlas *atlas = nil;
        NSArray *keyframes = nil;
        FLMPKeyframe *keyframe = nil;
        NSString *keyframeTextureName = nil;
        UIImageView *imageView = nil;
        UIImage *image = nil;
        CGAffineTransform transform;
        
        for(FLMPLayer *layer in layers)
        {
            keyframes = layer.keyframes;
            
            if (keyframes != nil && self.currentFrame < [keyframes count])
            {
                keyframe = [keyframes objectAtIndex:self.currentFrame];
                keyframeTextureName = keyframe.textureName;
                
                atlas = (FLMPUIAtlas *)[self.flumpExport getAtlasWithTextureName:keyframeTextureName];
                
                if (atlas != nil)
                {
                    image = [atlas getImageAtTextureName:keyframeTextureName andCacheImageInLocalMemory:YES];
                    
                    transform = [layer getTransformAtFrame:self.currentFrame];
                    
                    imageView = [[UIImageView alloc] initWithImage:image];
                    
                    imageView.layer.anchorPoint = CGPointMake(keyframe.pivot.x / image.size.width, keyframe.pivot.y / image.size.height);
                    imageView.layer.position = CGPointMake(transform.tx, transform.ty);
                    transform.tx = 0.0f;
                    transform.ty = 0.0f;
                    imageView.transform = transform;
                    imageView.alpha = keyframe.alpha;
                    
                    [self addSubview:imageView];
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
