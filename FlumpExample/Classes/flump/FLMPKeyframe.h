/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Levi Eggert
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

/**
 * Helper Class for setting up keyframes on a FLMPLayer.
 *
 * @author Levi Eggert
 */
@interface FLMPKeyframe : NSObject{
    
}

/** Key into layers image dictionary for retrieving image to display on this keyframe. */
@property(nonatomic, strong) NSString *imageKey;
/** The duration is the number of frames this keyframe will run. */
@property(nonatomic, assign) NSUInteger duration;
/** Keyframe index relative to duration of keyframes. */
@property(nonatomic, assign) NSUInteger index;
/** The frame position of the keyframe. */
@property(nonatomic, assign) NSUInteger frame;
/** The x position to set the image on this keyframe. */
@property(nonatomic, assign) CGFloat x;
/** The y position to set the image on this keyframe. */
@property(nonatomic, assign) CGFloat y;
/** The scaleX to apply to the image on this frame. */
@property(nonatomic, assign) CGFloat scaleX;
/** The scaleY to apply to the image on this frame. */
@property(nonatomic, assign) CGFloat scaleY;
/** The skewX to apply to the image on this frame. */
@property(nonatomic, assign) CGFloat skewX;
/** The skewY to apply to the image on this frame. */
@property(nonatomic, assign) CGFloat skewY;
/** The pivotX to apply to the image on this frame. */
@property(nonatomic, assign) CGFloat pivotX;
/** The pivotY to apply to the image on this frame. */
@property(nonatomic, assign) CGFloat pivotY;
/** The alpha of the image at this keyframe. */
@property(nonatomic, assign) CGFloat alpha;
/** The ease to apply if their is a tween.  -1, 0, 1. */
@property(nonatomic, assign) NSInteger ease;
/** Boolean to check if this keyframe should be tweened. */
@property(nonatomic, assign) BOOL tweened;

/**
 * Class function for allocating a new keyframe.
 */
+(FLMPKeyframe *)keyframe;

/**
 * Returns a copy of the keyframe.
 */
-(FLMPKeyframe *)copy;

@end
