//
//  CViewController.m
//  CFlump
//
//  Created by Levi Eggert on 4/17/14.
//  Copyright (c) 2014 Levi Eggert. All rights reserved.
//

#import "APPViewController.h"

#import "FLMPExport.h"
#import "FLMPMovie.h"

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
    self.flumpExport = nil;
    self.flumpMovie = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //flumpExport
    self.flumpExport = [FLMPExport flumpExportWithXMLFileName:@"test3.xml"];
    
    //flumpMovie
    self.flumpMovie = [self.flumpExport.moviesDictionary objectForKey:@"myMovie"];
    CGRect flumpMovieFrame = self.flumpContainer.frame;
    flumpMovieFrame.origin = CGPointMake(0.0f, 0.0f);
    [self.flumpMovie setFrame:flumpMovieFrame];
    
    //flumpContainer
    [self.flumpContainer setBackgroundColor:[UIColor clearColor]];
    [self.flumpContainer addSubview:self.flumpMovie];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.btPlay addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btPause addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btStop addTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.flumpMovie play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.btPlay removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btPause removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btStop removeTarget:self action:@selector(handleUIButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)handleUIButtonTouchUpInside:(UIButton *)button
{
    if ([button isEqual:self.btPlay])
    {
        [self.flumpMovie play];
    }
    else if ([button isEqual:self.btPause])
    {
        [self.flumpMovie pause];
    }
    else if ([button isEqual:self.btStop])
    {
        [self.flumpMovie stop];
    }
}

@end
