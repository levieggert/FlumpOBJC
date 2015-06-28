//
//  SPTextField.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.06.09.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SparrowClass.h>
#import <Sparrow/SPBitmapFont.h>
#import <Sparrow/SPEnterFrameEvent.h>
#import <Sparrow/SPGLTexture.h>
#import <Sparrow/SPImage.h>
#import <Sparrow/SPQuad.h>
#import <Sparrow/SPQuadBatch.h>
#import <Sparrow/SPRectangle.h>
#import <Sparrow/SPStage.h>
#import <Sparrow/SPSprite.h>
#import <Sparrow/SPSubTexture.h>
#import <Sparrow/SPTextField.h>
#import <Sparrow/SPTexture.h>

#import <UIKit/UIKit.h>

// --- public constants ----------------------------------------------------------------------------

NSString *const   SPDefaultFontName   = @"Helvetica";
const float       SPDefaultFontSize   = 14.0f;
const uint        SPDefaultFontColor  = 0x0;
const float       SPNativeFontSize    = -1;

// --- bitmap font cache ---------------------------------------------------------------------------

static NSMutableDictionary *bitmapFonts = nil;

// --- private interface ---------------------------------------------------------------------------

@interface SPTextField ()

- (void)redraw;
- (void)createRenderedContents;
- (void)updateBorder;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation SPTextField
{
    float _fontSize;
    uint _color;
    NSString *_text;
    NSString *_fontName;
    SPHAlign _hAlign;
    SPVAlign _vAlign;
    BOOL _autoScale;
    BOOL _kerning;
    BOOL _requiresRedraw;
    BOOL _isRenderedText;
	
    SPQuadBatch *_contents;
    SPRectangle *_textBounds;
    SPQuad *_hitArea;
    SPSprite *_border;
}

#pragma mark Initialization

- (instancetype)initWithWidth:(float)width height:(float)height text:(NSString *)text fontName:(NSString *)name 
          fontSize:(float)size color:(uint)color 
{
    if ((self = [super init]))
    {        
        _text = [text copy];
        _fontSize = size;
        _color = color;
        _hAlign = SPHAlignCenter;
        _vAlign = SPVAlignCenter;
        _autoScale = NO;
        _kerning = YES;
        _requiresRedraw = YES;
        self.fontName = name;
        
        _hitArea = [[SPQuad alloc] initWithWidth:width height:height];
        _hitArea.alpha = 0.0f;
        [self addChild:_hitArea];
        
        _contents = [[SPQuadBatch alloc] init];
        _contents.touchable = NO;
        [self addChild:_contents];
        
        [self addEventListener:@selector(onFlatten:) atObject:self forType:SPEventTypeFlatten];
    }
    return self;
} 

- (instancetype)initWithWidth:(float)width height:(float)height text:(NSString *)text
{
    return [self initWithWidth:width height:height text:text fontName:SPDefaultFontName
                     fontSize:SPDefaultFontSize color:SPDefaultFontColor];   
}

- (instancetype)initWithWidth:(float)width height:(float)height
{
    return [self initWithWidth:width height:height text:@""];
}

- (instancetype)initWithText:(NSString *)text
{
    return [self initWithWidth:128 height:128 text:text];
}

- (instancetype)init
{
    return [self initWithText:@""];
}

- (void)dealloc
{
    [_text release];
    [_fontName release];
    [_contents release];
    [_textBounds release];
    [_hitArea release];
    [_border release];
    [super dealloc];
}

+ (instancetype)textFieldWithWidth:(float)width height:(float)height text:(NSString *)text
                          fontName:(NSString *)name fontSize:(float)size color:(uint)color
{
    return [[[self alloc] initWithWidth:width height:height text:text fontName:name
                               fontSize:size color:color] autorelease];
}

+ (instancetype)textFieldWithWidth:(float)width height:(float)height text:(NSString *)text
{
    return [[[self alloc] initWithWidth:width height:height text:text] autorelease];
}

+ (instancetype)textFieldWithText:(NSString *)text
{
    return [[[self alloc] initWithText:text] autorelease];
}

#pragma mark Methods

+ (NSString *)registerBitmapFont:(SPBitmapFont *)font name:(NSString *)fontName
{
    if (!bitmapFonts) bitmapFonts = [[NSMutableDictionary alloc] init];
    if (!fontName) fontName = font.name;
    bitmapFonts[fontName] = font;
    return [[fontName copy] autorelease];
}

