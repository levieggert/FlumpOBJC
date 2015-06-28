//
//  SPUtils.m
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SparrowClass.h>
#import <Sparrow/SPNSExtensions.h>
#import <Sparrow/SPUtils.h>

#import <sys/stat.h>

@implementation SPUtils

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"Static class - do not initialize!"];
    return nil;
}

#pragma mark Math Utils

+ (int)nextPowerOfTwo:(int)number
{    
    int result = 1; 
    while (result < number) result *= 2;
    return result;    
}

+ (BOOL)isPowerOfTwo:(int)number
{
    return ((number != 0) && !(number & (number - 1)));
}

+ (int)randomIntBetweenMin:(int)minValue andMax:(int)maxValue
{
    return (int)(minValue + [self randomFloat] * (maxValue - minValue));
}

+ (float)randomFloatBetweenMin:(float)minValue andMax:(float)maxValue
{
    return (float)(minValue + [self randomFloat] * (maxValue - minValue));
}

+ (float)randomFloat
{
    return (float) arc4random() / UINT_MAX;
}

#pragma mark File Utils

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    if (!path)
        return NO;
    else if (![path isAbsolutePath])
        path = [[NSBundle appBundle] pathForResource:path];
    
    struct stat buffer;   
    return stat([path UTF8String], &buffer) == 0;
}

+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor 
                           idiom:(UIUserInterfaceIdiom)idiom
{
    // iOS image resource naming conventions:
    // SD: <ImageName><device_modifier>.<filename_extension>
    // HD: <ImageName>@2x<device_modifier>.<filename_extension>
    
    if (factor < 1.0f) factor = 1.0f;
    
    NSString *originalPath = path;
    NSString *pathWithScale = [path stringByAppendingScaleSuffixToFilename:factor];
    NSString *idiomSuffix = (idiom == UIUserInterfaceIdiomPad) ? @"~ipad" : @"~iphone";
    NSString *pathWithIdiom = [pathWithScale stringByAppendingSuffixToFilename:idiomSuffix];
    
    BOOL isAbsolute = [path isAbsolutePath];
    NSBundle *appBundle = [NSBundle appBundle];
    NSString *absolutePath = isAbsolute ? pathWithScale : [appBundle pathForResource:pathWithScale];
    NSString *absolutePathWithIdiom = isAbsolute ? pathWithIdiom : [appBundle pathForResource:pathWithIdiom];
    
    if ([SPUtils fileExistsAtPath:absolutePathWithIdiom])
        return absolutePathWithIdiom;
    else if ([SPUtils fileExistsAtPath:absolutePath])
        return absolutePath;
    else if (factor >= 2.0f)
        return [SPUtils absolutePathToFile:originalPath withScaleFactor:factor/2.0f idiom:idiom];
    else
        return nil;
}

+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor
{
    UIUserInterfaceIdiom currentIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    return [SPUtils absolutePathToFile:path withScaleFactor:factor idiom:currentIdiom];
}

+ (NSString *)absolutePathToFile:(NSString *)path
{
    return [SPUtils absolutePathToFile:path withScaleFactor:Sparrow.contentScaleFactor];
}

@end
