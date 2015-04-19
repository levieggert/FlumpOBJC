Flump runtime for iOS
======

Dependencies -

XML files exported from Flump are parsed via RaptureXML.

https://github.com/ZaBlanc/RaptureXML

Installing RaptureXML:

In Build Phases link the following:

1. libz.dylib
2. libxml2.dylib

In your build settings, add the following to your "Header Search Paths":

$(SDK_DIR)"/usr/include/libxml2

What is Flump?
----------------

Well if you haven't heard about Flump I suggest taking a look at the Application here first! 
http://threerings.github.io/flump/

FLMP is the Flump runtime for iOS.  It has classes that handle managing flump exports and parsing exports into movies that can be used in your app.

Note! Flump export xml contained a scaleFactor on textureGroups.  This has not been added into the parser.  So assume scaleFactor is always 1.

How does it work?
-----------------

FLMP is broken down into 4 core classes.

* Core

1. FLMPExport - This class is responsible for parsing xml file's exported from Flump.  This class will be used for building and storing your FLMPMovies.  An xml can contain more than one movie so movies are stored in a dictionary.  To retrieve a FLMPMovie use the movie name as the dictionary key.  Movie names can be found in the exported xml movie node.  Note that no paths are used in FLMPExport.  All paths are reduced to file name.

2. FLMPMovie - This class is used to play your flump animations. FLMPMovie's are broken into layers(FLMPLayer) of animated UIImageViews.  Instead of having a texture for each frame, UIImageViews are transformed and tweened frame by frame.  This gives us minimal textures to use and thus low memory.  Thank you Flump!

3. FLMPLayer - These are animated layers that make up the movie.  This class contains a UIImageViews's dictionary of all UIImageViews required for the layer.  It also holds an array of FLMPKeyframes which hold transformation data to manipulate UIImageViews.

4. FLMPkeyframe - This is a helper class for FLMPLayer.  When it comes time to update a new frame, a layer will pull a keyframe and use that transform data to update the UIImageView.

The future of FLMP.
---------------------

I haven't had the chance to use FLMP in a major app.  I've only tested a few animations.  Some that had tweens and some that didn't have any tweens.  But, from what I have tested, the animations run great!
