//
//  CViewController.m
//  CFlump
//
//  Created by Levi Eggert on 4/17/14.
//  Copyright (c) 2014 Levi Eggert. All rights reserved.
//

#import "APPViewController.h"
#import "APPSparrowViewController.h"

#import "FLMPExport.h"
#import "FLMPSPAtlas.h"
#import "FLMPUIAtlas.h"

#import "Sparrow.h"
#import "SPStage.h"

static NSString *const FrameSuffix = @"Frame: ";

@implementation APPViewController

- (id)init
{
    self = [super initWithNibName:@"APPViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    self.sparrowViewController = nil;
    self.flumpSPDisplayObject = nil;
    self.flumpViewUIKit = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //sparrowViewController
    self.sparrowViewController = [[APPSparrowViewController alloc] init];
    [self.view insertSubview:self.sparrowViewController.view atIndex:0];
    
    //lbFrame
    self.lbFrame.textColor = [UIColor blackColor];
    [self.lbFrame setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    
    //disable flump buttons
    [self setFlumpButtonControl:self.btFlumpUIKitExample enabled:NO];
    [self setFlumpButtonControl:self.btFlumpSparrowExample enabled:NO];
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btStop enabled:NO];
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btLoop enabled:NO];
    
    //hide lbAnimationComplete
    [self setLbAnimationCompleteHidden:YES withAnimation:NO];
    
    //flumpExportUIKit
    FLMPExport *flumpExportSparrow = [[FLMPExport alloc] initWithFlumpXMLFileName:@"test3" atlasClass:[FLMPSPAtlas class]];
    
    //flumpSPDisplayObject
    self.flumpSPDisplayObject = [[FLMPSPDisplayObject alloc] initWithFlumpExport:flumpExportSparrow movieName:@"test3_movie"];
    self.flumpSPDisplayObject.x = 10.0f;
    self.flumpSPDisplayObject.y = 64.0f;
    [self.flumpSPDisplayObject play];
    
    SPStage *stage = Sparrow.stage;
    [stage addChild:self.flumpSPDisplayObject];
    
    //flumpExportUIKit
    FLMPExport *flumpExportUIKit = [[FLMPExport alloc] initWithFlumpXMLFileName:@"test3" atlasClass:[FLMPUIAtlas class]];
    
    //flumpViewUIKit
    self.flumpViewUIKit = [[FLMPView alloc] initWithFlumpExport:flumpExportUIKit movieName:@"test3_movie"];
    self.flumpViewUIKit.delegate = self;
    CGRect flumpViewFrame = self.flumpContainer.frame;
    flumpViewFrame.origin = CGPointMake(0.0f, 0.0f);
    [self.flumpViewUIKit setFrame:flumpViewFrame];
        
    //flumpContainer
    [self.flumpContainer setBackgroundColor:[UIColor clearColor]];
    self.flumpContainer.layer.borderColor = [UIColor clearColor].CGColor;
    self.flumpContainer.layer.borderWidth = 1.0f;
    [self.flumpContainer addSubview:self.flumpViewUIKit];

    //play
    [self.flumpViewUIKit play];
    [self loopFlumpView:YES];
    
    //flumpExampleType
    self.flumpExampleType = FlumpExampleTypeSparrow;
}

- (void)didReceiveMemoryWarning
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
    
    [self.btFlumpUIKitExample addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btFlumpSparrowExample addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btPlay addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btPause addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btStop addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btLoop addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.btFlumpUIKitExample removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btFlumpSparrowExample removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btPlay removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btPause removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btStop removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btLoop removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)handleUIButtonTouchUpInside:(UIButton *)button
{
    if ([button isEqual:self.btFlumpUIKitExample])
    {
        self.flumpExampleType = FlumpExampleTypeUIKit;
    }
    if ([button isEqual:self.btFlumpSparrowExample])
    {
        self.flumpExampleType = FlumpExampleTypeSparrow;
    }
    if ([button isEqual:self.btPlay])
    {
        [self.flumpViewUIKit play];
        [self.flumpSPDisplayObject play];
    }
    else if ([button isEqual:self.btPause])
    {
        [self.flumpViewUIKit pause];
        [self.flumpSPDisplayObject pause];
    }
    else if ([button isEqual:self.btStop])
    {
        [self.flumpViewUIKit stop];
        [self.flumpSPDisplayObject stop];
    }
    else if ([button isEqual:self.btLoop])
    {
        BOOL isLooping = self.flumpViewUIKit.loop;
        
        [self loopFlumpView:!isLooping];
    }
}

