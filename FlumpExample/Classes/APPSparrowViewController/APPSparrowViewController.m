//
//  APPSparrowViewController.m
//  FlumpExample
//
//  Created by Levi Eggert on 6/19/15.
//  Copyright (c) 2015 Levi Eggert. All rights reserved.
//

#import "APPSparrowViewController.h"

#import "FLMPExport.h"
#import "FLMPSPAtlas.h"
#import "FLMPSPDisplayObject.h"

#import "Sparrow.h"
#import "SPStage.h"
#import "SPStage+Transparency.h"
#import "SPSprite.h"

@implementation APPSparrowViewController

-(id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)dealloc
{
    self.flumpSPDisplayObject = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.view.backgroundColor = [UIColor clearColor];
    self.stage.color = 0x000000;
    [self.stage setTransparent:YES];
    
    [super startWithRoot:[SPSprite class] supportHighResolutions:NO doubleOnPad:NO];
    self.multitouchEnabled = YES;
    self.preferredFramesPerSecond = 60;
    self.paused = NO;
    self.showStats = NO;
    
    //flumpExportSparrow
    FLMPExport *flumpExportSparrow = [[FLMPExport alloc] initWithFlumpXMLFileName:@"test3" atlasClass:[FLMPSPAtlas class]];
    
    //flumpSPDisplayObject
    self.flumpSPDisplayObject = [[FLMPSPDisplayObject alloc] initWithFlumpExport:flumpExportSparrow movieName:@"test3_movie"];
    self.flumpSPDisplayObject.x = 10.0f;
    self.flumpSPDisplayObject.y = 64.0f;
    
    SPStage *stage = Sparrow.stage;
    [stage addChild:self.flumpSPDisplayObject];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

@end
