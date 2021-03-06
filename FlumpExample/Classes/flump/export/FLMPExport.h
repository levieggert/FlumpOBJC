/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Levi Eggert
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

@class FLMPAtlas;
@class FLMPMovie;

@interface FLMPExport : NSObject<NSXMLParserDelegate>{
    
}

@property(nonatomic, strong, readonly) NSXMLParser *flumpXMLParser;
@property(nonatomic, strong, readonly) NSMutableDictionary *movies;
@property(nonatomic, strong, readonly) NSMutableArray *atlases;
@property(nonatomic, readonly) Class AtlasClass;
@property(nonatomic, strong, readonly) NSString *lastAddedMovieName;

-(id)initWithFlumpXMLFileName:(NSString *)fileName;
-(id)initWithFlumpXMLFileName:(NSString *)fileName atlasClass:(Class)atlasClass;
-(FLMPMovie *)getFlumpMovieWithMovieName:(NSString *)movieName;
-(FLMPAtlas *)getAtlasWithTextureName:(NSString *)textureName;

@end
