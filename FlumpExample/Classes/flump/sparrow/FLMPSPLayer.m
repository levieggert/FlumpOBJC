//
//  FLMPSPLayer.m
//  FlumpExample
//
//  Created by Levi Eggert on 7/7/15.
//  Copyright (c) 2015 Levi Eggert. All rights reserved.
//

#import "FLMPSPLayer.h"

#import "SPImage.h"

@implementation FLMPSPLayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        //image
        _image = [[SPImage alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    _image = nil;
    _texturesDictionary = nil;
}

#pragma mark public methods

-(void)addTexture:(SPTexture *)texture withTextureName:(NSString *)textureName
{
    if (texture == nil || textureName == nil)
    {
        return;
    }
    
    if (self.texturesDictionary == nil)
    {
        _texturesDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [self.texturesDictionary setValue:texture forKey:textureName];
}

@end
