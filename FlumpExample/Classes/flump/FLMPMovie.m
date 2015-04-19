//
// @author Levi Eggert
//

#import "FLMPMovie.h"
#import "FLMPLayer.h"

@implementation FLMPMovie

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setFrame:[UIScreen mainScreen].bounds];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
    }
    
    return self;
}

-(void)dealloc
{
    [self.timer invalidate];
    _timer = nil;
    self.movieName = nil;
    _layers = nil;
    _layersDictionary = nil;
}

#pragma mark private methods

-(void)handleTimer
{
    self.currentFrame++;
}

#pragma mark setters/getters

-(void)setFps:(CGFloat)fps
{
    _fps = fps;
    
    if (_isPlaying)
    {
        _isPlaying = NO;
        [_timer invalidate];
        _timer = nil;
        
        [self play];
    }
}

-(void)setCurrentFrame:(NSInteger)currentFrame
{
    if (currentFrame < 0 ||
        currentFrame >= self.numFrames)
    {
        currentFrame = 0;
    }
    
    _currentFrame = currentFrame;
    
    for (UIView *subview in self.subviews)
        [subview removeFromSuperview];
    FLMPLayer *layer;
    for (layer in _layers)
    {
        [layer updateFrame:_currentFrame];
        [self addSubview:layer.imageView];
    }
}

#pragma mark public methods

-(FLMPMovie *)copy
{
    FLMPMovie *flumpMovie = [[FLMPMovie alloc] init];
    flumpMovie.movieName = self.movieName;
    flumpMovie.fps = self.fps;
    
    FLMPLayer *flumpLayer;
    FLMPLayer *flumpLayerCopy;
    NSString *key;
    
    for (flumpLayer in _layers)
    {
        key = [[_layersDictionary allKeysForObject:flumpLayer] objectAtIndex:0];
        flumpLayerCopy = [flumpLayer copy];
        [flumpMovie addLayer:flumpLayerCopy name:key];
    }
    
    return flumpMovie;
}

-(void)addLayer:(FLMPLayer *)flumpLayer name:(NSString *)name
{
    flumpLayer.layerName = name;
    
    if (!_layers)
    {
        _layers = [[NSMutableArray alloc] init];
        _layersDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [_layers addObject:flumpLayer];
    [_layersDictionary setValue:flumpLayer forKey:name];
    
    if ([_layers count] == 1)
        _numFrames = [flumpLayer.keyframes count];
    
    self.currentFrame = 0;
}

-(void)play
{
    if (!self.isPlaying)
    {
        _isPlaying = YES;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1/self.fps
                                                  target:self
                                                selector:@selector(handleTimer)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

-(void)pause
{
    if (self.isPlaying)
    {
        _isPlaying = NO;
        [self.timer invalidate];
        _timer = nil;
    }
}

-(void)stop
{
    _isPlaying = NO;
    self.currentFrame = 0;
    [self.timer invalidate];
    _timer = nil;
}

@end
