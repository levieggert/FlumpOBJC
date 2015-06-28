//
//  SPButton.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.07.09.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SPButton.h>
#import <Sparrow/SPGLTexture.h>
#import <Sparrow/SPImage.h>
#import <Sparrow/SPRectangle.h>
#import <Sparrow/SPSprite.h>
#import <Sparrow/SPStage.h>
#import <Sparrow/SPTextField.h>
#import <Sparrow/SPTexture.h>
#import <Sparrow/SPTouchEvent.h>

// --- private interface ---------------------------------------------------------------------------

#define MAX_DRAG_DIST 40

@interface SPButton()

- (void)resetContents;
- (void)createTextField;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation SPButton
{
    SPTexture *_upState;
    SPTexture *_downState;
    
    SPSprite *_contents;
    SPImage *_background;
    SPTextField *_textField;
    SPRectangle *_textBounds;
    
    float _scaleWhenDown;
    float _alphaWhenDisabled;
    BOOL _enabled;
    BOOL _isDown;
}

#pragma mark Initialization

- (instancetype)initWithUpState:(SPTexture *)upState downState:(SPTexture *)downState
{
    if ((self = [super init]))
    {
        _upState = [upState retain];
        _downState = [downState retain];
        _contents = [[SPSprite alloc] init];
        _background = [[SPImage alloc] initWithTexture:upState];
        _textField = nil;
        _scaleWhenDown = 1.0f;
        _alphaWhenDisabled = 0.5f;
        _enabled = YES;
        _isDown = NO;
        _textBounds = [[SPRectangle alloc] initWithX:0 y:0 width:_upState.width height:_upState.height];
        self.touchGroup = YES;
        
        [_contents addChild:_background];
        [self addChild:_contents];
        [self addEventListener:@selector(onTouch:) atObject:self forType:SPEventTypeTouch];
    }
    return self;
}

- (instancetype)initWithUpState:(SPTexture *)upState text:(NSString *)text
{
    self = [self initWithUpState:upState];
    self.text = text;
    return self;
}

- (instancetype)initWithUpState:(SPTexture *)upState
{
    self = [self initWithUpState:upState downState:upState];
    _scaleWhenDown = 0.9f;
    return self;
}

- (instancetype)init
{
    SPTexture *texture = [[[SPGLTexture alloc] init] autorelease];
    return [self initWithUpState:texture];   
}

- (void)dealloc
{
    [self removeEventListenersAtObject:self forType:SPEventTypeTouch];

    [_upState release];
    [_downState release];
    [_contents release];
    [_background release];
    [_textField release];
    [_textBounds release];
    [super dealloc];
}

+ (instancetype)buttonWithUpState:(SPTexture *)upState downState:(SPTexture *)downState
{
    return [[[self alloc] initWithUpState:upState downState:downState] autorelease];
}

+ (instancetype)buttonWithUpState:(SPTexture *)upState text:(NSString *)text
{
    return [[[self alloc] initWithUpState:upState text:text] autorelease];
}

+ (instancetype)buttonWithUpState:(SPTexture *)upState
{
    return [[[self alloc] initWithUpState:upState] autorelease];
}

#pragma mark Events

