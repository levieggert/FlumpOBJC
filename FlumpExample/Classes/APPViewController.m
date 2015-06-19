//
//  CViewController.m
//  CFlump
//
//  Created by Levi Eggert on 4/17/14.
//  Copyright (c) 2014 Levi Eggert. All rights reserved.
//

#import "APPViewController.h"

#import "FLMPExport.h"

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
    self.flumpView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //lbFrame
    self.lbFrame.textColor = [UIColor blackColor];
    [self.lbFrame setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    
    //disable flump buttons
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btStop enabled:NO];
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btLoop enabled:NO];
    
    //hide lbAnimationComplete
    [self setLbAnimationCompleteHidden:YES withAnimation:NO];
    
    //flumpExport
    FLMPExport *flumpExport = [[FLMPExport alloc] initWithFlumpXMLFileName:@"test3"];
    
    //flumpView
    self.flumpView = [[FLMPView alloc] initWithFlumpExport:flumpExport movieName:@"test3_movie"];
    self.flumpView.delegate = self;
    CGRect flumpViewFrame = self.flumpContainer.frame;
    flumpViewFrame.origin = CGPointMake(0.0f, 0.0f);
    [self.flumpView setFrame:flumpViewFrame];
        
    //flumpContainer
    [self.flumpContainer setBackgroundColor:[UIColor whiteColor]];
    self.flumpContainer.layer.borderColor = [UIColor clearColor].CGColor;
    self.flumpContainer.layer.borderWidth = 1.0f;
    [self.flumpContainer addSubview:self.flumpView];
    
    //play flumpView
    [self.flumpView play];
    [self loopFlumpView:YES];
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
    
    [self.btPlay addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btPause addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btStop addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btLoop addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    if ([button isEqual:self.btPlay])
    {
        [self.flumpView play];
    }
    else if ([button isEqual:self.btPause])
    {
        [self.flumpView pause];
    }
    else if ([button isEqual:self.btStop])
    {
        [self.flumpView stop];
    }
    else if ([button isEqual:self.btLoop])
    {
        BOOL isLooping = self.flumpView.loop;
        
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
        button.alpha = 1.0f;
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
        self.flumpView.loop = YES;
        
        [self setFlumpButtonControl:self.btLoop enabled:YES];
    }
    else
    {
        self.flumpView.loop = NO;
        
        [self setFlumpButtonControl:self.btLoop enabled:NO];
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