#pragma mark private methods

-(void)updateFrame:(NSInteger)frame
{
    NSString *stringFrame = [@(frame) stringValue];
    NSMutableString *mutableFrame = [[NSMutableString alloc] initWithString:FrameSuffix];
    [mutableFrame appendString:stringFrame];
    
    self.lbFrame.text = mutableFrame;
}

-(void)setFlumpButtonControl:(UIButton *)button enabled:(BOOL)enabled
{
    if (enabled)
    {
        button.backgroundColor = [UIColor darkGrayColor];
        button.alpha = 1.0f;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        button.backgroundColor = [UIColor lightGrayColor];
        button.alpha = 0.4f;
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

-(void)setLbAnimationCompleteHidden:(BOOL)hidden withAnimation:(BOOL)animation
{
    if (!hidden)
    {
        self.lbAnimationCompleteTopConstraint.constant = -60.0f;
        [self.lbAnimationComplete layoutIfNeeded];
        
        self.lbAnimationCompleteTopConstraint.constant = 100.0f;
        
        self.lbAnimationComplete.alpha = 0.0f;
        
        if (animation)
        {
            [UIView animateWithDuration:0.85 delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                //animations
                [self.lbAnimationComplete layoutIfNeeded];
                self.lbAnimationComplete.alpha = 1.0f;
            } completion:^(BOOL finished) {
                //complete
            }];
        }
        else
        {
            [self.lbAnimationComplete layoutIfNeeded];
            self.lbAnimationComplete.alpha = 1.0f;
        }
    }
    else if (hidden)
    {
        self.lbAnimationCompleteTopConstraint.constant = -60.0f;
        
        if (animation)
        {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                //animations
                [self.lbAnimationComplete layoutIfNeeded];
            } completion:^(BOOL finished) {
                //complete
            }];
        }
        else
        {
            [self.lbAnimationComplete layoutIfNeeded];
        }
    }
}

-(void)loopFlumpView:(BOOL)loop
{
    if (loop)
    {
        self.flumpViewUIKit.loop = YES;
        self.flumpSPDisplayObject.loop = YES;
        
        [self setFlumpButtonControl:self.btLoop enabled:YES];
    }
    else
    {
        self.flumpViewUIKit.loop = NO;
        self.flumpSPDisplayObject.loop = NO;
        
        [self setFlumpButtonControl:self.btLoop enabled:NO];
    }
}

#pragma mark getters/setters

-(void)setFlumpExampleType:(FlumpExampleType)flumpExampleType
{
    if (self.flumpExampleType == flumpExampleType)
        return;
    
    _flumpExampleType = flumpExampleType;
    
    switch (flumpExampleType)
    {
        case FlumpExampleTypeUIKit:
        {
            [self setFlumpButtonControl:self.btFlumpUIKitExample enabled:YES];
            [self setFlumpButtonControl:self.btFlumpSparrowExample enabled:NO];
            
            self.flumpViewUIKit.hidden = NO;
            self.sparrowViewController.view.hidden = YES;
            
            break;
        }
        case FlumpExampleTypeSparrow:
        {
            [self setFlumpButtonControl:self.btFlumpUIKitExample enabled:NO];
            [self setFlumpButtonControl:self.btFlumpSparrowExample enabled:YES];
            
            self.flumpViewUIKit.hidden = YES;
            self.sparrowViewController.view.hidden = NO;
            
            break;
        }
    }
}

#pragma mark FLMPViewDelegate

-(void)flumpViewDidPlay:(FLMPView *)flumpView
{
    [self setFlumpButtonControl:self.btPlay enabled:YES];
    [self setFlumpButtonControl:self.btPause enabled:NO];
    [self setFlumpButtonControl:self.btStop enabled:NO];
    
    [self setLbAnimationCompleteHidden:YES withAnimation:YES];
}

-(void)flumpViewDidPause:(FLMPView *)flumpView
{
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btPause enabled:YES];
    [self setFlumpButtonControl:self.btStop enabled:NO];
}

-(void)flumpViewDidStop:(FLMPView *)flumpView
{
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btPause enabled:NO];
    [self setFlumpButtonControl:self.btStop enabled:YES];
    
    [self setLbAnimationCompleteHidden:YES withAnimation:YES];
}

-(void)flumpViewDidUpdateFrame:(FLMPView *)flumpView frame:(NSInteger)frame
{
    [self updateFrame:frame];
}

-(void)flumpViewDidComplete:(FLMPView *)flumpView
{
    [self setLbAnimationCompleteHidden:NO withAnimation:YES];
}

@end