- (void)onTouch:(SPTouchEvent *)touchEvent
{
    if (!_enabled) return;
    SPTouch *touch = [[touchEvent touchesWithTarget:self] anyObject];

    if (touch.phase == SPTouchPhaseBegan && !_isDown)
    {
        _background.texture = _downState;
        _contents.scaleX = _contents.scaleY = _scaleWhenDown;
        _contents.x = (1.0f - _scaleWhenDown) / 2.0f * _background.width;
        _contents.y = (1.0f - _scaleWhenDown) / 2.0f * _background.height;
        _isDown = YES;
    }
    else if (touch.phase == SPTouchPhaseMoved && _isDown)
    {
        // reset button when user dragged too far away after pushing
        SPRectangle *buttonRect = [self boundsInSpace:self.stage];
        if (touch.globalX < buttonRect.x - MAX_DRAG_DIST ||
            touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
            touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
            touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
        {
            [self resetContents];
        }
    }
    else if (touch.phase == SPTouchPhaseEnded && _isDown)
    {
        [self resetContents];
        [self dispatchEventWithType:SPEventTypeTriggered bubbles:YES];
    }
    else if (touch.phase == SPTouchPhaseCancelled && _isDown)
    {
        [self resetContents];
    }
}

#pragma mark SPDisplayObject

- (void)setWidth:(float)width
{
    // a button behaves just like a textfield: when changing width & height,
    // the textfield is not stretched, but will have more room for its chars.

    _background.width = width;
    [self createTextField];
}

- (float)width
{
    return _background.width;
}

- (void)setHeight:(float)height
{
    _background.height = height;
    [self createTextField];
}

- (float)height
{
    return _background.height;
}

#pragma mark Properties

- (void)setEnabled:(BOOL)value
{
    _enabled = value;
    if (_enabled)
    {
        _contents.alpha = 1.0f;
    }
    else
    {
        _contents.alpha = _alphaWhenDisabled;
        [self resetContents];
    }
}

- (NSString *)text
{
    if (_textField) return _textField.text;
    else return @"";
}

- (void)setText:(NSString *)value
{
    if (value.length == 0)
    {
        [_textField removeFromParent];
    }
    else
    {
        [self createTextField];
        if (!_textField.parent) [_contents addChild:_textField];
    }
    
    _textField.text = value;
}

- (NSString *)fontName
{
    if (_textField) return _textField.fontName;
    else return SPDefaultFontName;
}

- (void)setFontName:(NSString *)value
{
    [self createTextField];
    _textField.fontName = value;
}

- (float)fontSize
{
    if (_textField) return _textField.fontSize;
    else return SPDefaultFontSize;
}

- (void)setFontSize:(float)value
{
    [self createTextField];
    _textField.fontSize = value;
}

- (uint)fontColor
{
    if (_textField) return _textField.color;
    else return SPDefaultFontColor;
}

- (void)setFontColor:(uint)value
{
    [self createTextField];
    _textField.color = value;
}

- (uint)color
{
    return _background.color;
}

- (void)setColor:(uint)color
{
    _background.color = color;
}

- (void)setUpState:(SPTexture *)upState
{
    if (upState != _upState)
    {
        SP_RELEASE_AND_RETAIN(_upState, upState);
        if (!_isDown) _background.texture = upState;
    }
}

- (void)setDownState:(SPTexture *)downState
{
    if (downState != _downState)
    {
        SP_RELEASE_AND_RETAIN(_downState, downState);
        if (_isDown) _background.texture = downState;
    }
}

- (void)setTextBounds:(SPRectangle *)value
{
    float scaleX = _background.scaleX;
    float scaleY = _background.scaleY;

    [_textBounds release];
    _textBounds = [[SPRectangle alloc] initWithX:value.x/scaleX y:value.y/scaleY 
                                           width:value.width/scaleX height:value.height/scaleY];
    
    [self createTextField];
}

- (SPRectangle *)textBounds
{
    float scaleX = _background.scaleX;
    float scaleY = _background.scaleY;
    
    return [SPRectangle rectangleWithX:_textBounds.x*scaleX y:_textBounds.y*scaleY 
                                 width:_textBounds.width*scaleX height:_textBounds.height*scaleY];
}

#pragma mark Private

- (void)resetContents
{
    _isDown = NO;
    _background.texture = _upState;
    _contents.x = _contents.y = 0;
    _contents.scaleX = _contents.scaleY = 1.0f;
}

- (void)createTextField
{
    if (!_textField)
    {
        _textField = [[SPTextField alloc] init];
        _textField.vAlign = SPVAlignCenter;
        _textField.hAlign = SPHAlignCenter;
        _textField.touchable = NO;
    }

    _textField.width  = _textBounds.width;
    _textField.height = _textBounds.height;
    _textField.x = _textBounds.x;
    _textField.y = _textBounds.y;
}

@end
