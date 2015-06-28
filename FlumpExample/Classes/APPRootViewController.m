//
// @author Levi Eggert
//

#import "APPRootViewController.h"
#import "APPUIViewController.h"
#import "APPSparrowViewController.h"

static NSString *const ImageNameXcode = @"xcode";
static NSString *const ImageNameSparrow = @"sparrow";
static NSString *const FrameSuffix = @"Frame: ";
static CGFloat const BackgroundImageAlpha = 1.0f;
static CGFloat const FlumpButtonControlEnabledAlpha = 0.85f;
static CGFloat const FlumpButtonControlDisabledAlpha = 0.4f;
static CGFloat const LbAnimationCompleteShowConstant = 160;
static CGFloat const LbAnimationCompleteHideConstant = -100.0f;

@implementation APPRootViewController

-(id)init
{
    return [super initWithNibName:@"APPRootViewController" bundle:nil];
}

-(void)dealloc
{
    self.uiViewController = nil;
    self.sparrowViewController = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //backgroundImage
    self.backgroundImage.alpha = BackgroundImageAlpha;
    
    //uiViewController
    self.uiViewController = [[APPUIViewController alloc] init];
    [self.view insertSubview:self.uiViewController.view aboveSubview:self.backgroundImage];
    
    //sparrowViewController
    self.sparrowViewController = [[APPSparrowViewController alloc] init];
    [self.view insertSubview:self.sparrowViewController.view aboveSubview:self.backgroundImage];
    
    //lbFrame
    self.lbFrame.textColor = [UIColor blackColor];
    [self.lbFrame setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    self.lbFrame.backgroundColor = [UIColor clearColor];
    
    //lbAnimationComplete
    self.lbAnimationComplete.layer.shadowColor = [UIColor blackColor].CGColor;
    self.lbAnimationComplete.layer.shadowRadius = 5.0f;
    self.lbAnimationComplete.layer.shadowOffset = CGSizeZero;
    self.lbAnimationComplete.layer.shadowOpacity = 0.3f;
    
    //disable flump buttons
    [self setFlumpButtonControl:self.btFlumpUIKitExample enabled:NO];
    [self setFlumpButtonControl:self.btFlumpSparrowExample enabled:NO];
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btStop enabled:NO];
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btLoop enabled:NO];
        
    //hide lbAnimationComplete
    [self setLbAnimationCompleteHidden:YES withAnimation:NO];
    
    //loopFlumpView
    [self loopFlumpView:self.uiViewController.flumpViewUIKit.loop];
    
    //flumpExampleType
    self.flumpExampleType = FlumpExampleTypeUIKit;
    
    [self.uiViewController.flumpViewUIKit play];
    [self.sparrowViewController.flumpSPDisplayObject play];
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
        [self.uiViewController.flumpViewUIKit play];
        [self.sparrowViewController.flumpSPDisplayObject play];
    }
    else if ([button isEqual:self.btPause])
    {
        [self.uiViewController.flumpViewUIKit pause];
        [self.sparrowViewController.flumpSPDisplayObject pause];
    }
    else if ([button isEqual:self.btStop])
    {
        [self.uiViewController.flumpViewUIKit stop];
        [self.sparrowViewController.flumpSPDisplayObject stop];
    }
    else if ([button isEqual:self.btLoop])
    {
        BOOL isLooping = self.uiViewController.flumpViewUIKit.loop;
        
        [self loopFlumpView:!isLooping];
    }
}

#pragma mark private methods

