/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Levi Eggert
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

@class FLMPLayer;

/**
 * FLMPMovies are used for advancing the frames of all added FLMPLayers.
 * You can play, stop, pause the movie.
 *
 * @author Levi Eggert
 */
@interface FLMPMovie : UIView{
    
}

/** The name of the movie. */
@property(nonatomic, strong) NSString *movieName;
/** All layers(FLMPLayers) of the FLMPMovie. Each layer is an animation sequence of UIImageViews. */
@property(nonatomic, strong, readonly) NSMutableArray *layers;
/** A dictionary of all the layers stored by layer name.  Layer name can be found in flump's exported xml. */
@property(nonatomic, strong, readonly) NSMutableDictionary *layersDictionary;
/** Timer controls FLMPMovie playback. */
@property(nonatomic, strong, readonly) NSTimer *timer;
/** BOOL flag to check if movie is playing. */
@property(nonatomic, readonly) BOOL isPlaying;
/** The current frame of the movie. */
@property(nonatomic, assign) NSInteger currentFrame;
/** Total number of frames in the movie. */
@property(nonatomic, readonly) NSInteger numFrames;
/** The current fps of the movie. */
@property(nonatomic, assign) CGFloat fps;

/**
 * Allocates and returns a new FLMPMovie that is an exact copy of the movie.
 */
-(FLMPMovie *)copy;

/**
 * Add an animated layer to the flump movie.
 *
 * @param       flumpLayer      The animated layer to add.
 * @param       name            The name of the layer for accessing in the layersDictionary.
 */
-(void)addLayer:(FLMPLayer *)flumpLayer name:(NSString *)name;

/**
 * Start playback.
 */
-(void)play;

/**
 * Pause playback.
 */
-(void)pause;

/**
 * Stops playback.  Resets current frame back to beginning.
 */
-(void)stop;

@end
