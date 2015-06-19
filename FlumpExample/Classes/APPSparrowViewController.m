//
//  APPSparrowViewController.m
//  FlumpExample
//
//  Created by Levi Eggert on 6/19/15.
//  Copyright (c) 2015 Levi Eggert. All rights reserved.
//

#import "APPSparrowViewController.h"

#import "SPStage.h"
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
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.view.backgroundColor = [UIColor blackColor];
    self.stage.color = 0xFFFFFF;//0x222222;
    
    [super startWithRoot:[SPSprite class] supportHighResolutions:NO doubleOnPad:NO];
    self.multitouchEnabled = YES;
    self.preferredFramesPerSecond = 60;
    self.paused = NO;
    self.showStats = NO;
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