-(void)setFlumpButtonControl:(UIButton *)button enabled:(BOOL)enabled
{
    if (enabled)
    {
        button.backgroundColor = [UIColor darkGrayColor];
        button.alpha = FlumpButtonControlEnabledAlpha;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        button.backgroundColor = [UIColor lightGrayColor];
        button.alpha = FlumpButtonControlDisabledAlpha;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

-(void)setLbAnimationCompleteHidden:(BOOL)hidden withAnimation:(BOOL)animation
{
    if (!hidden)
    {
        self.lbAnimationCompleteTopConstraint.constant = LbAnimationCompleteHideConstant;
        [self.lbAnimationComplete layoutIfNeeded];
        
        self.lbAnimationCompleteTopConstraint.constant = LbAnimationCompleteShowConstant;
        
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
        self.lbAnimationCompleteTopConstraint.constant = LbAnimationCompleteHideConstant;
        
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
        self.uiViewController.flumpViewUIKit.loop = YES;
        self.sparrowViewController.flumpSPDisplayObject.loop = YES;
        
        [self setFlumpButtonControl:self.btLoop enabled:YES];
    }
    else
    {
        self.uiViewController.flumpViewUIKit.loop = NO;
        self.sparrowViewController.flumpSPDisplayObject.loop = NO;
        
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
            
            self.uiViewController.view.hidden = NO;
            self.sparrowViewController.view.hidden = YES;
            
            [self.backgroundImage setImage:[UIImage imageNamed:ImageNameXcode]];
            
            self.uiViewController.flumpViewUIKit.delegate = self;
            self.sparrowViewController.flumpSPDisplayObject.delegate = nil;
            
            break;
        }
        case FlumpExampleTypeSparrow:
        {
            [self setFlumpButtonControl:self.btFlumpUIKitExample enabled:NO];
            [self setFlumpButtonControl:self.btFlumpSparrowExample enabled:YES];
            
            self.uiViewController.view.hidden = YES;
            self.sparrowViewController.view.hidden = NO;
            
            [self.backgroundImage setImage:[UIImage imageNamed:ImageNameSparrow]];
            
            self.uiViewController.flumpViewUIKit.delegate = nil;
            self.sparrowViewController.flumpSPDisplayObject.delegate = self;
            
            break;
        }
    }
}

-(void)setLbFrameCount:(NSInteger)lbFrameCount
{
    _lbFrameCount = lbFrameCount;
    
    NSString *stringFrame = [@(lbFrameCount) stringValue];
    NSMutableString *mutableFrame = [[NSMutableString alloc] initWithString:FrameSuffix];
    [mutableFrame appendString:stringFrame];
    
    self.lbFrame.text = mutableFrame;
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
    self.lbFrameCount = frame;
}

-(void)flumpViewDidComplete:(FLMPView *)flumpView
{
    [self setLbAnimationCompleteHidden:NO withAnimation:YES];
}

#pragma mark FLMPSPDisplayObjectDelegate

-(void)flumpDisplayObjectDidPlay:(FLMPSPDisplayObject *)flumpDisplayObject
{
    [self setFlumpButtonControl:self.btPlay enabled:YES];
    [self setFlumpButtonControl:self.btPause enabled:NO];
    [self setFlumpButtonControl:self.btStop enabled:NO];
    
    [self setLbAnimationCompleteHidden:YES withAnimation:YES];
}

-(void)flumpDisplayObjectDidPause:(FLMPSPDisplayObject *)flumpDisplayObject
{
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btPause enabled:YES];
    [self setFlumpButtonControl:self.btStop enabled:NO];
}

-(void)flumpDisplayObjectDidStop:(FLMPSPDisplayObject *)flumpDisplayObject
{
    [self setFlumpButtonControl:self.btPlay enabled:NO];
    [self setFlumpButtonControl:self.btPause enabled:NO];
    [self setFlumpButtonControl:self.btStop enabled:YES];
    
    [self setLbAnimationCompleteHidden:YES withAnimation:YES];
}

-(void)flumpDisplayObjectDidUpdateFrame:(FLMPSPDisplayObject *)flumpDisplayObject frame:(NSInteger)frame
{
    self.lbFrameCount = frame;
}

-(void)flumpDisplayObjectDidComplete:(FLMPSPDisplayObject *)flumpDisplayObject
{
    [self setLbAnimationCompleteHidden:NO withAnimation:YES];
}

@end
