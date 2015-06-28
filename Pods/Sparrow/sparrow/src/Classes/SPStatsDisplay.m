//
//  SPStatsDisplay.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.03.13.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SPBlendMode.h>
#import <Sparrow/SPBitmapFont.h>
#import <Sparrow/SPEnterFrameEvent.h>
#import <Sparrow/SPQuad.h>
#import <Sparrow/SPStatsDisplay.h>
#import <Sparrow/SPTextField.h>

@implementation SPStatsDisplay
{
    SPTextField *_textField;
    int _framesPerSecond;
    int _numDrawCalls;
    
    double _totalTime;
    int _frameCount;
}

#pragma mark Initialization

- (instancetype)init
{
    if ((self = [super init]))
    {
        SPQuad *background = [[SPQuad alloc] initWithWidth:45 height:17 color:0x0];
        [self addChild:background];
        [background release];
        
        _framesPerSecond = 0;
        _numDrawCalls = 0;

        self.blendMode = SPBlendModeNone;
        
        [self addEventListener:@selector(onAddedToStage:) atObject:self
                       forType:SPEventTypeAddedToStage];
        [self addEventListener:@selector(onEnterFrame:) atObject:self
                       forType:SPEventTypeEnterFrame];
    }
    return self;
}

- (void)dealloc
{
    [_textField release];
    [super dealloc];
}

#pragma mark Events

- (void)onAddedToStage:(SPEvent *)event
{
    _framesPerSecond = _numDrawCalls = 0;
    [self update];
}

- (void)onEnterFrame:(SPEnterFrameEvent *)event
{
    _totalTime += event.passedTime;
    _frameCount++;
    
    if (_totalTime > 1.0)
    {
        _framesPerSecond = roundf(_frameCount / _totalTime);
        _frameCount = _totalTime = 0;
        [self update];
    }
}

- (void)update
{
    if (!_textField)
    {
        _textField = [[SPTextField alloc] initWithWidth:48 height:17 text:@""
            fontName:SPBitmapFontMiniName fontSize:SPNativeFontSize color:SPColorWhite];
        _textField.hAlign = SPHAlignLeft;
        _textField.vAlign = SPVAlignTop;
        _textField.x = 2;
        [self addChild:_textField];
    }
    
    _textField.text = [NSString stringWithFormat:@"FPS: %d\nDRW: %d",
                       _framesPerSecond, _numDrawCalls];
}

@end
