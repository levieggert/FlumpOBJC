Flump Objective-C Runtime for iOS
======

What is Flump?
----------------

The purpose of Flump is to reduce texture memory consumed by your animations.

In this example we've taken an animation that requires 40 textures and knocked it down to use only 5 textures.  All of this, with the power of Flump.

If you'd like to see more about Flump, you can read more from the developers here:

http://threerings.github.io/flump

https://github.com/tconkling/flump/wiki


How does it work?
----------------

In this example we have an animation that is 40 frames in length. 

A traditional approach to render this animation would be to save 40 textures and display a texture for each frame. Just like a flip book.  However, saving 40 textures isn't very efficient.  Here's where Flump kicks in.

When Flump exports a SWF file it does 2 things.

1. It stuffs all textures required for your animation into texture atlases.
2. It spits out a bunch of data that houses keyframe information about your animation.  Each keyframe holds the necessary information to create a sub texture from an exported texture atlas as well as the transforms that should be applied to that texture when rendering a frame.

So in this example we have 1 texture atlas exported from Flump as well as 4 sub textures created from this atlas.  At runtime we display a texture and apply the appropriate transformations to render the animation frame.

This has reduced our overall texture count to 5!


Installation with CocoaPods
----------------

To install both Flump with UIKit and Flump with Sparrow use:

pod 'FlumpOBJC'

To install Flump with Sparrow use:

pod 'FlumpOBJC/sparrow'

To install Flump with UIKit use:

pod 'FlumpOBJC/uikit'


Common pitfalls
----------------

Double check that the atlas file attribute matches the exported atlas.png.  Sometimes this file attribute will include a path.  Depending on how you add your atlas.png's to Xcode you may need to update this field to in order to correctly load the atlas.

Atlas's are loaded into UIImages using imageName.

Example from test3.xml
```
<atlas file="test3.png">
    <texture name="test3/box3" rect="1,1,61,61" origin="30.5,30.5"/>
    <texture name="test3/box" rect="65,1,61,61" origin="0.5,0.5"/>
    <texture name="test3/box2" rect="1,64,31,31" origin="15.5,15.5"/>
    <texture name="test3/marker" rect="34,64,11,11" origin="5.5,5.5"/>
</atlas>
```

You can also edit your movie names in the XML.

Example from test3.xml

```
<movie name="test3_movie" frameRate="24">
```


Notes exporting Flash SWF to Flump Application
----------------

1. Your flash animation should be a MovieClip symbol exported for Flash and placed at frame 1 on the stage.
2. All layers in the animation should be symbols exported for Flash as Sprites.


Creating a FLMPSPDisplayObject - Sparrow
----------------

```
FLMPExport *flumpExportSparrow = [[FLMPExport alloc] initWithFlumpXMLFileName:@"test3" atlasClass:[FLMPSPAtlas class]];
FLMPSPDisplayObject *flumpDisplayObject = [[FLMPSPDisplayObject alloc] initWithFlumpExport:flumpExportSparrow movieName:@"test3_movie"];

[stage addChild:flumpSPDisplayObject];

[flumpDisplayObject play];
```


Creating a FLMPView - UIkit
----------------

```
FLMPExport *flumpExportUIKit = [[FLMPExport alloc] initWithFlumpXMLFileName:@"test3" atlasClass:[FLMPUIAtlas class]];
FLMPView *flumpView = [[FLMPView alloc] initWithFlumpExport:flumpExportUIKit movieName:@"test3_movie"];

[self.view addSubview:flumpView];

[flumpView play];
```