+ (NSString *)registerBitmapFont:(SPBitmapFont *)font
{
    return [self registerBitmapFont:font name:nil];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path texture:(SPTexture *)texture
                                    name:(NSString *)fontName
{
    SPBitmapFont *font = [[[SPBitmapFont alloc] initWithContentsOfFile:path texture:texture] autorelease];
    return [self registerBitmapFont:font name:fontName];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path texture:(SPTexture *)texture
{
    SPBitmapFont *font = [[[SPBitmapFont alloc] initWithContentsOfFile:path texture:texture] autorelease];
    return [self registerBitmapFont:font];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path
{
    SPBitmapFont *font = [[[SPBitmapFont alloc] initWithContentsOfFile:path] autorelease];
    return [self registerBitmapFont:font];
}

+ (void)unregisterBitmapFont:(NSString *)name
{
    [bitmapFonts removeObjectForKey:name];
}

+ (SPBitmapFont *)registeredBitmapFont:(NSString *)name
{
    return bitmapFonts[name];
}

#pragma mark SPDisplayObject

- (void)render:(SPRenderSupport *)support
{
    if (_requiresRedraw) [self redraw];
    [super render:support];
}

- (SPRectangle *)boundsInSpace:(SPDisplayObject *)targetSpace
{
    return [_hitArea boundsInSpace:targetSpace];
}

- (void)setWidth:(float)width
{
    // other than in SPDisplayObject, changing the size of the object should not change the scaling;
    // changing the size should just make the texture bigger/smaller,
    // keeping the size of the text/font unchanged. (this applies to setHeight:, as well.)

    _hitArea.width = width;
    _requiresRedraw = YES;
    [self updateBorder];
}

- (void)setHeight:(float)height
{
    _hitArea.height = height;
    _requiresRedraw = YES;
    [self updateBorder];
}

#pragma mark Events

- (void)onFlatten:(SPEvent *)event
{
    if (_requiresRedraw) [self redraw];
}

#pragma mark Properties

- (void)setText:(NSString *)text
{
    if (![text isEqualToString:_text])
    {
        SP_RELEASE_AND_COPY(_text, text);
        _requiresRedraw = YES;
    }
}

- (void)setFontName:(NSString *)fontName
{
    if (![fontName isEqualToString:_fontName])
    {
        if ([fontName isEqualToString:SPBitmapFontMiniName] && ![bitmapFonts objectForKey:fontName])
            [SPTextField registerBitmapFont:[[[SPBitmapFont alloc] initWithMiniFont] autorelease]];

        SP_RELEASE_AND_COPY(_fontName, fontName);
        _requiresRedraw = YES;        
        _isRenderedText = !bitmapFonts[_fontName];
    }
}

- (void)setFontSize:(float)fontSize
{
    if (fontSize != _fontSize)
    {
        _fontSize = fontSize;
        _requiresRedraw = YES;
    }
}
 
- (void)setHAlign:(SPHAlign)hAlign
{
    if (hAlign != _hAlign)
    {
        _hAlign = hAlign;
        _requiresRedraw = YES;
    }
}

- (void)setVAlign:(SPVAlign)vAlign
{
    if (vAlign != _vAlign)
    {
        _vAlign = vAlign;
        _requiresRedraw = YES;
    }
}

- (BOOL)border
{
    return _border != nil;
}

- (void)setBorder:(BOOL)value
{
    if (value && !_border)
    {
        _border = [[SPSprite alloc] init];

        for (int i=0; i<4; ++i)
            [_border addChild:[SPQuad quadWithWidth:1.0f height:1.0f]];

        [self addChild:_border];
        [self updateBorder];
    }
    else if (!value && _border)
    {
        [_border removeFromParent];
        SP_RELEASE_AND_NIL(_border);
    }
}

- (void)setColor:(uint)color
{
    if (color != _color)
    {
        _color = color;
        _requiresRedraw = YES;
        [self updateBorder];
    }
}

- (SPRectangle *)textBounds
{
    if (_requiresRedraw) [self redraw];
    if (!_textBounds) _textBounds = [[_contents boundsInSpace:_contents] retain];
    return [[_textBounds copy] autorelease];
}

- (void)setKerning:(BOOL)kerning
{
	if (kerning != _kerning)
	{
		_kerning = kerning;
		_requiresRedraw = YES;
	}
}

- (void)setAutoScale:(BOOL)autoScale
{
    if (_autoScale != autoScale)
    {
        _autoScale = autoScale;
        _requiresRedraw = YES;
    }
}

#pragma mark Private

- (void)redraw
{
    if (_requiresRedraw)
    {
        [_contents reset];
        
        if (_isRenderedText) [self createRenderedContents];
        else                 [self createComposedContents];
        
        _requiresRedraw = NO;
    }
}

- (void)createRenderedContents
{
    float width  = _hitArea.width;
    float height = _hitArea.height;    
    float fontSize = _fontSize == SPNativeFontSize ? SPDefaultFontSize : _fontSize;
    
  #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
    NSLineBreakMode lbm = NSLineBreakByTruncatingTail;
  #else
    UILineBreakMode lbm = UILineBreakModeTailTruncation;
  #endif

    CGSize textSize;
    
    if (_autoScale)
    {
        CGSize maxSize = CGSizeMake(width, FLT_MAX);
        fontSize += 1.0f;
        
        do
        {
            fontSize -= 1.0f;
            textSize = [_text sizeWithFont:[UIFont fontWithName:_fontName size:fontSize]
                         constrainedToSize:maxSize lineBreakMode:lbm];
        } while (textSize.height > height);
    }
    else
    {
        textSize = [_text sizeWithFont:[UIFont fontWithName:_fontName size:fontSize]
                     constrainedToSize:CGSizeMake(width, height) lineBreakMode:lbm];
    }
    
    float xOffset = 0;
    if (_hAlign == SPHAlignCenter)      xOffset = (width - textSize.width) / 2.0f;
    else if (_hAlign == SPHAlignRight)  xOffset =  width - textSize.width;
    
    float yOffset = 0;
    if (_vAlign == SPVAlignCenter)      yOffset = (height - textSize.height) / 2.0f;
    else if (_vAlign == SPVAlignBottom) yOffset =  height - textSize.height;
    
    if (!_textBounds) _textBounds = [[SPRectangle alloc] init];
    [_textBounds setX:xOffset y:yOffset width:textSize.width height:textSize.height];
    
    SPTexture *texture = [[SPTexture alloc] initWithWidth:width height:height generateMipmaps:NO
                                                     draw:^(CGContextRef context)
      {
          float red   = SP_COLOR_PART_RED(_color)   / 255.0f;
          float green = SP_COLOR_PART_GREEN(_color) / 255.0f;
          float blue  = SP_COLOR_PART_BLUE(_color)  / 255.0f;
          
          CGContextSetRGBFillColor(context, red, green, blue, 1.0f);
          
          [_text drawInRect:CGRectMake(0, yOffset, width, height)
                   withFont:[UIFont fontWithName:_fontName size:fontSize] 
              lineBreakMode:lbm alignment:(NSTextAlignment)_hAlign];
      }];
    
    SPImage *image = [[SPImage alloc] initWithTexture:texture];
    [texture release];

    [_contents addQuad:image];
    [image release];
}

- (void)createComposedContents
{
    SPBitmapFont *bitmapFont = bitmapFonts[_fontName];
    if (!bitmapFont)
        [NSException raise:SPExceptionInvalidOperation 
                    format:@"bitmap font %@ not registered!", _fontName];
    
    [bitmapFont fillQuadBatch:_contents withWidth:_hitArea.width height:_hitArea.height
                         text:_text fontSize:_fontSize color:_color hAlign:_hAlign vAlign:_vAlign
                    autoScale:_autoScale kerning:_kerning];

    SP_RELEASE_AND_NIL(_textBounds); // will be created on demand
}

- (void)updateBorder
{
    if (!_border) return;
    
    float width  = _hitArea.width;
    float height = _hitArea.height;
    
    SPQuad *topLine    = (SPQuad *)[_border childAtIndex:0];
    SPQuad *rightLine  = (SPQuad *)[_border childAtIndex:1];
    SPQuad *bottomLine = (SPQuad *)[_border childAtIndex:2];
    SPQuad *leftLine   = (SPQuad *)[_border childAtIndex:3];
    
    topLine.width = width; topLine.height = 1;
    bottomLine.width = width; bottomLine.height = 1;
    leftLine.width = 1; leftLine.height = height;
    rightLine.width = 1; rightLine.height = height;
    rightLine.x = width - 1;
    bottomLine.y = height - 1;
    topLine.color = rightLine.color = bottomLine.color = leftLine.color = _color;
    
    [_border flatten];
}

@end
