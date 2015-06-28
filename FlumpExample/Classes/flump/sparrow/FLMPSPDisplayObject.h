/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Levi Eggert
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

#import "SPDisplayObjectContainer.h"
#import "SPAnimatable.h"

@class FLMPExport;
@class FLMPSPDisplayObject;

@protocol FLMPSPDisplayObjectDelegate <NSObject>
@optional
-(void)flumpDisplayObjectDidPlay:(FLMPSPDisplayObject *)flumpDisplayObject;
-(void)flumpDisplayObjectDidPause:(FLMPSPDisplayObject *)flumpDisplayObject;
-(void)flumpDisplayObjectDidStop:(FLMPSPDisplayObject *)flumpDisplayObject;
-(void)flumpDisplayObjectDidUpdateFrame:(FLMPSPDisplayObject *)flumpDisplayObject frame:(NSInteger)frame;
-(void)flumpDisplayObjectDidComplete:(FLMPSPDisplayObject *)flumpDisplayObject;
@end

@interface FLMPSPDisplayObject : SPDisplayObjectContainer<SPAnimatable>{
    
}

@property(nonatomic, weak) id<FLMPSPDisplayObjectDelegate> delegate;
@property(nonatomic, strong, readonly) FLMPExport *flumpExport;
@property(nonatomic, strong, readonly) NSString *movieName;
@property(nonatomic, readonly) NSInteger prevFrame;
@property(nonatomic, readonly) NSInteger currentFrame;
@property(nonatomic, readonly) NSInteger totalFrames;
@property(nonatomic, readonly) BOOL isPlaying;
@property(nonatomic, assign) BOOL loop;
@property(nonatomic, assign) CGFloat fps;

-(id)initWithFlumpExport:(FLMPExport *)flumpExport movieName:(NSString *)movieName;

-(void)drawFrame:(NSInteger)frame;
-(void)clearFrame;
-(void)play;
-(void)pause;
-(void)stop;

@end
