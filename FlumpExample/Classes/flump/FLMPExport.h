/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Levi Eggert
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

/**
 * This class handles parsing an xml file exported from the Flump application.  This class will contain
 * all FLMPMovies and textures that are found in the exported xml.  You can access your FLMPMovies here
 * by grabbing them from the moviesDictionary using the movie name.  Movie name can be found in the xml exported from flump
 * in the movie node.  Note that flump will export a project from the path it was in. /directory/file.  FLMPMovie class will remove
 * all paths in the xml file.  Only file names are used.  So /directory/file becomes file.
 *
 * @author Levi Eggert
 */
@interface FLMPExport : NSObject{
    
}

/** A dictionary containing all FLMPMovies which can be accessed by movie name found in the xml exported from flump.
 Note that the movie name will not use the entire path.  Only the file name is used. */
@property(nonatomic, strong, readonly) NSMutableDictionary *moviesDictionary;
/** This dictionary contains all textures (UIImages) found in the xml exported from flump in the texture node. Each texture is
 cut from the atlas it is in. FLMPLayers will access this dictionary so UIImageViews can be allocated for their animation sequence. */
@property(nonatomic, strong, readonly) NSMutableDictionary *subTextures;

/**
 * Static Function for allocating and parsing a new FLMPExport.
 *
 * @param       fileName        The xml file exported from the Flump application.
 */
+(FLMPExport *)flumpExportWithXMLFileName:(NSString *)fileName;

@end
