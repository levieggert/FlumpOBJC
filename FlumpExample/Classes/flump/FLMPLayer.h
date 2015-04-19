/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Levi Eggert
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

@class FLMPKeyframe;

/**
 * Flump Layers are animations that make up the flump movie.  Each layer has it's own set of keyframes
 * and images that are animated.  Here you could add some cool features to control the animated layers of a movie.
 *
 * @author Levi Eggert
 */
@interface FLMPLayer : NSObject{
    
}

/** The name of the layer. */
@property(nonatomic, strong) NSString *layerName;
/** Current UIImageView that is being animated. */
@property(nonatomic, strong, readonly) UIImageView *imageView;
/** A dictionary containing UIImageViews that will be animated in the layer.
 The name of the image will match the name of the subTexture loaded in FLMPExport. */
@property(nonatomic, strong, readonly) NSMutableDictionary *imagesDictionary;
/** An array of all keyframes in the layer. Keyframes will manipulate the layers current UIImageView per frame. */
@property(nonatomic, strong, readonly) NSMutableArray *keyframes;
/** Total number of animation frames in the layer.  All keyframe durations in the layer. */
@property(nonatomic, readonly) NSInteger numFrames;

/**
 * Allocates and returns a new FLMPLayer that is an exact copy of the layer.
 */
-(FLMPLayer *)copy;

/**
 * Call to add an image to the images dictionary.  These are images are used in the layer animation.
 *
 * @param       imageView       UIImageView to display on the layer.
 * @param       key             Key value for retrieving image from the dictionary.
 */
-(void)addImage:(UIImageView *)imageView key:(NSString *)key;

/**
 * Adds a keyframe to the flump layer.
 *
 * @param       flumpKeyFrame       The keyframe object to add.
 * @param       duration            The number of frames this keyframe will last.
 * @param       imageKey            The SPImage in the imagesDictionary will be displayed on this keyframe.
 */
-(void)addKeyframe:(FLMPKeyframe *)flumpKeyFrame duration:(NSUInteger)duration imageKey:(NSString *)imageKey;

/**
 * Updates the frame the layer should be on.
 * Called from SXFlumpMovie when the currentFrame is set.
 */
-(void)updateFrame:(NSInteger)frameIndex;
@end
