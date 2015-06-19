/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Levi Eggert
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

@interface FLMPKeyframe : NSObject{
    
}

@property(nonatomic, strong) NSString *textureName;
@property(nonatomic, assign) NSUInteger duration;
@property(nonatomic, assign) CGPoint position;
@property(nonatomic, assign) CGPoint scale;
@property(nonatomic, assign) CGPoint skew;
@property(nonatomic, assign) CGPoint pivot;
@property(nonatomic, assign) CGFloat alpha;
@property(nonatomic, assign) NSInteger ease;
@property(nonatomic, assign) BOOL tween;

@end
