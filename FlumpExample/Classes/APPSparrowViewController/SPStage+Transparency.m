//
//  SPStage+Transparency.m
//
//  Created by Shilo White on 6/16/13.
//
//

#import "SPStage+Transparency.h"
#import "Sparrow.h"
#import <Sparrow/SPViewController.h>
#import <Sparrow/SPStatsDisplay.h>
#import <GLKit/GLKit.h>

@interface SPViewController (Transparency)

@property (nonatomic, assign, readonly) SPStatsDisplay *statsDisplay;

@end

@interface SPStatsDisplay ()
{
    int _framesPerSecond;
    int _numDrawCalls;
}
@end

@implementation SPStage (Transparency)

- (void)setTransparent:(BOOL)transparent
{
    if (transparent)
    {
        self.alpha = 0.0f;
        Sparrow.currentController.view.backgroundColor = [UIColor clearColor];
        Sparrow.currentController.view.opaque = NO;
        Sparrow.currentController.statsDisplay.blendMode = SP_BLEND_MODE_AUTO;
    }
    else
    {
        self.alpha = 1.0f;
        Sparrow.currentController.view.backgroundColor = nil;
        Sparrow.currentController.view.opaque = YES;
        Sparrow.currentController.statsDisplay.blendMode = SP_BLEND_MODE_NONE;
    }
}

- (BOOL)transparent
{
    return (self.alpha == 0.0f &&
            Sparrow.currentController.view.backgroundColor == [UIColor clearColor] &&
            Sparrow.currentController.view.opaque == NO);
}

- (void)render:(SPRenderSupport *)support
{
    [SPRenderSupport clearWithColor:self.color alpha:self.alpha];
    [support setupOrthographicProjectionWithLeft:0 right:self.width top:0 bottom:self.height];
    
    [super render:support];
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint
{
    if (!self.visible || !self.touchable)
        return nil;
    
    SPDisplayObject *target = [super hitTestPoint:localPoint];
    if (!target && !self.transparent) target = self;
    
    return target;
}

@end

@implementation GLKView (Transparency)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!Sparrow.stage.transparent)
        return [super pointInside:point withEvent:event];
    
    for (UIView *subview in [self subviews])
        if ([subview pointInside:[subview convertPoint:point fromView:self] withEvent:event])
            return YES;
    
    if (Sparrow.currentController.doubleOnPad && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))
    {
        point.x /= 2;
        point.y /= 2;
    }
    
    return ([Sparrow.stage hitTestPoint:[SPPoint pointWithX:point.x y:point.y]])?YES:NO;
}

@end

@implementation SPViewController (Transparency)

- (SPStatsDisplay *)statsDisplay
{
    return [self valueForKey:@"_statsDisplay"];
}

@end

@implementation SPStatsDisplay (Transparency)

- (id)init
{
    if ((self = [super init]))      
    {
        SPQuad *background = [[SPQuad alloc] initWithWidth:45 height:17 color:0x0];
        [self addChild:background];
        
        self.blendMode = (Sparrow.stage.transparent)?SP_BLEND_MODE_AUTO:SP_BLEND_MODE_NONE;
        
        [self addEventListener:@selector(onAddedToStage:) atObject:self
                       forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
        [self addEventListener:@selector(onEnterFrame:) atObject:self
                       forType:SP_EVENT_TYPE_ENTER_FRAME];
    }
    return self;
}

@end